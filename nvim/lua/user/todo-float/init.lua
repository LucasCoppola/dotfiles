local M = {}
local todo_buf = nil
local todo_path = nil
local todo_content = nil

local function ensure_todo_ready()
	if todo_buf and vim.api.nvim_buf_is_valid(todo_buf) then
		return todo_buf
	end

	-- Only find path once
	if not todo_path then
		local root_markers = { ".git" } -- Just check for .git for speed
		local current_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) or vim.loop.cwd()
		local project_root = vim.fs.find(root_markers, { path = current_dir, upward = true, limit = 1 })
		local root = (project_root and #project_root > 0) and vim.fs.dirname(project_root[1]) or vim.loop.cwd()
		todo_path = root .. "/todo.md"
	end

	if not todo_content then
		if vim.fn.filereadable(todo_path) == 1 then
			todo_content = vim.fn.readfile(todo_path)
		else
			todo_content = { "" } -- Empty file
		end
	end

	-- Create buffer and set everything only on first creation
	todo_buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_name(todo_buf, todo_path)
	vim.api.nvim_buf_set_lines(todo_buf, 0, -1, false, todo_content)
	vim.api.nvim_set_option_value("filetype", "markdown", { buf = todo_buf })

	return todo_buf
end

local function open_todo_float()
	local buf = ensure_todo_ready()

	-- Calculate window dimensions
	local width = math.floor(vim.o.columns * 0.7)
	local height = math.floor(vim.o.lines * 0.7)

	-- Create floating window
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		border = "rounded",
		title = " Todo.md ",
	})

	-- Set window-local options after opening
	vim.opt_local.number = true
	vim.opt_local.relativenumber = true
end

function M.float()
	open_todo_float()
end

M.toggle = M.float

function M.setup()
	vim.api.nvim_create_user_command("TodoFloat", M.float, { desc = "Open todo.md in a floating window" })
	vim.keymap.set("n", "<leader>td", M.float, { desc = "Todo Float" })
end

return M
