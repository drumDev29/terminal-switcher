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

-- Generate a preview of terminal content - empty if not found
local function terminal_preview(terminal)
  if not terminal or not terminal.bufnr or not vim.api.nvim_buf_is_valid(terminal.bufnr) then
    -- Return empty preview if no content
    return { text = "", ft = "text" }
  end
  
  -- Get terminal content
  local lines = vim.api.nvim_buf_get_lines(terminal.bufnr, 0, -1, false)
  if #lines == 0 then
    -- Return empty preview if no content
    return { text = "", ft = "text" }
  end
  
  -- Return content
  return { text = table.concat(lines, "\n"), ft = "terminal" }
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
  
  -- Setup creation action
  local function create_new_terminal(picker)
    picker:close()
    vim.ui.input({ prompt = "Terminal name: " }, function(name)
      if not name or name == "" then return end
      
      vim.ui.input({ prompt = "Command (optional): " }, function(cmd)
        local id = M.create_terminal(name, cmd ~= "" and cmd or nil)
        if id then
          vim.schedule(function() 
            M.toggle_terminal(id)
            vim.notify("Terminal '" .. name .. "' created with ID " .. id)
          end)
        end
      end)
    end)
  end
  
  -- Setup delete action
  local function delete_terminal(picker)
    local item = picker:current()
    if item and item.id then
      picker:close()
      vim.ui.input({
        prompt = "Delete terminal '" .. item.text .. "'? (y/N): "
      }, function(input)
        if input and (input:lower() == "y" or input:lower() == "yes") then
          M.delete_terminal(item.id)
          vim.notify("Terminal deleted")
        end
      end)
    end
  end
  
  -- No terminals to show - Ask to create one
  if vim.tbl_isempty(all_terms) then
    vim.ui.input({
      prompt = "No terminals available. Create one? (y/N): "
    }, function(input)
      if input and (input:lower() == "y" or input:lower() == "yes") then
        create_new_terminal({ close = function() end })
      end
    end)
    return
  end
  
  -- Create simple array of selectable items
  local term_items = {}
  local term_data = {}  -- Map for lookup by index
  
  for id, term in pairs(all_terms) do
    table.insert(term_items, id .. ": " .. term.name)
    term_data[#term_items] = term
  end
  
  -- Sort items by terminal ID
  table.sort(term_items, function(a, b)
    local id_a = tonumber(string.match(a, "^(%d+):"))
    local id_b = tonumber(string.match(b, "^(%d+):"))
    return id_a < id_b
  end)
  
  -- Determine if we use vim.ui.select or snacks
  local use_ui_select = not snacks or not snacks.picker
  
  -- Try to use snacks picker with simpler approach
  if not use_ui_select then
    local items = {}
    for i, text in ipairs(term_items) do
      table.insert(items, {
        text = text,
        terminal = term_data[i].instance,
        preview = function()
          return terminal_preview(term_data[i].instance)
        end
      })
    end
    
    -- Use a more direct approach with snacks
    snacks.picker.pick({
      items = items,
      prompt = "⚡ Terminal",
      preview = "preview", -- Use the preview function
      format = function(item)
        return {{item.text}}
      end,
      confirm = function(picker, item)
        picker:close()
        if item and item.terminal then
          item.terminal:toggle()
        end
      end,
      actions = {
        add_terminal = function(picker)
          create_new_terminal(picker)
        end,
        delete_terminal = function(picker)
          delete_terminal(picker)
        end
      },
      win = {
        list = {
          keys = {
            ["a"] = "add_terminal",
            ["x"] = "delete_terminal"
          }
        }
      }
    })
  else
    -- Fallback to vim.ui.select which is guaranteed to work
    vim.ui.select(term_items, {
      prompt = "Select Terminal:",
      format_item = function(item) return item end
    }, function(choice, idx)
      if idx and term_data[idx] and term_data[idx].instance then
        term_data[idx].instance:toggle()
      end
    end)
    
    -- Let user know they can enhance the experience
    vim.notify("Using basic selector. Install 'folke/snacks.nvim' for enhanced picker with previews.", vim.log.levels.INFO)
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