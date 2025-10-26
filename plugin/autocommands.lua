vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end
})

vim.api.nvim_create_user_command('MakeGS', function(tbl)
  local session_path = vim.fn.stdpath('data') .. '/session/' .. tbl.fargs[1] .. '.vim'
  print(session_path)
  vim.cmd('mksession ' .. session_path)
  print('Session saved as: ' .. session_path)
end, { nargs=1 })

vim.api.nvim_create_user_command('DelGS', function(tbl)
  local session_path = vim.fn.stdpath('data') .. '/session/' .. tbl.fargs[1] .. '.vim'
  print(session_path)
  vim.cmd(': !rm ' .. session_path)
  print('Session deleted: ' .. session_path)
end, { nargs=1 })
