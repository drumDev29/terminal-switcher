-- Terminal Switcher plugin file

if vim.fn.has('nvim-0.7.0') == 0 then
  vim.api.nvim_err_writeln("terminal-switcher requires at least nvim-0.7.0")
  return
end

-- Simple command to open the terminal switcher
vim.api.nvim_create_user_command('TerminalSwitch', function()
  require('terminal-switcher').pick_terminal()
end, {desc = 'Switch between terminals using picker'})