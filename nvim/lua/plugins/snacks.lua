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
		keys = {},
	},
}
