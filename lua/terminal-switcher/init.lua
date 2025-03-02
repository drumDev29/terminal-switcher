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

-- Get all available terminals (both custom and toggleterm instances)
local function get_all_terminals()
  local ok, toggleterm = pcall(require, "toggleterm.terminal")
  if not ok then
    vim.notify("toggleterm.nvim is required", vim.log.levels.ERROR)
    return {}
  end
  
  local all_terms = {}
  
  -- First, add our manually registered terminals
  for id, term in pairs(terminals) do
    all_terms[id] = term
  end
  
  -- Then, check for any toggleterm terminals we haven't registered
  if toggleterm and toggleterm.get_all then
    local tt_terms = toggleterm.get_all()
    for _, term in pairs(tt_terms) do
      local term_id = term.id
      
      -- Only add if we don't already have it registered
      if not all_terms[term_id] then
        all_terms[term_id] = {
          id = term_id,
          name = "Terminal " .. term_id,
          cmd = term.cmd or "",
          instance = term
        }
      end
    end
  end
  
  return all_terms
end

-- Toggle a specific terminal by ID
function M.toggle_terminal(id)
  local all_terms = get_all_terminals()
  
  if all_terms[id] and all_terms[id].instance then
    all_terms[id].instance:toggle()
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
  
  -- Get all terminals (including toggleterm instances)
  local all_terms = get_all_terminals()
  
  -- No terminals to show
  if vim.tbl_isempty(all_terms) then
    vim.notify("No terminals available", vim.log.levels.INFO)
    return
  end
  
  -- Create simple string items for picker to avoid concatenation issues
  local term_strings = {}
  local term_lookup = {}
  local index = 1
  
  for id, term in pairs(all_terms) do
    -- Create a simple string for display
    local display_text = tostring(id) .. ": " .. term.name
    term_strings[index] = display_text
    term_lookup[display_text] = term
    index = index + 1
  end
  
  -- Sort strings numerically by terminal ID
  table.sort(term_strings, function(a, b)
    local id_a = tonumber(string.match(a, "^(%d+):"))
    local id_b = tonumber(string.match(b, "^(%d+):"))
    return id_a < id_b
  end)
  
  -- Use picker with simple strings to avoid table concatenation
  if snacks.picker and snacks.picker.pick then
    snacks.picker.pick(term_strings, {
      prompt = "Switch Terminal",
    }, function(selected)
      if selected and term_lookup[selected] and term_lookup[selected].instance then
        term_lookup[selected].instance:toggle()
      end
    end)
  else
    vim.notify("Unsupported snacks.nvim API. Please ensure you're using the correct version", vim.log.levels.ERROR)
  end
end

-- List all terminal instances (both custom and toggleterm instances)
function M.list_terminals()
  return get_all_terminals()
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