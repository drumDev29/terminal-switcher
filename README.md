# Terminal Switcher

A minimal Neovim plugin that lets you switch between toggleterm instances using the snacks picker.

## Requirements

- Neovim >= 0.7.0
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim)

## Installation

### Using packer.nvim

```lua
use {
  'drumDev29/terminal-switcher',
  requires = {
    'akinsho/toggleterm.nvim',
    'folke/snacks.nvim'
  },
  config = function()
    require('terminal-switcher').setup()
  end
}
```

### Using lazy.nvim

```lua
{
  'drumDev29/terminal-switcher',
  dependencies = {
    'akinsho/toggleterm.nvim',
    'folke/snacks.nvim'
  },
  config = function()
    require('terminal-switcher').setup({
      -- Default configuration
      keybinding = '<leader>ts',
      setup_keybinding = true,
    })
  end
}
```

## Usage

First, set up the plugin (if not using lazy.nvim's config option):

```lua
require('terminal-switcher').setup()
```

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

-- Note: A keybinding is set up by default when you call setup()
-- You can also manually set up a keybinding:
-- ts.setup_keybinding('<leader>ts')
```

The plugin also provides a command:

- `:TerminalSwitch` - Open the snacks picker to switch between terminals

## Configuration

The plugin comes with the following default configuration:

```lua
{
  -- Default keybinding to open terminal picker
  keybinding = '<leader>ts',
  -- Automatically set up the keybinding
  setup_keybinding = true,
}
```

### Example Configuration

```lua
-- Setup with custom configuration
require('terminal-switcher').setup({
  keybinding = '<leader>tt',
  setup_keybinding = true,
})

local ts = require('terminal-switcher')

-- Create a set of terminal instances at startup
ts.create_terminal("Git", "git status", { dir = vim.fn.getcwd() })
ts.create_terminal("Node REPL", "node")
ts.create_terminal("Python REPL", "python")
ts.create_terminal("Shell", nil)

-- Add your own keybindings for specific terminals
vim.keymap.set('n', '<leader>tg', function()
  ts.toggle_terminal(1)  -- Toggle the Git terminal
end, { desc = 'Toggle Git terminal' })
```

## License

MIT