-- unsaved_changes.lua
-- Optimized plugin to highlight unsaved changes (Kate-style)

local api = vim.api

local snapshots = {}
local placed_signs = {}
local last_changed_lines = {}
local update_timers = {}

-- Define highlight groups once with better performance
local function setup_highlights()
  api.nvim_set_hl(0, "UnsavedChangeHL", { 
    default = true, 
    fg = "#ffc777", 
    bg = "NONE" 
  })
  api.nvim_set_hl(0, "SavedHL", { 
    default = true, 
    fg = "#40a02b", 
    bg = "NONE" 
  })
  api.nvim_set_hl(0, "DeleteHL", { 
    default = true, 
    fg = "#7287fd", 
    bg = "NONE" 
  })
end

-- Setup signs once
local function setup_signs()
  vim.fn.sign_define("UnsavedAdd", { 
    text = "┃", 
    texthl = "UnsavedChangeHL" 
  })
  vim.fn.sign_define("UnsavedChange", { 
    text = "┃", 
    texthl = "UnsavedChangeHL" 
  })
  vim.fn.sign_define("UnsavedDelete", { 
    text = "_", 
    texthl = "DeleteHL" 
  })
  vim.fn.sign_define("UnsavedSaved", { 
    text = "┃", 
    texthl = "SavedHL" 
  })
end

-- Optimized sign clearing
local function clear_signs(bufnr)
  if placed_signs[bufnr] and #placed_signs[bufnr] > 0 then
    vim.fn.sign_unplace("unsaved_changes", { buffer = bufnr })
    placed_signs[bufnr] = {}
  end
end

-- Batch sign placement for better performance
local sign_id_counter = 1
local function place_signs_batch(bufnr, signs_to_place)
  if not signs_to_place or #signs_to_place == 0 then
    return
  end
  
  placed_signs[bufnr] = placed_signs[bufnr] or {}
  
  for _, sign_info in ipairs(signs_to_place) do
    local id = sign_id_counter
    sign_id_counter = sign_id_counter + 1
    vim.fn.sign_place(id, "unsaved_changes", sign_info.name, bufnr, { 
      lnum = sign_info.lnum 
    })
    table.insert(placed_signs[bufnr], id)
  end
end

-- Optimized buffer validation
local function is_valid_buffer(bufnr)
  return api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == ""
end

local function save_snapshot(bufnr)
  if not is_valid_buffer(bufnr) then
    return
  end
  
  snapshots[bufnr] = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  clear_signs(bufnr)
  
  -- Show saved indicators for previously changed lines
  if last_changed_lines[bufnr] then
    local saved_signs = {}
    for lnum, _ in pairs(last_changed_lines[bufnr]) do
      table.insert(saved_signs, { name = "UnsavedSaved", lnum = lnum })
    end
    place_signs_batch(bufnr, saved_signs)
    
    -- Clear saved indicators after a delay
    vim.defer_fn(function()
      if is_valid_buffer(bufnr) then
        clear_signs(bufnr)
      end
    end, 2000)
    
    last_changed_lines[bufnr] = nil
  end
end

-- Optimized diff calculation with early returns
local function update_diff(bufnr)
  if not is_valid_buffer(bufnr) then
    return
  end

  -- Initialize snapshot if needed
  if not snapshots[bufnr] then
    snapshots[bufnr] = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    return
  end

  local current = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local original = snapshots[bufnr]

  -- Early return for empty buffers
  if #current == 0 and #original == 0 then
    clear_signs(bufnr)
    last_changed_lines[bufnr] = nil
    return
  end

  -- Quick comparison for identical content
  if #current == #original then
    local identical = true
    for i = 1, #current do
      if current[i] ~= original[i] then
        identical = false
        break
      end
    end
    if identical then
      clear_signs(bufnr)
      last_changed_lines[bufnr] = nil
      return
    end
  end

  -- Prepare strings for diff
  local current_str = #current > 0 and (table.concat(current, "\n") .. "\n") or ""
  local original_str = #original > 0 and (table.concat(original, "\n") .. "\n") or ""

  local hunks = vim.diff(original_str, current_str, { 
    result_type = "indices",
    algorithm = "myers" -- Explicitly use Myers algorithm for consistency
  })

  clear_signs(bufnr)
  last_changed_lines[bufnr] = {}
  
  local signs_to_place = {}

  for _, hunk in ipairs(hunks) do
    local orig_start, orig_count, new_start, new_count = unpack(hunk)
    
    if orig_count == 0 and new_count > 0 then
      -- Added lines
      for i = new_start, math.min(new_start + new_count - 1, #current) do
        table.insert(signs_to_place, { name = "UnsavedAdd", lnum = i })
        last_changed_lines[bufnr][i] = true
      end
    elseif new_count == 0 and orig_count > 0 then
      -- Deleted lines
      local lnum = math.max(1, math.min(new_start, #current > 0 and #current or 1))
      table.insert(signs_to_place, { name = "UnsavedDelete", lnum = lnum })
      last_changed_lines[bufnr][lnum] = true
    elseif new_count > 0 and orig_count > 0 then
      -- Modified lines
      for i = new_start, math.min(new_start + new_count - 1, #current) do
        table.insert(signs_to_place, { name = "UnsavedChange", lnum = i })
        last_changed_lines[bufnr][i] = true
      end
    end
  end
  
  place_signs_batch(bufnr, signs_to_place)
end

-- Debounced update function
local function schedule_update(bufnr)
  -- Cancel existing timer
  if update_timers[bufnr] then
    update_timers[bufnr]:stop()
  end
  
  -- Schedule new update
  update_timers[bufnr] = vim.defer_fn(function()
    update_timers[bufnr] = nil
    if is_valid_buffer(bufnr) then
      update_diff(bufnr)
    end
  end, 150) -- Slightly longer delay for better performance
end

-- Initialize buffer with validation
local function init_buffer(bufnr)
  if api.nvim_buf_is_loaded(bufnr) and is_valid_buffer(bufnr) then
    snapshots[bufnr] = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  end
end

-- Cleanup function
local function cleanup_buffer(bufnr)
  snapshots[bufnr] = nil
  placed_signs[bufnr] = nil
  last_changed_lines[bufnr] = nil
  if update_timers[bufnr] then
    update_timers[bufnr]:stop()
    update_timers[bufnr] = nil
  end
end

-- Setup function
local function setup()
  setup_highlights()
  setup_signs()
  
  local augroup = api.nvim_create_augroup("UnsavedChanges", { clear = true })

  api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    callback = function(args) 
      init_buffer(args.buf)
    end,
  })

  api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    callback = function(args) 
      save_snapshot(args.buf) 
    end,
  })

  api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = augroup,
    callback = function(args) 
      schedule_update(args.buf)
    end,
  })

  api.nvim_create_autocmd("BufDelete", {
    group = augroup,
    callback = function(args)
      cleanup_buffer(args.buf)
    end,
  })
  
  -- Handle colorscheme changes
  api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = function()
      setup_highlights()
    end,
  })

  -- Initialize existing buffers
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    init_buffer(bufnr)
  end
end

-- Debug commands (only if debug is enabled)
if vim.g.unsaved_changes_debug then
  vim.api.nvim_create_user_command("UnsavedDebug", function()
    local bufnr = api.nvim_get_current_buf()
    print("Buffer:", bufnr)
    print("Valid:", is_valid_buffer(bufnr))
    print("Snapshot lines:", snapshots[bufnr] and #snapshots[bufnr] or "none")
    print("Current lines:", #api.nvim_buf_get_lines(bufnr, 0, -1, false))
    print("Placed signs:", placed_signs[bufnr] and #placed_signs[bufnr] or 0)
    print("Active timer:", update_timers[bufnr] ~= nil)
  end, {})
  
  vim.api.nvim_create_user_command("UnsavedClear", function()
    local bufnr = api.nvim_get_current_buf()
    clear_signs(bufnr)
  end, {})
  
  vim.api.nvim_create_user_command("UnsavedRefresh", function()
    local bufnr = api.nvim_get_current_buf()
    update_diff(bufnr)
  end, {})
end

-- Auto-setup
setup()

-- Export for manual setup if needed
return { setup = setup }