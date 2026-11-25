return {
	{
		"j-hui/fidget.nvim",
		event = { "BufEnter" },
		config = function()
			-- Turn on LSP, formatting, and linting status and progress information
			require("fidget").setup({
				notification = {
					window = {
						winblend = 100,
					},
				},
				progress = {
					display = {
						done_icon = "", -- Icon shown when all LSP progress tasks are complete
					},
				},
			})
		end,
	},
}
