vim.pack.add({
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
})

local dap, dapui = require('dap'), require('dapui')
dapui.setup()
require('nvim-dap-virtual-text').setup({})

dap.listeners.before.attach.dapui = dapui.open
dap.listeners.before.launch.dapui = dapui.open
dap.listeners.before.event_terminated.dapui = dapui.close
dap.listeners.before.event_exited.dapui = dapui.close

vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticError' })
vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DiagnosticHint' })
vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DiagnosticInfo' })
vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticWarn', linehl = 'CursorLine' })

-- gdb >= 14 speaks DAP natively. Extra config fields:
--   gdb    = 'gdb' | 'rust-gdb'
--   rr     = true when attaching to an `rr replay` gdbserver
--   tbreak = one-shot breakpoint location, e.g. 'crate::tests::foo'
dap.adapters.gdb = function(callback, config)
  local args = { '--quiet', '--interpreter=dap', '-iex', 'set breakpoint pending on' }
  if config.rr then vim.list_extend(args, { '-l', '10000', '-iex', 'set sysroot /' }) end
  if config.tbreak then vim.list_extend(args, { '-ex', 'tbreak ' .. config.tbreak }) end
  callback({ type = 'executable', command = config.gdb, args = args })
end

local function notify(msg, level) vim.notify(msg, level or vim.log.levels.INFO, { title = 'dap' }) end

local function project_lang()
  if vim.uv.fs_stat('Cargo.toml') then return 'rust' end
  if vim.uv.fs_stat('compile_commands.json') then return 'c' end
end

--------------------------------------------------------------------------------
-- Running: rr record -> rr replay -> gdb attach, or plain gdb launch without rr

local rr_trace = vim.fn.stdpath('state') .. '/rr-trace'
local last_spec -- the last run, if it was recorded with rr

-- The `rr replay` server ends with its debug session
local function stop_replay(session)
  if session.config.rr_job then vim.fn.jobstop(session.config.rr_job) end
end
dap.listeners.after.event_terminated.rr = stop_replay
dap.listeners.after.disconnect.rr = stop_replay

-- Breakpoints are set during attach. Then run to the first one (or crash / end of trace),
-- once nvim-dap has processed the stop.
local function continue_when_stopped(session, tries)
  if session.stopped_thread_id then return dap.continue() end
  if tries > 0 then vim.defer_fn(function() continue_when_stopped(session, tries - 1) end, 20) end
end
dap.listeners.after.event_stopped.rr = function(session, body)
  if session.config.rr and body.reason == 'attach' then continue_when_stopped(session, 100) end
end

--- Plain gdb, without rr
local function launch(spec)
  last_spec = nil
  dap.run({
    type = 'gdb', request = 'launch', name = spec.name, gdb = spec.gdb, tbreak = spec.tbreak,
    program = spec.program, args = spec.args, cwd = spec.cwd,
    -- gdb replaces the whole environment with `env`
    env = spec.env and vim.tbl_extend('force', vim.fn.environ(), spec.env),
  })
end

--- Replays the last rr recording in a fresh gdb session (no re-recording)
local function replay()
  if not last_spec then return notify('No rr recording to replay', vim.log.levels.WARN) end
  local spec, started, stderr, job = last_spec, false, {}, nil
  job = vim.fn.jobstart({ 'rr', 'replay', '-s', '0', rr_trace }, {
    on_stdout = function(_, lines)
      for _, line in ipairs(lines) do
        if line ~= '' then require('dap.repl').append(line) end
      end
    end,
    on_stderr = function(_, lines)
      vim.list_extend(stderr, lines)
      for _, line in ipairs(lines) do
        local port = line:match('target extended%-remote [%d.]+:(%d+)')
        if port and not started then
          started = true
          dap.run({
            type = 'gdb', request = 'attach', name = 'rr: ' .. spec.name, rr = true, rr_job = job,
            gdb = spec.gdb, program = spec.program, target = '127.0.0.1:' .. port, tbreak = spec.tbreak,
          })
        end
      end
    end,
    on_exit = function()
      if not started then notify('rr replay failed:\n' .. table.concat(stderr, '\n'), vim.log.levels.ERROR) end
    end,
  })
end

--- spec: { name, program, args: string[], cwd?, env?, lang, tbreak? }
--- Set `vim.g.dap_rr = false` to always use plain gdb.
local function run(spec)
  -- A new run replaces the current one (and its rr recording)
  if dap.session() then return dap.terminate({ on_done = vim.schedule_wrap(function() run(spec) end) }) end

  spec.gdb = (spec.lang == 'rust' and vim.fn.executable('rust-gdb') == 1) and 'rust-gdb' or 'gdb'
  spec.cwd = spec.cwd or vim.fn.getcwd()
  if vim.g.dap_rr == false or vim.fn.executable('rr') == 0 then return launch(spec) end

  -- Record in a terminal so the program can read input and be stopped with CTRL-C, then replay
  vim.fn.delete(rr_trace, 'rf')
  local prev_win = vim.api.nvim_get_current_win()
  vim.cmd('botright 12new')
  local term_buf = vim.api.nvim_get_current_buf()
  local tail, failed = '', false
  vim.fn.jobstart(vim.list_extend({ 'rr', 'record', '-o', rr_trace, spec.program }, spec.args), {
    term = true,
    cwd = spec.cwd,
    env = spec.env,
    -- rr's own errors look like "[FATAL src/record_syscall.cc:6733:...]". With a terminal rr then
    -- waits for an emergency debugger instead of exiting, so make sure everything is gone.
    on_stdout = function(job, data)
      local chunk = tail .. table.concat(data, '\n')
      tail = chunk:sub(-100) -- in case the message is split across chunks
      if not failed and chunk:find('%[FATAL [%w_/]+%.%a+:%d+:') then
        failed = true
        vim.uv.kill(-vim.fn.jobpid(job), 'sigkill') -- the terminal's whole process group
      end
    end,
    on_exit = function()
      vim.schedule(function()
        local incomplete = vim.uv.fs_stat(rr_trace .. '/incomplete')
        if failed or incomplete or not vim.uv.fs_stat(rr_trace .. '/version') then
          notify('rr failed to record (see terminal), using plain gdb', vim.log.levels.WARN)
          return launch(spec)
        end
        if vim.api.nvim_buf_is_valid(term_buf) then vim.api.nvim_buf_delete(term_buf, { force = true }) end
        last_spec = spec
        replay()
      end)
    end,
  })
  vim.api.nvim_set_current_win(prev_win)
end

--- Replays the last recording again, else reruns the last session
local function restart()
  local function rerun()
    if last_spec then replay() else dap.run_last() end
  end
  if dap.session() then dap.terminate({ on_done = vim.schedule_wrap(rerun) }) else rerun() end
end

--- Runs a gdb CLI command, e.g. reverse execution which gdb's DAP server has no requests for
local function gdb_cmd(cmd)
  local session = dap.session()
  if not session then return end
  session:request('evaluate', { expression = cmd, context = 'repl' }, function(err)
    if err then notify(cmd .. ': ' .. err.message, vim.log.levels.ERROR) end
  end)
end

--- dap.run_to_cursor() backwards (rr): back to where the cursor line last ran, ignoring other
--- breakpoints. Without a hit it stops at the start of the recording.
local function reverse_to_cursor()
  local session = dap.session()
  if not (session and session.config.rr) then return notify('Needs an rr session', vim.log.levels.INFO) end
  local function exec(cmd) session:request('evaluate', { expression = cmd, context = 'repl' }, function() end) end
  dap.listeners.after.event_stopped.reverse_to_cursor = function()
    dap.listeners.after.event_stopped.reverse_to_cursor = nil
    exec('enable')
    exec('delete $rtc') -- fails if it was hit, as tbreaks delete themselves
  end
  exec('disable')
  exec(('tbreak %s:%d'):format(vim.api.nvim_buf_get_name(0), vim.api.nvim_win_get_cursor(0)[1]))
  exec('set $rtc = $bpnum')
  exec('reverse-continue')
end

--------------------------------------------------------------------------------
-- Executable discovery

--- Splits an argument line like a shell would (quotes, $VARS, globs)
local function split_args(line)
  if line:match('^%s*$') then return {} end
  local out = vim.system({ 'sh', '-c', 'printf "%s\\0" ' .. line }):wait().stdout or ''
  local args = vim.split(out, '\0', { plain = true })
  table.remove(args) -- trailing NUL
  return args
end

--- Builds with cargo and returns `{ label, path, crate }` for every executable artifact
local function cargo_artifacts(cargo_args, cwd, cb)
  local cmd = vim.list_extend({ 'cargo' }, cargo_args)
  vim.list_extend(cmd, { '--message-format=json-render-diagnostics' })
  notify('Building: ' .. table.concat(cmd, ' ', 2, #cmd - 1))
  vim.system(cmd, { cwd = cwd, text = true }, vim.schedule_wrap(function(res)
    if res.code ~= 0 then
      local lines = vim.split(vim.trim(res.stderr or ''), '\n')
      return notify(table.concat(vim.list_slice(lines, #lines - 20), '\n'), vim.log.levels.ERROR)
    end
    local items = {}
    for line in vim.gsplit(res.stdout, '\n', { trimempty = true }) do
      local ok, msg = pcall(vim.json.decode, line)
      if ok and msg.reason == 'compiler-artifact' and msg.executable ~= vim.NIL then
        local kind, name = msg.target.kind[1], msg.target.name
        local label
        if kind == 'test' then label = 'test     ' .. name
        elseif msg.profile.test then label = ('test     %s (%s)'):format(name, kind)
        elseif kind == 'example' then label = 'example  ' .. name
        elseif kind == 'bin' then label = 'bin      ' .. name
        end
        if label then
          table.insert(items, { label = label, path = msg.executable, crate = name:gsub('-', '_') })
        end
      end
    end
    cb(items)
  end))
end

--- ELF executables below the directory compile_commands.json points into
local function c_executables(cb)
  local root = vim.fs.dirname(vim.uv.fs_realpath('compile_commands.json'))
  vim.system({
    'find', root, '-type', 'f', '-perm', '-u+x',
    '-not', '-path', '*/CMakeFiles/*', '-not', '-path', '*/.git/*', '-not', '-name', '*.so', '-not', '-name', '*.so.*',
  }, { text = true }, vim.schedule_wrap(function(res)
    local cwd, items = vim.fn.getcwd(), {}
    for path in vim.gsplit(res.stdout or '', '\n', { trimempty = true }) do
      local f = io.open(path, 'rb')
      local magic = f and f:read(4)
      if f then f:close() end
      if magic == '\127ELF' then
        table.insert(items, { label = vim.fs.relpath(cwd, path) or path, path = path })
      end
    end
    cb(items)
  end))
end

--------------------------------------------------------------------------------
-- Last used executable + args, per cwd

local state_file = vim.fn.stdpath('state') .. '/dap-last.json'

local function load_state()
  local f = io.open(state_file, 'r')
  if not f then return {} end
  local ok, state = pcall(vim.json.decode, f:read('*a'))
  f:close()
  return ok and state or {}
end

local function save_last(entry)
  local state = load_state()
  state[vim.fn.getcwd()] = entry
  local f = io.open(state_file, 'w')
  if f then
    f:write(vim.json.encode(state))
    f:close()
  end
end

--------------------------------------------------------------------------------
-- Entry points

--- Picks an executable (last used on top), asks for args (last used prefilled), runs it
local function debug_pick()
  local lang = project_lang()
  if not lang then return notify('No Cargo.toml or compile_commands.json in cwd', vim.log.levels.WARN) end
  local last = load_state()[vim.fn.getcwd()] or {}

  local function pick(items)
    if #items == 0 then return notify('No executables found', vim.log.levels.WARN) end
    table.sort(items, function(a, b) return a.label < b.label end)
    for i, item in ipairs(items) do
      if item.label == last.label then
        table.insert(items, 1, table.remove(items, i))
        break
      end
    end
    for _, item in ipairs(items) do item.text = item.label end

    local item = MiniPick.start({ source = {
      name = 'Debug executable',
      items = items,
      choose = function() end,
      preview = function(buf, it) vim.api.nvim_buf_set_lines(buf, 0, -1, false, { it.path }) end,
    } })
    if not item then return end

    local default = item.label == last.label and last.args or ''
    vim.ui.input({ prompt = 'Args: ', default = default }, function(input)
      if input == nil then return end
      save_last({ label = item.label, args = input })
      run({ name = vim.trim(item.label), program = item.path, args = split_args(input), lang = lang })
    end)
  end

  if lang == 'rust' then
    cargo_artifacts({ 'build', '--bins', '--examples', '--tests' }, nil, pick)
  else
    c_executables(pick)
  end
end

--- Debugs the Rust test under the cursor, using rust-analyzer's runnables
local function rust_debug_test()
  local client = vim.lsp.get_clients({ bufnr = 0, name = 'rust_analyzer' })[1]
  if not client then return notify('rust-analyzer is not attached', vim.log.levels.WARN) end
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  local bufnr = vim.api.nvim_get_current_buf()

  local function on_runnables(runnables)
    -- A single test, else the enclosing test module
    local runnable
    for _, prefix in ipairs({ 'test ', 'test%-mod ' }) do
      for _, r in ipairs(runnables or {}) do
        if r.label:match('^' .. prefix) then runnable = r end
      end
      if runnable then break end
    end
    if not runnable then return notify('No test at cursor', vim.log.levels.WARN) end

    local a = runnable.args
    local cargo_args = vim.list_extend(vim.list_slice(a.cargoArgs, 1, 1), { '--no-run' })
    vim.list_extend(cargo_args, vim.list_slice(a.cargoArgs, 2))
    vim.list_extend(cargo_args, a.cargoExtraArgs or {})

    local args = vim.deepcopy(a.executableArgs or {})
    if not vim.list_contains(args, '--nocapture') then table.insert(args, '--nocapture') end

    local cwd = a.cwd or a.workspaceRoot
    cargo_artifacts(cargo_args, cwd, function(items)
      if #items == 0 then return notify('No test executable built', vim.log.levels.ERROR) end
      local test = items[#items]
      -- Without any breakpoints, stop at the start of a single test: `<crate>::<path::to::test>`
      local tbreak
      if runnable.label:match('^test ') and vim.tbl_isempty(require('dap.breakpoints').get()) then
        tbreak = test.crate .. '::' .. args[1]
      end
      run({
        name = runnable.label,
        program = test.path,
        args = args,
        cwd = cwd,
        env = a.environment,
        lang = 'rust',
        tbreak = tbreak,
      })
    end)
  end

  local function request(tries)
    client:request('experimental/runnables', params, function(err, runnables)
      -- rust-analyzer is still loading the workspace: ContentModified, or nothing at all
      -- (it always lists `cargo check`/`cargo test` for the package once it is ready)
      if tries > 0 and ((err and err.code == -32801) or (not err and vim.tbl_isempty(runnables or {}))) then
        return vim.defer_fn(function() request(tries - 1) end, 500)
      end
      if err then return notify(err.message, vim.log.levels.ERROR) end
      on_runnables(runnables)
    end, bufnr)
  end
  request(20)
end

local gtest_macros = { TEST = true, TEST_F = true, TEST_P = true, TYPED_TEST = true, TYPED_TEST_P = true }
local catch_macros = { TEST_CASE = true, TEST_CASE_METHOD = true, SCENARIO = true, TEMPLATE_TEST_CASE = true }

--- The gtest / Catch2 test case whose body contains the cursor
local function cpp_test_at_cursor()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for lnum = row, 1, -1 do
    local macro = lines[lnum]:match('^%s*([%u_]+)%s*%(')
    if macro and (gtest_macros[macro] or catch_macros[macro]) then
      -- Header up to the body's `{`, which may be on a later line
      local header, brace_row, brace_col = '', nil, nil
      for l = lnum, math.min(lnum + 5, #lines) do
        local col = lines[l]:find('{', 1, true)
        header = header .. ' ' .. (col and lines[l]:sub(1, col - 1) or lines[l])
        if col then brace_row, brace_col = l, col break end
      end
      local body = brace_row and vim.treesitter.get_node({ pos = { brace_row - 1, brace_col - 1 } })
      if not (body and body:type() == 'compound_statement') then return end
      local _, _, end_row = body:range()
      if row - 1 > end_row then return end -- cursor is below this test, e.g. in a helper

      local args = header:match('%((.*)%)') or ''
      local first = body:named_child(0)
      local test = { line = (first and first:range() or end_row) + 1 }
      if gtest_macros[macro] then
        test.suite, test.name = args:match('^%s*([%w_]+)%s*,%s*([%w_]+)')
        test.label = ('%s.%s'):format(test.suite, test.name)
      else
        test.name = args:match('"(.-)"')
        if macro == 'SCENARIO' and test.name then test.name = 'Scenario: ' .. test.name end
        test.label = test.name
      end
      return test.name and test
    end
  end
end

--- Whether a CTest test runs `test`. For gtest, returns its --gtest_filter value.
local function ctest_runs(ctest, test)
  for _, arg in ipairs(vim.list_slice(ctest.command or {}, 2)) do
    if test.suite then
      -- "Suite.Name", parametrized "Instance/Suite.Name/Param", typed "Suite/Type.Name"
      local suite, name = (arg:match('^%-%-gtest_filter=(.*)$') or ''):match('^(.-)%.(.*)$')
      if suite and vim.list_contains(vim.split(suite, '/'), test.suite) and vim.split(name, '/')[1] == test.name then
        return arg:match('=(.*)$')
      end
    elseif arg:gsub('\\(.)', '%1') == test.name then -- Catch2 escapes `,[]\`
      return arg
    end
  end
end

--- Debugs the gtest / Catch2 test under the cursor, as CTest would run it
local function cpp_debug_test()
  local test = cpp_test_at_cursor()
  if not test then return notify('No test at cursor', vim.log.levels.WARN) end
  local file = vim.api.nvim_buf_get_name(0)
  local build = vim.fs.dirname(vim.uv.fs_realpath('compile_commands.json'))

  vim.system({ 'ctest', '--test-dir', build, '--show-only=json-v1' }, { text = true }, vim.schedule_wrap(function(res)
    local ok, json = pcall(vim.json.decode, res.stdout or '')
    if res.code ~= 0 or not ok then return notify('ctest failed:\n' .. (res.stderr or ''), vim.log.levels.ERROR) end

    -- All instances of a parametrized / typed gtest run at once
    local found, filters = nil, {}
    for _, ctest in ipairs(json.tests or {}) do
      local match = ctest_runs(ctest, test)
      if match and (not found or ctest.command[1] == found.command[1]) then
        found = found or ctest
        table.insert(filters, match)
      end
    end
    if not found then return notify(test.label .. ' is not known to CTest. Rebuild?', vim.log.levels.WARN) end

    local props = {}
    for _, p in ipairs(found.properties or {}) do props[p.name] = p.value end
    local args = vim.list_slice(found.command, 2)
    for i, arg in ipairs(args) do
      if arg:match('^%-%-gtest_filter=') then args[i] = '--gtest_filter=' .. table.concat(filters, ':') end
    end
    local env
    for _, kv in ipairs(type(props.ENVIRONMENT) == 'string' and { props.ENVIRONMENT } or props.ENVIRONMENT or {}) do
      local k, v = kv:match('^([^=]+)=(.*)$')
      if k then env = env or {}; env[k] = v end
    end

    run({
      name = test.label,
      program = found.command[1],
      args = args,
      cwd = props.WORKING_DIRECTORY,
      env = env,
      lang = 'c',
      -- Without any breakpoints, stop at the start of the test
      tbreak = vim.tbl_isempty(require('dap.breakpoints').get()) and ('%s:%d'):format(file, test.line) or nil,
    })
  end))
end

local function debug_test()
  local lang = project_lang()
  if lang == 'rust' then return rust_debug_test() end
  if lang == 'c' then return cpp_debug_test() end
  notify('No Cargo.toml or compile_commands.json in cwd', vim.log.levels.WARN)
end

vim.api.nvim_create_user_command('Debug', debug_pick, { desc = 'Debug an executable of this project' })
vim.api.nvim_create_user_command('DebugTest', debug_test, { desc = 'Debug the test at the cursor' })
vim.api.nvim_create_user_command('DebugReplay', replay, { desc = 'Replay the last rr recording' })
vim.api.nvim_create_user_command('DebugGdb', function(o) gdb_cmd(o.args) end, {
  nargs = '+', desc = 'Run a gdb command (e.g. reverse-next) in the debug session',
})

--------------------------------------------------------------------------------
-- Keymaps

local map = function(lhs, rhs, desc, mode) vim.keymap.set(mode or 'n', lhs, rhs, { desc = 'Debug: ' .. desc }) end

map('<F5>', function()
  if dap.session() then dap.continue() else debug_pick() end
end, 'Start / continue')
map('<F17>', dap.terminate, 'Stop') -- S-F5
map('<F41>', restart, 'Replay recording / rerun') -- C-S-F5
map('<F9>', dap.toggle_breakpoint, 'Toggle breakpoint')
map('<leader>b', dap.toggle_breakpoint, 'Toggle [B]reakpoint')
map('<leader>B', function()
  vim.ui.input({ prompt = 'Condition: ' }, function(cond)
    if cond then dap.set_breakpoint(cond) end
  end)
end, 'Conditional [B]reakpoint')
map('<F4>', dap.run_to_cursor, 'Run to cursor')
map('<F28>', reverse_to_cursor, 'Reverse run to cursor') -- C-F4
map('<F10>', dap.step_over, 'Step over')
map('<F11>', dap.step_into, 'Step into')
map('<F23>', dap.step_out, 'Step out') -- S-F11
map('<F29>', function() gdb_cmd('reverse-continue') end, 'Reverse continue') -- C-F5
map('<F34>', function() gdb_cmd('reverse-next') end, 'Reverse step over') -- C-F10
map('<F35>', function() gdb_cmd('reverse-step') end, 'Reverse step into') -- C-F11
map('<F47>', function() gdb_cmd('reverse-finish') end, 'Reverse step out') -- C-S-F11
map('<leader>dt', debug_test, '[D]ebug [T]est at cursor')
map('<leader>du', dapui.toggle, 'Toggle [D]ebug [U]I')
map('<leader>de', dapui.eval, '[D]ebug [E]valuate', { 'n', 'x' })
