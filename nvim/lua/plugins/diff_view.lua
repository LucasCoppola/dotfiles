return {
	{
		"sindrets/diffview.nvim",
		config = function()
			require("diffview").setup({
				file_panel = {
					win_config = { -- See |diffview-config-win_config|
						position = "bottom",
					},
				},
			})
		end,
	},
}
