local nnoremap = require("user.keymap_utils").nnoremap
local vnoremap = require("user.keymap_utils").vnoremap
local inoremap = require("user.keymap_utils").inoremap
local tnoremap = require("user.keymap_utils").tnoremap
local xnoremap = require("user.keymap_utils").xnoremap
local harpoon_ui = require("harpoon.ui")
local harpoon_mark = require("harpoon.mark")
local illuminate = require("illuminate")
local utils = require("user.utils")

local M = {}

-- Normal --
-- Disable Space bar since it'll be used as the leader key
nnoremap("<space>", "<nop>")

-- Window navigation
nnoremap("<C-j>", [[<Cmd>wincmd j<CR>]])
nnoremap("<C-k>", [[<Cmd>wincmd k<CR>]])
nnoremap("<C-l>", [[<Cmd>wincmd l<CR>]])
nnoremap("<C-h>", [[<Cmd>wincmd h<CR>]])

-- Swap between last two buffers
nnoremap("<leader>'", "<C-^>", { desc = "Switch to last buffer" })

-- Save File
nnoremap("<C-s>", "<cmd>w<cr>", { silent = false, desc = "Save File" })

-- Quit with leader key
nnoremap("<leader>q", "<cmd>q<cr>", { silent = false, desc = "Quit Buffer" })

-- Save and Quit with leader key
nnoremap("<leader>z", "<cmd>wq<cr>", { silent = false, desc = "Save and Quit" })

-- Toggle File Tree
nnoremap("<leader>e", ":NvimTreeToggle<cr>", { desc = "Toggle File Tree" })

-- Select all
nnoremap("<C-a>", "ggVG")

-- Toggle AI
nnoremap("<leader>i", function()
	vim.cmd("CodeiumToggle")
	local ai_status = vim.g.codeium_enabled and "enabled" or "disabled"
	vim.notify("AI " .. ai_status, vim.log.levels.INFO, { title = "Codeium" })
end, { desc = "Toggle AI" })

-- Center buffer while navigating
nnoremap("<C-u>", "<C-u>zz")
nnoremap("<C-d>", "<C-d>zz")
nnoremap("{", "{zz")
nnoremap("}", "}zz")
nnoremap("N", "Nzz")
nnoremap("n", "nzz")
nnoremap("G", "Gzz")
nnoremap("gg", "ggzz")
nnoremap("<C-i>", "<C-i>zz")
nnoremap("<C-o>", "<C-o>zz")
nnoremap("%", "%zz")
nnoremap("*", "*zz")
nnoremap("#", "#zz")

-- Press 'S' for quick find/replace for the word under the cursor
nnoremap("S", function()
	local cmd = ":%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>"
	local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end)

-- Open Spectre for global find/replace
nnoremap("<leader>S", function()
	require("spectre").toggle()
end, { desc = "Open Spectre for global find/replace" })

-- Open Spectre for global find/replace for the word under the cursor in normal mode
nnoremap("<leader>sw", function()
	require("spectre").open_visual({ select_word = true })
end, { desc = "Search current word" })

-- Jump to start/end of a line (first/last char)
nnoremap("L", "$", { desc = "Jump to end of a line" })
nnoremap("H", "^", { desc = "Jump to start of a line" })

-- Turn off highlighted results
nnoremap("<leader>no", "<cmd>nohl<cr>", { desc = "Turn off highlighted results" })

-- Diagnostics

-- Goto next diagnostic of any severity
nnoremap("]d", function()
	vim.diagnostic.goto_next({})
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous diagnostic of any severity
nnoremap("[d", function()
	vim.diagnostic.goto_prev({})
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto next error diagnostic
nnoremap("]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous error diagnostic
nnoremap("[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto next warning diagnostic
nnoremap("]w", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

-- Goto previous warning diagnostic
nnoremap("[w", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end)

nnoremap("<leader>d", function()
	vim.diagnostic.open_float({
		border = "rounded",
	})
end)

-- Place all dignostics into a qflist
nnoremap("<leader>ld", vim.diagnostic.setqflist, { desc = "Quickfix [L]ist [D]iagnostics" })

-- Navigate to next qflist item
nnoremap("<leader>cn", ":cnext<cr>zz", { desc = "Navigate to next qflist item" })

-- Navigate to previos qflist item
nnoremap("<leader>cp", ":cprevious<cr>zz", { desc = "Navigate to previous qflist item" })

-- Open the qflist
nnoremap("<leader>co", ":copen<cr>zz", { desc = "Open the qflist" })

-- Close the qflist
nnoremap("<leader>cc", ":cclose<cr>zz", { desc = "Close the qflist" })

-- Map MaximizerToggle (szw/vim-maximizer) to leader-m
nnoremap("<leader>m", ":MaximizerToggle<cr>", { desc = "[M]aximize Buffer" })

-- Resize split windows to be equal size
nnoremap("<leader>=", "<C-w>=", { desc = "Resize split windows to be equal size" })

-- Press leader rw to rotate open windows
nnoremap("<leader>rw", ":RotateWindows<cr>", { desc = "[R]otate [W]indows" })

-- Press gx to open the link under the cursor
nnoremap("gx", ":sil !open <cWORD><cr>", { silent = true, desc = "Open link" })

-- TSC autocommand keybind to run TypeScripts tsc
nnoremap("<leader>tc", ":TSC<cr>", { desc = "[T]ypeScript [C]ompile" })

-- Harpoon keybinds --
-- Open harpoon ui
nnoremap("<leader>ho", function()
	harpoon_ui.toggle_quick_menu()
end, { desc = "[H]arpoon [O]pen" })

-- Add current file to harpoon
nnoremap("<leader>ha", function()
	harpoon_mark.add_file()
end, { desc = "[H]arpoon [A]dd File" })

-- Remove current file from harpoon
nnoremap("<leader>hr", function()
	harpoon_mark.rm_file()
end, { desc = "[H]arpoon [R]emove File" })

-- Remove all files from harpoon
nnoremap("<leader>hc", function()
	harpoon_mark.clear_all()
end, { desc = "[H]arpoon [C]lear" })

-- Quickly jump to harpooned files
nnoremap("1", function()
	harpoon_ui.nav_file(1)
end, { desc = "Harpoon 1" })

nnoremap("2", function()
	harpoon_ui.nav_file(2)
end, { desc = "Harpoon 2" })

nnoremap("3", function()
	harpoon_ui.nav_file(3)
end, { desc = "Harpoon 3" })

nnoremap("4", function()
	harpoon_ui.nav_file(4)
end, { desc = "Harpoon 4" })

nnoremap("5", function()
	harpoon_ui.nav_file(5)
end, { desc = "Harpoon 5" })

-- Git keymaps --
nnoremap("<leader>gb", ":Gitsigns toggle_current_line_blame<cr>")
nnoremap("<leader>gf", function()
	local cmd = {
		"sort",
		"-u",
		"<(git diff --name-only --cached)",
		"<(git diff --name-only)",
		"<(git diff --name-only --diff-filter=U)",
	}

	if not utils.is_git_directory() then
		vim.notify(
			"Current project is not a git directory",
			vim.log.levels.WARN,
			{ title = "Telescope Git Files", git_command = cmd }
		)
	else
		require("telescope.builtin").git_files()
	end
end, { desc = "Search [G]it [F]iles" })

-- Telescope keybinds --
nnoremap("<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
nnoremap("<leader>sb", require("telescope.builtin").buffers, { desc = "[S]earch Open [B]uffers" })
nnoremap("<leader>f", function()
	require("telescope.builtin").find_files({ hidden = true })
end, { desc = "[F]iles" })
nnoremap("<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
nnoremap("<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })

nnoremap("<leader>sc", function()
	require("telescope.builtin").commands(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, { desc = "[S]earch [C]ommands" })

nnoremap("<leader>/", function()
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

nnoremap("<leader>ss", function()
	require("telescope.builtin").spell_suggest(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, { desc = "[S]earch [S]pelling suggestions" })

-- LSP Keybinds (exports a function to be used in ../../after/plugin/lsp.lua b/c we need a reference to the current buffer) --
M.map_lsp_keybinds = function(buffer_number)
	nnoremap("<leader>rn", vim.lsp.buf.rename, { desc = "LSP: [R]e[n]ame", buffer = buffer_number })
	nnoremap("<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: [C]ode [A]ction", buffer = buffer_number })

	nnoremap("gd", vim.lsp.buf.definition, { desc = "LSP: [G]oto [D]efinition", buffer = buffer_number })

	-- Telescope LSP keybinds --
	nnoremap(
		"gr",
		require("telescope.builtin").lsp_references,
		{ desc = "LSP: [G]oto [R]eferences", buffer = buffer_number }
	)

	nnoremap(
		"gi",
		require("telescope.builtin").lsp_implementations,
		{ desc = "LSP: [G]oto [I]mplementation", buffer = buffer_number }
	)

	nnoremap(
		"<leader>bs",
		require("telescope.builtin").lsp_document_symbols,
		{ desc = "LSP: [B]uffer [S]ymbols", buffer = buffer_number }
	)

	-- nnoremap(
	-- 	"<leader>ps",
	-- 	require("telescope.builtin").lsp_workspace_symbols,
	-- 	{ desc = "LSP: [P]roject [S]ymbols", buffer = buffer_number }
	-- )

	-- See `:help K` for why this keymap
	nnoremap("K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation", buffer = buffer_number })
	nnoremap("<leader>k", vim.lsp.buf.signature_help, { desc = "LSP: Signature Documentation", buffer = buffer_number })
	inoremap("<C-k>", vim.lsp.buf.signature_help, { desc = "LSP: Signature Documentation", buffer = buffer_number })

	-- Lesser used LSP functionality
	nnoremap("gD", vim.lsp.buf.declaration, { desc = "LSP: [G]oto [D]eclaration", buffer = buffer_number })
	nnoremap("td", vim.lsp.buf.type_definition, { desc = "LSP: [T]ype [D]efinition", buffer = buffer_number })
end

-- Symbol Outline keybind
nnoremap("<leader>so", ":SymbolsOutline<cr>")

-- Vim Illuminate keybinds
nnoremap("<leader>]", function()
	illuminate.goto_next_reference()
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Illuminate: Goto next reference" })

nnoremap("<leader>[", function()
	illuminate.goto_prev_reference()
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Illuminate: Goto previous reference" })

-- nvim-ufo keybinds
nnoremap("zR", require("ufo").openAllFolds)
nnoremap("zM", require("ufo").closeAllFolds)

-- Insert --
-- Map jj to <esc>
inoremap("jj", "<esc>")

-- Visual --
-- Disable Space bar since it'll be used as the leader key
vnoremap("<space>", "<nop>")

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
vnoremap("L", "$", { desc = "Jump to end of a line" })
vnoremap("H", "^", { desc = "Jump to start of a line" })

-- Paste without losing the contents of the register
xnoremap("<leader>p", '"_dP', { desc = "Paste without losing the contents of the register" })

-- Move selected text up/down in visual mode
vnoremap("<A-j>", ":m '>+1<CR>gv=gv")
vnoremap("<A-k>", ":m '<-2<CR>gv=gv")

-- Reselect the last visual selection
xnoremap("<<", function()
	vim.cmd("normal! <<")
	vim.cmd("normal! gv")
end)

xnoremap(">>", function()
	vim.cmd("normal! >>")
	vim.cmd("normal! gv")
end)

-- Terminal --
-- Enter normal mode while in a terminal
tnoremap("<esc>", [[<C-\><C-n>]])
tnoremap("jj", [[<C-\><C-n>]])

-- Window navigation from terminal
tnoremap("<C-h>", [[<Cmd>wincmd h<CR>]])
tnoremap("<C-j>", [[<Cmd>wincmd j<CR>]])
tnoremap("<C-k>", [[<Cmd>wincmd k<CR>]])
tnoremap("<C-l>", [[<Cmd>wincmd l<CR>]])

-- Reenable default <space> functionality to prevent input delay
tnoremap("<space>", "<space>")

return M