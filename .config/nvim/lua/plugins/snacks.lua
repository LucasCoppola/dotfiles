local filtered_message = { "No information available" }

return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,

		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			bufdelete = { enabled = true },
			dim = { enabled = true },
			gitbrowse = { enabled = true },
			indent = { enabled = true, animate = { enabled = false } },
			notifier = {
				enabled = true,
				timeout = 3000,
				style = "fancy",
			},
			rename = { enabled = true },
			toggle = { enabled = true },
			scratch = { enabled = true },
			input = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			picker = {
				formatters = { file = { filename_first = true } },
				win = { input = { keys = { ["<Esc>"] = { "close", mode = { "n", "i" } } } } },
				sources = {
					smart = {
						filter = {
							cwd = true,
							current = false,
						},
						matcher = {
							cwd_bonus = false,
							sort_empty = false,
							history_bonus = true,
						},
					},
				},
			},
		},

		init = function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VeryLazy",
				callback = function()
					local notify = Snacks.notifier.notify
					---@diagnostic disable-next-line: duplicate-set-field
					Snacks.notifier.notify = function(message, level, opts)
						for _, msg in ipairs(filtered_message) do
							if message == msg then
								return nil
							end
						end
						return notify(message, level, opts)
					end
				end,
			})

			local prev = { new_name = "", old_name = "" } -- Prevents duplicate events
			vim.api.nvim_create_autocmd("User", {
				pattern = "NvimTreeSetup",
				callback = function()
					local events = require("nvim-tree.api").events
					events.subscribe(events.Event.NodeRenamed, function(data)
						if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
							data = data
							Snacks.rename.on_rename_file(data.old_name, data.new_name)
						end
					end)
				end,
			})
		end,

		keys = {
			-- Git
			{
				"<leader>og",
				function()
					Snacks.gitbrowse()
				end,
				desc = "[O]pen [G]it",
				mode = { "n", "v" },
			},
			{
				"<leader>gb",
				function()
					Snacks.picker.git_branches()
				end,
				desc = "Git Branches",
			},
			{
				"<leader>gl",
				function()
					Snacks.picker.git_log()
				end,
				desc = "Git Log",
			},
			{
				"<leader>gL",
				function()
					Snacks.picker.git_log_line()
				end,
				desc = "Git Log Line",
			},

			-- Toggles
			{
				"<leader>ln",
				function()
					Snacks.toggle.option("relativenumber", { name = "Relative Number" }):toggle()
				end,
				desc = "Toggle Relative [L]ine [N]umbers",
			},
			{
				"<leader>td",
				function()
					Snacks.toggle.diagnostics():toggle()
				end,
				desc = "[T]oggle [D]iagnostics",
			},
			{
				"<leader>zm",
				function()
					Snacks.toggle.dim():toggle()
				end,
				desc = "Toggle Dim Mode",
			},
			{
				"<leader>tw",
				function()
					Snacks.toggle.option("wrap"):toggle()
				end,
				desc = "[T]oggle line [W]rap",
			},
			{
				"<leader>ih",
				function()
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
				end,
				desc = "Toggle [I]nlay [H]ints",
			},
			{
				"<leader>hl",
				function()
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
				end,
				desc = "Toggle [H]igh[L]ight Colors",
			},

			-- Scratch
			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>s.",
				function()
					Snacks.scratch.select()
				end,
				desc = "Search Scratch Buffers",
			},

			-- Picker - General
			{
				"ff",
				function()
					Snacks.picker.smart()
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader><leader>",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>sg",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>ff",
				function()
					Snacks.picker.files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fp",
				function()
					Snacks.picker.projects()
				end,
				desc = "Projects",
			},
			{
				"<leader>sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>su",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo History",
			},
			{
				"<leader>sc",
				function()
					Snacks.picker.colorschemes()
				end,
				desc = "Colorschemes",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.spelling({
						layout = {
							preset = "select",
						},
					})
				end,
				desc = "[S]earch [S]pelling suggestions",
			},

			-- Picker - LSP
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"gD",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				desc = "References",
				nowait = true,
			},
			{
				"gi",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"gt",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto T[y]pe Definition",
			},
			{
				"gai",
				function()
					Snacks.picker.lsp_incoming_calls()
				end,
				desc = "C[a]lls Incoming",
			},
			{
				"gao",
				function()
					Snacks.picker.lsp_outgoing_calls()
				end,
				desc = "C[a]lls Outgoing",
			},
		},
	},
}
