-- ~/.config/nvim/lua/config/autocommands.lua

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Disable line numbers in terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end
})

-- Custom user command: Save session (MakeGS)
vim.api.nvim_create_user_command('MakeGS', function(tbl)
  local session_path = vim.fn.stdpath('data') .. '/session/' .. tbl.fargs[1] .. '.vim'
  print(session_path)
  vim.cmd('mksession ' .. session_path)
  print('Session saved as: ' .. session_path)
end, { nargs=1 })

-- Custom user command: Wipe registers (WipeRegs)
vim.api.nvim_create_user_command('WipeRegs', function()
  local regs = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
                  'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
                  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '+', '/' }
  for i = 1, #regs do
    vim.fn.setreg(regs[i], {})
  end
  vim.cmd('wshada!')
end, { nargs=0 })

