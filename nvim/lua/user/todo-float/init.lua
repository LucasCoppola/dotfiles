local M = {}

-- Find project root (looks for git, package.json, etc.)
local function find_project_root()
	local root_markers = { ".git", "package.json", "Cargo.toml", "go.mod", "pyproject.toml", ".gitignore" }
	-- Use vim.loop.cwd() for the current directory and fallback to expand() if needed.
	local current_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) or vim.loop.cwd()

	-- vim.fs.find is a more efficient and idiomatic way to find files upwards
	local project_root = vim.fs.find(root_markers, { path = current_dir, upward = true })

	if project_root and #project_root > 0 then
		-- vim.fs.find returns a list of found files, get the directory of the first one.
		return vim.fs.dirname(project_root[1])
	end

	-- Fallback to the current working directory if no root is found
	return vim.loop.cwd()
end

-- Get todo.md path
local function get_todo_path()
	local root = find_project_root()
	return root .. "/todo.md"
end

-- Open todo.md in floating window
local function open_todo_float()
	local todo_path = get_todo_path()

	-- Check if file exists, if not ask to create
	if vim.fn.filereadable(todo_path) == 0 then
		local choice = vim.fn.confirm("No todo.md found in project root.\nCreate one?", "&Yes\n&No", 1)
		if choice ~= 1 then
			vim.notify("Todo float cancelled.", vim.log.levels.INFO)
			return
		end

		-- Create the file with initial content if it doesn't exist
		vim.fn.writefile({
			"# " .. vim.fs.basename(find_project_root()) .. " Todos",
			"",
			"- [ ] First task",
			"- [ ] Second task",
		}, todo_path)
		vim.notify("Created todo.md at: " .. todo_path)
	end

	-- Create a new buffer and load the file content into it.
	-- true -> listed buffer, false -> not a scratch buffer
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_name(buf, todo_path)
	vim.api.nvim_buf_set_option(buf, "filetype", "markdown") -- Set filetype for syntax highlighting

	-- Read file content using the correct function and set it in the buffer
	local lines = vim.fn.readfile(todo_path)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modified", false) -- It's not modified yet

	-- Floating window configuration
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.6)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (vim.o.columns - width) / 2,
		row = (vim.o.lines - height) / 2,
		border = "rounded",
		title = " Todo.md ",
	}

	-- Open the window with the prepared buffer
	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Keymaps for the floating window
	vim.keymap.set("n", "q", function()
		-- Before closing, check if the buffer is modified
		if vim.api.nvim_buf_get_option(buf, "modified") then
			local save_choice = vim.fn.confirm("Save changes to todo.md?", "&Yes\n&No\n&Cancel", 1)
			if save_choice == 1 then
				-- Use vim.cmd to save the buffer associated with the todo_path
				vim.cmd("write! " .. vim.fn.fnameescape(todo_path))
			elseif save_choice == 3 then
				return -- Do nothing and leave window open
			end
		end
		vim.api.nvim_win_close(win, true) -- Force close the window
	end, { buffer = buf, nowait = true, silent = true, desc = "Close Todo Float" })
end

-- Public functions
function M.float()
	open_todo_float()
end

-- Alias for backward compatibility
M.toggle = M.float

-- Setup function
function M.setup()
	vim.api.nvim_create_user_command("TodoFloat", M.float, { desc = "Open todo.md in a floating window" })
	vim.keymap.set("n", "<leader>t", M.float, { desc = "Todo Float" })
end

return M
