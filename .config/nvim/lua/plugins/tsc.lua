return {
	{
		"dmmulroy/tsc.nvim",
		lazy = true,
		ft = { "typescript", "typescriptreact" },
		config = function()
			require("tsc").setup({
				bin_name = "tsgo",
				auto_open_qflist = true,
				pretty_errors = false,
				flags = "--noEmit --pretty false",
			})
		end,
	},
}

-- By default, tsc.nvim will check only the nearest tsconfig file.
-- If you would like it to use all tsconfig files in the current working directory, set run_as_monorepo = true.
-- All other options will work as usual such as auto_start_watch_mode, flags.watch, etc.
--
-- require('tsc').setup({
--     run_as_monorepo = true,
-- })

-- With this configuration, tsc.nvim will typecheck all projects in the monorepo,
-- taking into account project references and incremental builds.
