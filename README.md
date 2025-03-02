# Terminal Switcher

A minimal Neovim plugin for switching between toggleterm instances. Works automatically with existing toggleterm terminals without requiring manual registration.

## Requirements

- Neovim >= 0.7.0
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim)

## Installation

```lua
-- lazy.nvim
{
  'drumDev29/terminal-switcher',
  dependencies = {
    'akinsho/toggleterm.nvim',
    'folke/snacks.nvim'
  },
  config = function()
    require('terminal-switcher').setup()
  end
}
```

## Usage

The plugin automatically works with existing toggleterm terminals. Just press the keybinding (default: `<leader>ts`) to open the picker and select a terminal.

```lua
local ts = require('terminal-switcher')

-- Open the picker to switch between terminals
ts.pick_terminal()

-- Optional: Create named terminals for specific tasks
local git_term = ts.create_terminal("Git", "git status", { dir = vim.fn.getcwd() })
local node_term = ts.create_terminal("Node", "node")

-- Toggle a specific terminal by ID
ts.toggle_terminal(git_term)
```

The plugin also provides the `:TerminalSwitch` command.

## Configuration

```lua
require('terminal-switcher').setup({
  -- Default keybinding to open terminal picker
  keybinding = '<leader>ts',
  -- Automatically set up the keybinding
  setup_keybinding = true,
})
```

## License

MIT