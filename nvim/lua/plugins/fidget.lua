return {
	{
		"j-hui/fidget.nvim",
		tag = "v1.0.0",
		event = { "BufEnter" },
		config = function()
			-- Turn on LSP, formatting, and linting status and progress information
			require("fidget").setup({
				text = {
					spinner = "dots",
					done = "",
				},
			})
		end,
	},
}
