return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you use the mini.nvim suite
		opts = {
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},
			heading = {
				position = "inline",
				icons = {},
			},
		},
		ft = { "markdown", "norg", "rmd", "org" },
	},
}
