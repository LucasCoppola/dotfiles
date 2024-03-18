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

-- return {
-- 	{
-- 		"catppuccin/nvim",
-- 		config = function()
-- 			require("catppuccin").setup({
-- 				integrations = {
-- 					cmp = true,
-- 					gitsigns = true,
-- 					harpoon = true,
-- 					illuminate = true,
-- 					indent_blankline = {
-- 						enabled = false,
-- 						scope_color = "sapphire",
-- 						colored_indent_levels = false,
-- 					},
-- 					mason = true,
-- 					native_lsp = { enabled = true },
-- 					notify = true,
-- 					nvimtree = true,
-- 					symbols_outline = true,
-- 					telescope = true,
-- 					treesitter = true,
-- 					treesitter_context = true,
-- 				},
-- 			})
--
-- 			vim.cmd.colorscheme("catppuccin-mocha")
--
-- 			-- Hide all semantic highlights until upstream issues are resolved (https://github.com/catppuccin/nvim/issues/480)
-- 			for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
-- 				vim.api.nvim_set_hl(0, group, {})
-- 			end
-- 		end,
-- 	},
-- }
