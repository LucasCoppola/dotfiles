return {
	"Exafunction/codeium.vim",
	config = function()
		vim.keymap.set("i", "<C-y>", function()
			return vim.fn["codeium#Accept"]()
		end, { expr = true, silent = true })
	end,
}
