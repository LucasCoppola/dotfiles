return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			view = {
				width = 35,
				side = "right",
			},
			renderer = {
				group_empty = true,
				highlight_git = "name",
				highlight_modified = "name",
				icons = {
					git_placement = "after",
					glyphs = {
						git = {
							unstaged = "U",
							staged = "+",
							unmerged = "",
							renamed = "R",
							untracked = "U",
							deleted = "D",
						},
					},
				},
			},
			filters = {
				git_ignored = false,
				exclude = { ".git/", "node_modules", ".next", "drizzle" },
			},
			notify = {
				threshold = vim.log.levels.ERROR,
			},
		})
	end,
}
