local parsers = {
	"astro",
	"bash",
	"css",
	"go",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"rust",
	"sql",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"yaml",
}

local filetypes = {
	"astro",
	"css",
	"go",
	"html",
	"javascript",
	"javascriptreact",
	"json",
	"jsonc",
	"lua",
	"markdown",
	"rust",
	"sh",
	"sql",
	"toml",
	"typescript",
	"typescriptreact",
	"vim",
	"yaml",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				branch = "main",
			},
		},
		config = function()
			require("nvim-treesitter").install(parsers)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetypes,
				callback = function()
					vim.treesitter.start()
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})

			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select").select_textobject
			local function select_mapping(capture)
				return function()
					select(capture, "textobjects")
				end
			end

			for key, capture in pairs({
				aa = "@parameter.outer",
				ia = "@parameter.inner",
				af = "@function.outer",
				["if"] = "@function.inner",
				ac = "@class.outer",
				ic = "@class.inner",
			}) do
				vim.keymap.set({ "x", "o" }, key, select_mapping(capture))
			end

			local move = require("nvim-treesitter-textobjects.move")
			local function move_mapping(movement)
				return function()
					movement[1](movement[2], "textobjects")
				end
			end

			for key, movement in pairs({
				["]m"] = { move.goto_next_start, "@function.outer" },
				[']]'] = { move.goto_next_start, "@class.outer" },
				["]M"] = { move.goto_next_end, "@function.outer" },
				["]["] = { move.goto_next_end, "@class.outer" },
				["[m"] = { move.goto_previous_start, "@function.outer" },
				["[["] = { move.goto_previous_start, "@class.outer" },
				["[M"] = { move.goto_previous_end, "@function.outer" },
				["[]"] = { move.goto_previous_end, "@class.outer" },
			}) do
				vim.keymap.set({ "n", "x", "o" }, key, move_mapping(movement))
			end
		end,
	},
}
