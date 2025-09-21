return {
	{
		"j-hui/fidget.nvim",
		tag = "v1.4.5",
		event = { "BufEnter" },
		config = function()
			-- Turn on LSP, formatting, and linting status and progress information
			require("fidget").setup({
				progress = {
					display = {
						done_icon = "", -- Icon shown when all LSP progress tasks are complete
					},
				},
			})
		end,
	},
}
