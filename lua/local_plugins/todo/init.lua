-- File: ~/.config/nvim/lua/todo/init.lua
local M = {}

-- Constants
local SECONDS_PER_DAY = 86400

-- Default Configuration
local default_config = {
	todo_file = vim.fn.stdpath("data") .. "/todo/todos.json",
	backup_file = vim.fn.stdpath("data") .. "/todo/todos.backup.json",
	max_display = 5,
	menu_width = 60,
	menu_max_width = 80,
	text_display_length = 35,
	text_truncate_length = 32,
	auto_backup = true,
	date_format = "%Y-%m-%d %H:%M:%S",
	auto_delete_completed_after_24h = false,
	show_stats = true,
	ask_before_delete = true,
	sort_order = "oldest_first", -- "oldest_first" or "newest_first"
	help_text = "x=Toggle, dd=Delete, D=Delete all completed, e=edit, a=add, q=quit",
}

-- Configuration
M.config = {}

-- Internal state
local todos = {}
local current_menu = nil

-- Utility functions
local function log(message, level)
	vim.notify("[Todo] " .. message, level or vim.log.levels.INFO)
end

local function validate_config()
	if M.config.text_truncate_length >= M.config.text_display_length then
		log("Warning: text_truncate_length should be less than text_display_length", vim.log.levels.WARN)
		M.config.text_truncate_length = M.config.text_display_length - 3
	end

	if M.config.max_display < 1 then
		M.config.max_display = 1
	end

	if M.config.sort_order ~= "oldest_first" and M.config.sort_order ~= "newest_first" then
		log("Invalid sort_order, defaulting to 'oldest_first'", vim.log.levels.WARN)
		M.config.sort_order = "oldest_first"
	end
end

local function truncate_text(text, max_length, truncate_length)
	if not text then
		return ""
	end

	if vim.fn.strwidth(text) > max_length then
		return string.sub(text, 1, truncate_length) .. "..."
	end
	return text
end

local function create_backup()
	if not M.config.auto_backup then
		return
	end

	local todo_file = io.open(M.config.todo_file, "r")
	if todo_file then
		local content = todo_file:read("*all")
		todo_file:close()

		if content and content ~= "" then
			local backup_file = io.open(M.config.backup_file, "w")
			if backup_file then
				backup_file:write(content)
				backup_file:close()
			end
		end
	end
end

-- Deep extend utility
local function deep_extend(target, source)
	for k, v in pairs(source) do
		if type(v) == "table" and type(target[k]) == "table" then
			deep_extend(target[k], v)
		else
			target[k] = v
		end
	end
	return target
end

-- Filter function
local function filter_todos(predicate)
	local result = {}
	for _, todo in ipairs(todos) do
		if predicate(todo) then
			table.insert(result, todo)
		end
	end
	return result
end

local function sort_todos()
	-- Sort order:
	-- 1) Pending tasks first (always)
	-- 2) Sort by created time based on config (oldest_first or newest_first)
	-- 3) Text alphabetical as tiebreaker
	table.sort(todos, function(a, b)
		-- Pending always comes before completed
		if a.done ~= b.done then
			return not a.done
		end

		local a_created = a.created or 0
		local b_created = b.created or 0

		-- Apply configured sort order for creation time
		if a_created ~= b_created then
			if M.config.sort_order == "newest_first" then
				return a_created > b_created
			else -- oldest_first (default)
				return a_created < b_created
			end
		end

		-- Alphabetical tiebreaker
		local a_text = (a.text or ""):lower()
		local b_text = (b.text or ""):lower()
		return a_text < b_text
	end)
end

-- File operations
local function load_todos()
	local file = io.open(M.config.todo_file, "r")
	if not file then
		todos = {}
		return
	end

	local content = file:read("*all")
	file:close()

	if not content or content == "" then
		todos = {}
		return
	end

	local ok, data = pcall(vim.json.decode, content)
	if ok and type(data) == "table" then
		todos = data
		-- Ensure all todos have required fields
		for i, todo in ipairs(todos) do
			if not todo.created then
				todo.created = os.time()
			end
			if not todo.id then
				todo.id = tostring(os.time()) .. "_" .. i
			end
			if todo.done == nil then
				todo.done = false
			end
		end
	else
		log("Failed to parse todo file, attempting backup restore...", vim.log.levels.WARN)
		-- Try to load backup
		local backup_file = io.open(M.config.backup_file, "r")
		if backup_file then
			local backup_content = backup_file:read("*all")
			backup_file:close()

			local backup_ok, backup_data = pcall(vim.json.decode, backup_content)
			if backup_ok and type(backup_data) == "table" then
				todos = backup_data
				log("Successfully restored from backup", vim.log.levels.INFO)
				return
			end
		end

		log("Could not restore from backup, starting with empty list", vim.log.levels.WARN)
		todos = {}
	end
end

local function save_todos()
	-- Ensure parent directory exists
	local parent_dir = vim.fn.fnamemodify(M.config.todo_file, ":h")
	vim.fn.mkdir(parent_dir, "p")

	local ok, encoded = pcall(vim.json.encode, todos)
	if not ok then
		log("Failed to encode todos for saving", vim.log.levels.ERROR)
		return false
	end

	local file = io.open(M.config.todo_file, "w")
	if not file then
		log("Failed to open todo file for writing", vim.log.levels.ERROR)
		return false
	end

	file:write(encoded)
	file:close()

	-- Create backup after successful save
	create_backup()

	return true
end

-- Prune completed tasks older than 24 hours (only called on load)
local function prune_completed_tasks()
	if not M.config.auto_delete_completed_after_24h then
		return false
	end

	local now = os.time()
	local kept = {}
	local pruned_count = 0

	for _, todo in ipairs(todos) do
		local should_keep = true

		if todo.done then
			local completion_time = todo.completed_at or todo.modified or todo.created or 0
			local age_seconds = now - completion_time

			if age_seconds >= SECONDS_PER_DAY then
				should_keep = false
				pruned_count = pruned_count + 1
			end
		end

		if should_keep then
			table.insert(kept, todo)
		end
	end

	if pruned_count > 0 then
		todos = kept
		save_todos()
		log(string.format("Auto-pruned %d completed task(s) older than 24 hours", pruned_count))
	end

	return pruned_count > 0
end

-- Todo management functions
local function generate_todo_id()
	-- Use timestamp with higher precision and random component
	return string.format("%d_%d_%d", os.time(), vim.loop.hrtime(), math.random(10000, 99999))
end

-- Public API

-- Add a new todo
function M.add(text)
	if not text or vim.trim(text) == "" then
		return false
	end

	local new_todo = {
		id = generate_todo_id(),
		text = vim.trim(text),
		done = false,
		created = os.time(),
		created_str = os.date(M.config.date_format),
	}

	table.insert(todos, new_todo)
	sort_todos()
	save_todos()
	return true
end

-- Toggle todo completion
function M.toggle(index)
	if todos[index] then
		local was_done = todos[index].done
		todos[index].done = not todos[index].done
		todos[index].modified = os.time()

		-- Record completion time for auto-delete feature
		if todos[index].done and not was_done then
			todos[index].completed_at = os.time()
		elseif not todos[index].done and was_done then
			todos[index].completed_at = nil
		end

		sort_todos()
		save_todos()
		return true
	end
	return false
end

-- Remove todo
function M.remove(index)
	if todos[index] then
		table.remove(todos, index)
		save_todos()
		return true
	end
	return false
end

-- Edit todo text
function M.edit(index, new_text)
	if todos[index] and new_text and vim.trim(new_text) ~= "" then
		todos[index].text = vim.trim(new_text)
		todos[index].modified = os.time()
		save_todos()
		return true
	end
	return false
end

-- Get todos with filtering
function M.list(filter_type)
	if filter_type == "done" then
		return filter_todos(function(todo)
			return todo.done
		end)
	elseif filter_type == "pending" then
		return filter_todos(function(todo)
			return not todo.done
		end)
	end
	return vim.deepcopy(todos)
end

-- Get completion stats
function M.stats()
	local done = 0
	for _, todo in ipairs(todos) do
		if todo.done then
			done = done + 1
		end
	end
	local total = #todos
	local pending = total - done
	local completion_rate = total > 0 and math.floor((done / total) * 100) or 0

	return {
		done = done,
		pending = pending,
		total = total,
		completion_rate = completion_rate,
	}
end

-- Get formatted display lines for dashboard
function M.display(max_items)
	max_items = max_items or M.config.max_display

	if #todos == 0 then
		return { "No tasks today! :)" }
	end

	local lines = {}
	local shown = 0

	for i, todo in ipairs(todos) do
		if shown >= max_items then
			local remaining = #todos - shown
			table.insert(lines, string.format("... and %d more", remaining))
			break
		end

		local icon = todo.done and "✓" or "○"
		local text = truncate_text(todo.text, M.config.text_display_length, M.config.text_truncate_length)

		table.insert(lines, string.format("%s %s", icon, text))
		shown = shown + 1
	end

	return lines
end

-- Menu state management
local function close_menu()
	if current_menu and current_menu.win_id and vim.api.nvim_win_is_valid(current_menu.win_id) then
		vim.api.nvim_win_close(current_menu.win_id, true)
	end
	current_menu = nil
end

local function get_task_index_from_line(line_num)
	local stats_lines = M.config.show_stats and 2 or 0
	if line_num <= stats_lines or #todos == 0 then
		return nil
	end
	local task_index = line_num - stats_lines
	return (task_index <= #todos) and task_index or nil
end

local function validate_cursor_position(current_line)
	local stats_lines = M.config.show_stats and 2 or 0
	local first_task_line = stats_lines + 1

	if #todos == 0 then
		return 1
	end
	return math.max(first_task_line, math.min(current_line, #todos + stats_lines))
end

local function get_relative_time(timestamp)
	local now = os.time()
	local diff = now - timestamp

	if diff < 60 then
		return "just now"
	elseif diff < 3600 then
		local mins = math.floor(diff / 60)
		return string.format("%dm ago", mins)
	elseif diff < SECONDS_PER_DAY then
		local hours = math.floor(diff / 3600)
		return string.format("%dh ago", hours)
	else
		local days = math.floor(diff / SECONDS_PER_DAY)
		return string.format("%dd ago", days)
	end
end

local function build_menu_lines()
	local lines = {}

	if M.config.show_stats then
		local stats = M.stats()
		table.insert(
			lines,
			string.format("📋 Tasks: %d/%d completed (%d%%)", stats.done, stats.total, stats.completion_rate)
		)
		table.insert(lines, "")
	end

	if #todos == 0 then
		table.insert(lines, "✨ No tasks - press 'a' to add one")
	else
		for i, todo in ipairs(todos) do
			local icon = todo.done and "[✓]" or "[ ]"
			local text = truncate_text(todo.text, M.config.menu_width - 10, M.config.menu_width - 15)
			local time_info = ""

			if todo.created then
				time_info = " " .. get_relative_time(todo.created)
			end

			table.insert(lines, string.format("  %s %s%s", icon, text, time_info))
		end
	end

	table.insert(lines, "")
	table.insert(lines, M.config.help_text)

	return lines
end

local function refresh_menu_content()
	if not current_menu or not current_menu.buf or not vim.api.nvim_buf_is_valid(current_menu.buf) then
		return false
	end

	local lines = build_menu_lines()

	-- Update buffer content
	vim.bo[current_menu.buf].modifiable = true
	vim.api.nvim_buf_set_lines(current_menu.buf, 0, -1, false, lines)
	vim.bo[current_menu.buf].modifiable = false

	-- Validate and update cursor position
	current_menu.current_line = validate_cursor_position(current_menu.current_line)

	if vim.api.nvim_win_is_valid(current_menu.win_id) then
		vim.api.nvim_win_set_cursor(current_menu.win_id, { current_menu.current_line, 2 })

		-- Clear previous highlights
		vim.api.nvim_buf_clear_namespace(current_menu.buf, -1, 0, -1)

		-- Highlight current line if we have tasks
		local stats_lines = M.config.show_stats and 2 or 0
		if #todos > 0 and current_menu.current_line > stats_lines then
			vim.api.nvim_buf_add_highlight(current_menu.buf, -1, "Visual", current_menu.current_line - 1, 0, -1)
		end
	end

	return true
end

-- Create floating window
local function create_floating_window(lines, opts)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local win_opts = {
		relative = "editor",
		width = opts.width,
		height = opts.height,
		col = opts.col,
		row = opts.row,
		border = "rounded",
		title = opts.title,
		title_pos = "center",
		style = "minimal",
	}

	local win = vim.api.nvim_open_win(buf, true, win_opts)
	return win, buf
end

-- Setup key mappings for menu
local function setup_menu_keymaps(buf)
	local function map(key, fn, desc)
		vim.keymap.set("n", key, fn, { buffer = buf, silent = true, desc = desc })
	end

	local function get_current_task()
		if not current_menu then
			return nil
		end
		return get_task_index_from_line(current_menu.current_line)
	end

	local function move_cursor(direction)
		if #todos == 0 or not current_menu then
			return
		end

		local stats_lines = M.config.show_stats and 2 or 0
		local new_line = current_menu.current_line

		if direction == "down" then
			new_line = math.min(current_menu.current_line + 1, #todos + stats_lines)
		elseif direction == "up" then
			new_line = math.max(current_menu.current_line - 1, stats_lines + 1)
		end

		if new_line ~= current_menu.current_line and new_line > stats_lines and new_line <= #todos + stats_lines then
			current_menu.current_line = new_line
			refresh_menu_content()
		end
	end

	-- Navigation
	map("j", function()
		move_cursor("down")
	end, "Move down")
	map("k", function()
		move_cursor("up")
	end, "Move up")
	map("<Down>", function()
		move_cursor("down")
	end, "Move down")
	map("<Up>", function()
		move_cursor("up")
	end, "Move up")

	-- Exit
	map("q", close_menu, "Quit")
	map("<Esc>", close_menu, "Quit")

	-- Add new task
	map("a", function()
		vim.ui.input({ prompt = "New task: " }, function(input)
			if input and M.add(input) then
				current_menu.current_line = (M.config.show_stats and 2 or 0) + 1
				refresh_menu_content()
				log("Task added successfully!")
			end
		end)
	end, "Add new task")

	-- Toggle task completion
	map("x", function()
		local task_idx = get_current_task()
		if task_idx and M.toggle(task_idx) then
			refresh_menu_content()
			local status = todos[task_idx].done and "completed" or "reopened"
			log(string.format("Task %s", status))
		end
	end, "Toggle task")

	-- Delete task
	map("dd", function()
		local task_idx = get_current_task()
		if task_idx and todos[task_idx] then
			local task_text = todos[task_idx].text
			local display_text = truncate_text(task_text, 30, 27)

			local should_delete = true
			if M.config.ask_before_delete then
				local confirm = vim.fn.confirm(string.format('Delete task: "%s"?', display_text), "&Yes\n&No", 2)
				should_delete = confirm == 1
			end

			if should_delete and M.remove(task_idx) then
				local stats_lines = M.config.show_stats and 2 or 0
				if current_menu.current_line > #todos + stats_lines and #todos > 0 then
					current_menu.current_line = #todos + stats_lines
				elseif #todos == 0 then
					current_menu.current_line = 1
				end
				refresh_menu_content()
				log("Task deleted")
			end
		end
	end, "Delete task")

	-- Edit task
	map("e", function()
		local task_idx = get_current_task()
		if task_idx and todos[task_idx] then
			vim.ui.input({
				prompt = "Edit task: ",
				default = todos[task_idx].text,
			}, function(new_text)
				if new_text and M.edit(task_idx, new_text) then
					refresh_menu_content()
					log("Task updated")
				end
			end)
		end
	end, "Edit task")

	-- Delete all completed tasks
	map("D", function()
		local completed = M.list("done")
		if #completed > 0 then
			local should_delete = true
			if M.config.ask_before_delete then
				local confirm =
					vim.fn.confirm(string.format("Delete all %d completed tasks?", #completed), "&Yes\n&No", 2)
				should_delete = confirm == 1
			end

			if should_delete then
				todos = M.list("pending")
				save_todos()
				current_menu.current_line = 1
				refresh_menu_content()
				log(string.format("Deleted %d completed tasks", #completed))
			end
		else
			log("No completed tasks to delete")
		end
	end, "Delete all completed tasks")
end

-- Interactive menu
function M.menu()
	-- Close existing menu if open
	close_menu()

	local lines = build_menu_lines()

	local stats_lines = M.config.show_stats and 2 or 0
	local current_line = #todos > 0 and (stats_lines + 1) or 1

	-- Calculate popup dimensions
	local width = math.max(M.config.menu_width, math.min(M.config.menu_max_width, vim.o.columns - 10))
	local height = math.min(#lines + 2, vim.o.lines - 8)

	-- Create floating window
	local win_id, buf = create_floating_window(lines, {
		title = "   Todo Manager   ",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2 - 1),
	})

	-- Set buffer options
	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "TodoList"
	vim.wo[win_id].cursorline = false
	vim.wo[win_id].number = false
	vim.wo[win_id].relativenumber = false

	-- Store menu state
	current_menu = {
		buf = buf,
		win_id = win_id,
		current_line = validate_cursor_position(current_line),
	}

	-- Set cursor position
	vim.api.nvim_win_set_cursor(win_id, { current_menu.current_line, 2 })

	-- Highlight current line
	if #todos > 0 and current_menu.current_line > stats_lines then
		vim.api.nvim_buf_add_highlight(buf, -1, "Visual", current_menu.current_line - 1, 0, -1)
	end

	-- Setup key mappings
	setup_menu_keymaps(buf)

	-- Handle window close events
	vim.api.nvim_create_autocmd({ "WinClosed", "BufWipeout" }, {
		buffer = buf,
		callback = function()
			current_menu = nil
		end,
		once = true,
	})
end

-- Setup function
function M.setup(opts)
	M.config = deep_extend(vim.deepcopy(default_config), opts or {})
	validate_config()
	load_todos()
	sort_todos()

	-- Run pruning only on plugin load
	prune_completed_tasks()

	-- Create commands
	vim.api.nvim_create_user_command("TodoAdd", function(cmd)
		if cmd.args and M.add(cmd.args) then
			log("Task added!")
		else
			log("Please provide a task description")
		end
	end, {
		nargs = 1,
		desc = "Add a new todo task",
	})

	vim.api.nvim_create_user_command("TodoMenu", M.menu, {
		desc = "Open todo menu",
	})

	vim.api.nvim_create_user_command("TodoList", function(cmd)
		local filter_type = cmd.args ~= "" and cmd.args or nil
		local filtered_todos = M.list(filter_type)
		local stats = M.stats()

		print(string.format("Tasks: %d/%d completed (%d%%)", stats.done, stats.total, stats.completion_rate))
		if #filtered_todos == 0 then
			print("No tasks!")
		else
			for i, todo in ipairs(filtered_todos) do
				local icon = todo.done and "[✓]" or "[ ]"
				local time_info = todo.created and (" " .. get_relative_time(todo.created)) or ""
				print(string.format("%d. %s %s%s", i, icon, todo.text, time_info))
			end
		end
	end, {
		nargs = "?",
		desc = "List all todos",
		complete = function()
			return { "done", "pending" }
		end,
	})

	vim.api.nvim_create_user_command("TodoStats", function()
		local stats = M.stats()
		print(string.format("📊 Todo Statistics:"))
		print(string.format("   Total tasks: %d", stats.total))
		print(string.format("   Completed: %d", stats.done))
		print(string.format("   Pending: %d", stats.pending))
		print(string.format("   Completion rate: %d%%", stats.completion_rate))
	end, { desc = "Show todo statistics" })

	vim.api.nvim_create_user_command("TodoClear", function(cmd)
		local filter_type = cmd.args
		if filter_type == "completed" then
			local completed_count = #M.list("done")

			local should_delete = true
			if M.config.ask_before_delete then
				local confirm = vim.fn.confirm("Clear all completed tasks?", "&Yes\n&No", 2)
				should_delete = confirm == 1
			end

			if should_delete then
				todos = M.list("pending")
				save_todos()
				log(string.format("Cleared %d completed tasks", completed_count))
			end
		elseif filter_type == "all" then
			local should_delete = true
			if M.config.ask_before_delete then
				local confirm = vim.fn.confirm("Clear all tasks?", "&Yes\n&No", 2)
				should_delete = confirm == 1
			end

			if should_delete then
				todos = {}
				save_todos()
				log("All tasks cleared")
			end
		else
			log("Usage: TodoClear {completed|all}")
		end
	end, {
		nargs = 1,
		desc = "Clear completed or all todos",
		complete = function()
			return { "completed", "all" }
		end,
	})
end

return M
