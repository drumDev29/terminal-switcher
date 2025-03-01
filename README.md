# Terminal Switcher

A minimal Neovim plugin that lets you switch between toggleterm instances using the snacks picker.

## Requirements

- Neovim >= 0.7.0
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)
- [snacks.nvim](https://github.com/creativenull/snacks.nvim)

## Installation

### Using packer.nvim

```lua
use {
  'drumDev29/terminal-switcher',
  requires = {
    'akinsho/toggleterm.nvim',
    'creativenull/snacks.nvim'
  }
}
```

### Using lazy.nvim

```lua
{
  'drumDev29/terminal-switcher',
  dependencies = {
    'akinsho/toggleterm.nvim',
    'creativenull/snacks.nvim'
  }
}
```

## Usage

The plugin provides a simple API to create and manage terminal instances, and a picker to switch between them:

```lua
local ts = require('terminal-switcher')

-- Create a new terminal
local id1 = ts.create_terminal("Git", "git status")
local id2 = ts.create_terminal("Node REPL", "node")
local id3 = ts.create_terminal("Bash", nil, { dir = "~/" })

-- Toggle a specific terminal
ts.toggle_terminal(id1)

-- Open the picker to switch between terminals
ts.pick_terminal()

-- Optional: Set up a keybinding for the picker
ts.setup_keybinding('<leader>ts')  -- Default is <leader>ts
```

The plugin also provides a command:

- `:TerminalSwitch` - Open the snacks picker to switch between terminals

## Example Configuration

```lua
local ts = require('terminal-switcher')

-- Create a set of terminal instances at startup
ts.create_terminal("Git", "git status", { dir = vim.fn.getcwd() })
ts.create_terminal("Node REPL", "node")
ts.create_terminal("Python REPL", "python")
ts.create_terminal("Shell", nil)

-- Set up a keybinding for quick access
ts.setup_keybinding('<leader>tt')

-- Add your own keybindings for specific terminals
vim.keymap.set('n', '<leader>tg', function()
  ts.toggle_terminal(1)  -- Toggle the Git terminal
end, { desc = 'Toggle Git terminal' })
```

## License

MIT