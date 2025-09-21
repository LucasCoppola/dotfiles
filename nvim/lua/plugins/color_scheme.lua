return {
	"marko-cerovac/material.nvim",
	config = function()
		vim.g.material_style = "deep ocean"
		require("material").setup({
			contrast = {
				sidebars = true, -- Enable contrast for sidebar-like windows ( for example Nvim-Tree )
				floating_windows = true, -- Enable contrast for floating windows
				cursor_line = true, -- Enable darker background for the cursor line
			},

			plugins = {
				"fidget",
				"gitsigns",
				"harpoon",
				"illuminate",
				"indent-blankline",
				"nvim-cmp",
				"nvim-tree",
				"nvim-web-devicons",
				"telescope",
				"which-key",
				"nvim-notify",
			},

			high_visibility = {
				darker = true,
			},
		})

		vim.cmd("colorscheme material")
	end,
}
