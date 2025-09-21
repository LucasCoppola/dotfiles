return {
	{
		"nvim-treesitter/nvim-treesitter-context",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("treesitter-context").setup({
				enable = true,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "typescriptreact", "javascriptreact" },
				callback = function()
					require("treesitter-context").disable()
				end,
			})
		end,
	},
}
