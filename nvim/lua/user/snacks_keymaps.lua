-- Snacks keymaps
local Snacks = require("snacks")

-- Git browse
vim.keymap.set({ "n", "v" }, "<leader>og", function()
	Snacks.gitbrowse()
end, { desc = "[O]pen [G]it" })

-- Toggle relative numbers
vim.keymap.set("n", "<leader>ln", function()
	Snacks.toggle.option("relativenumber", { name = "Relative Number" }):toggle()
end, { desc = "Toggle Relative [L]ine [N]umbers" })

-- Toggle diagnostics
vim.keymap.set("n", "<leader>td", function()
	Snacks.toggle.diagnostics():toggle()
end, { desc = "[T]oggle [D]iagnostics" })

-- Toggle dim
vim.keymap.set("n", "<leader>zm", function()
	Snacks.toggle.dim():toggle()
end, { desc = "Toggle Dim Mode" })

-- Toggle wrap
vim.keymap.set("n", "<leader>tw", function()
	Snacks.toggle.option("wrap"):toggle()
end, { desc = "[T]oggle line [W]rap" })

-- Toggle inlay hints
vim.keymap.set("n", "<leader>ih", function()
	Snacks.toggle({
		name = "Inlay Hints",
		get = function()
			return vim.lsp.inlay_hint.is_enabled()
		end,
		set = function(state)
			if state then
				vim.lsp.inlay_hint.enable(true)
			else
				vim.lsp.inlay_hint.enable(false)
			end
		end,
	}):toggle()
end, { desc = "Toggle [I]nlay [H]ints" })

-- Toggle highlight colors
vim.keymap.set("n", "<leader>hl", function()
	local hc = require("nvim-highlight-colors")
	Snacks.toggle({
		name = "Highlight Colors",
		get = function()
			return hc.is_active()
		end,
		set = function(state)
			if state then
				hc.turnOn()
			else
				hc.turnOff()
			end
		end,
	}):toggle()
end, { desc = "Toggle [H]igh[L]ight Colors" })

-- Scratch
vim.keymap.set("n", "<leader>.", function()
	Snacks.scratch()
end, { desc = "Toggle Scratch Buffer" })
vim.keymap.set("n", "<leader>s.", function()
	Snacks.scratch.select()
end, { desc = "Search Scratch Buffers" })

-- Picker keymaps
vim.keymap.set("n", "ff", function()
	Snacks.picker.smart()
end, { desc = "Smart Find Files" })

vim.keymap.set("n", "<leader><leader>", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })

vim.keymap.set("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "Grep" })

vim.keymap.set("n", "<leader>:", function()
	Snacks.picker.command_history()
end, { desc = "Command History" })

-- find
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files()
end, { desc = "Find Files" })

vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.git_files()
end, { desc = "Find Git Files" })

vim.keymap.set("n", "<leader>fp", function()
	Snacks.picker.projects()
end, { desc = "Projects" })

vim.keymap.set("n", "<leader>fr", function()
	Snacks.picker.recent()
end, { desc = "Recent" })

-- git
vim.keymap.set("n", "<leader>gb", function()
	Snacks.picker.git_branches()
end, { desc = "Git Branches" })

vim.keymap.set("n", "<leader>gl", function()
	Snacks.picker.git_log()
end, { desc = "Git Log" })

vim.keymap.set("n", "<leader>gL", function()
	Snacks.picker.git_log_line()
end, { desc = "Git Log Line" })

vim.keymap.set("n", "<leader>gs", function()
	Snacks.picker.git_status()
end, { desc = "Git Status" })

vim.keymap.set("n", "<leader>gS", function()
	Snacks.picker.git_stash()
end, { desc = "Git Stash" })

vim.keymap.set("n", "<leader>gd", function()
	Snacks.picker.git_diff()
end, { desc = "Git Diff (Hunks)" })

vim.keymap.set("n", "<leader>gf", function()
	Snacks.picker.git_log_file()
end, { desc = "Git Log File" })

-- gh
-- vim.keymap.set("n", "<leader>gi", function()
-- 	Snacks.picker.gh_issue()
-- end, { desc = "GitHub Issues (open)" })
-- vim.keymap.set("n", "<leader>gI", function()
-- 	Snacks.picker.gh_issue({ state = "all" })
-- end, { desc = "GitHub Issues (all)" })
-- vim.keymap.set("n", "<leader>gp", function()
-- 	Snacks.picker.gh_pr()
-- end, { desc = "GitHub Pull Requests (open)" })
-- vim.keymap.set("n", "<leader>gP", function()
-- 	Snacks.picker.gh_pr({ state = "all" })
-- end, { desc = "GitHub Pull Requests (all)" })

-- Grep
-- vim.keymap.set("n", "<leader>sb", function()
-- 	Snacks.picker.lines()
-- end, { desc = "Buffer Lines" })
-- vim.keymap.set({ "n", "x" }, "<leader>sw", function()
-- 	Snacks.picker.grep_word()
-- end, { desc = "Visual selection or word" })

-- search
-- vim.keymap.set("n", '<leader>s"', function()
-- 	Snacks.picker.registers()
-- end, { desc = "Registers" })
-- vim.keymap.set("n", "<leader>s/", function()
-- 	Snacks.picker.search_history()
-- end, { desc = "Search History" })
-- vim.keymap.set("n", "<leader>sa", function()
-- 	Snacks.picker.autocmds()
-- end, { desc = "Autocmds" })
-- vim.keymap.set("n", "<leader>sc", function()
-- 	Snacks.picker.command_history()
-- end, { desc = "Command History" })
-- vim.keymap.set("n", "<leader>sC", function()
-- 	Snacks.picker.commands()
-- end, { desc = "Commands" })
-- vim.keymap.set("n", "<leader>sd", function()
-- 	Snacks.picker.diagnostics()
-- end, { desc = "Diagnostics" })
-- vim.keymap.set("n", "<leader>sD", function()
-- 	Snacks.picker.diagnostics_buffer()
-- end, { desc = "Buffer Diagnostics" })
-- vim.keymap.set("n", "<leader>sh", function()
-- 	Snacks.picker.help()
-- end, { desc = "Help Pages" })
-- vim.keymap.set("n", "<leader>sH", function()
-- 	Snacks.picker.highlights()
-- end, { desc = "Highlights" })
-- vim.keymap.set("n", "<leader>si", function()
-- 	Snacks.picker.icons()
-- end, { desc = "Icons" })
-- vim.keymap.set("n", "<leader>sj", function()
-- 	Snacks.picker.jumps()
-- end, { desc = "Jumps" })
vim.keymap.set("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "Keymaps" })
-- vim.keymap.set("n", "<leader>sl", function()
-- 	Snacks.picker.loclist()
-- end, { desc = "Location List" })
-- vim.keymap.set("n", "<leader>sm", function()
-- 	Snacks.picker.marks()
-- end, { desc = "Marks" })
-- vim.keymap.set("n", "<leader>sM", function()
-- 	Snacks.picker.man()
-- end, { desc = "Man Pages" })
-- vim.keymap.set("n", "<leader>sp", function()
-- 	Snacks.picker.lazy()
-- end, { desc = "Search for Plugin Spec" })
-- vim.keymap.set("n", "<leader>sq", function()
-- 	Snacks.picker.qflist()
-- end, { desc = "Quickfix List" })
-- vim.keymap.set("n", "<leader>sR", function()
-- 	Snacks.picker.resume()
-- end, { desc = "Resume" })
vim.keymap.set("n", "<leader>su", function()
	Snacks.picker.undo()
end, { desc = "Undo History" })
vim.keymap.set("n", "<leader>sc", function()
	Snacks.picker.colorschemes()
end, { desc = "Colorschemes" })

-- LSP
vim.keymap.set("n", "gd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Goto Definition" })

vim.keymap.set("n", "gD", function()
	Snacks.picker.lsp_declarations()
end, { desc = "Goto Declaration" })

vim.keymap.set("n", "gr", function()
	Snacks.picker.lsp_references()
end, { desc = "References", nowait = true })

vim.keymap.set("n", "gi", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Goto Implementation" })

vim.keymap.set("n", "gt", function()
	Snacks.picker.lsp_type_definitions()
end, { desc = "Goto T[y]pe Definition" })

vim.keymap.set("n", "gai", function()
	Snacks.picker.lsp_incoming_calls()
end, { desc = "C[a]lls Incoming" })

vim.keymap.set("n", "gao", function()
	Snacks.picker.lsp_outgoing_calls()
end, { desc = "C[a]lls Outgoing" })

-- vim.keymap.set("n", "<leader>ss", function()
-- 	Snacks.picker.lsp_symbols()
-- end, { desc = "LSP Symbols" })

-- vim.keymap.set("n", "<leader>sS", function()
-- 	Snacks.picker.lsp_workspace_symbols()
-- end, { desc = "LSP Workspace Symbols" })
--
vim.keymap.set("n", "<leader>ss", function()
	Snacks.picker.spelling({
		layout = {
			preset = "select",
		},
	})
end, { desc = "[S]earch [S]pelling suggestions" })
