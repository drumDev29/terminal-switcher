-- Terminal Switcher
-- A simple plugin to manage toggleterm instances with snacks picker

local M = {}

-- Default configuration
local default_config = {
  -- Default keybinding to open terminal picker
  keybinding = '<leader>ts',
  -- Automatically set up the keybinding
  setup_keybinding = true,
}

-- Plugin configuration
local config = vim.deepcopy(default_config)

-- Store all terminal instances
local terminals = {}

-- Create a new toggleterm instance and add to our list
function M.create_terminal(name, cmd, opts)
  -- Check if toggleterm is available
  local ok, toggleterm = pcall(require, "toggleterm.terminal")
  if not ok then
    vim.notify("toggleterm.nvim is required", vim.log.levels.ERROR)
    return nil
  end
  
  -- Default options
  opts = opts or {}
  opts.hidden = true
  
  -- Set terminal ID
  local id = #terminals + 1
  opts.id = id
  
  -- Create terminal instance
  local term = toggleterm.Terminal:new(opts)
  
  -- Store terminal with metadata
  terminals[id] = {
    id = id,
    name = name or ("Terminal " .. id),
    cmd = cmd,
    instance = term
  }
  
  return id
end

-- Toggle a specific terminal by ID
function M.toggle_terminal(id)
  if terminals[id] and terminals[id].instance then
    terminals[id].instance:toggle()
  else
    vim.notify("Terminal " .. id .. " does not exist", vim.log.levels.ERROR)
  end
end

-- Show snacks picker to select and toggle terminal
function M.pick_terminal()
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("snacks.nvim is required", vim.log.levels.ERROR)
    return
  end
  
  -- Build list of terminals for picker
  local items = {}
  for id, term in pairs(terminals) do
    table.insert(items, {
      id = id,
      text = id .. ": " .. term.name,
      value = id
    })
  end
  
  -- No terminals to show
  if #items == 0 then
    vim.notify("No terminals available", vim.log.levels.INFO)
    return
  end
  
  -- Open snacks picker
  snacks.select({
    prompt = "Switch Terminal",
    items = items,
    on_select = function(item)
      if item then
        M.toggle_terminal(item.value)
      end
    end
  })
end

-- List all terminal instances
function M.list_terminals()
  return terminals
end

-- Delete a terminal instance
function M.delete_terminal(id)
  if terminals[id] then
    terminals[id] = nil
  end
end

-- Set a keybinding to open the terminal picker
function M.setup_keybinding(mapping)
  vim.keymap.set('n', mapping or '<leader>ts', M.pick_terminal, { 
    silent = true, 
    noremap = true,
    desc = "Open terminal switcher" 
  })
end

-- Setup function to initialize the plugin with configuration
function M.setup(opts)
  -- Update config with user options
  opts = opts or {}
  config = vim.tbl_deep_extend("force", default_config, opts)
  
  -- Set up keybinding if configured
  if config.setup_keybinding then
    M.setup_keybinding(config.keybinding)
  end
end

return M