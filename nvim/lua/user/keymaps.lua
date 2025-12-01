local harpoon_ui = require("harpoon.ui")
local harpoon_mark = require("harpoon.mark")
local supermaven = require("supermaven-nvim.api")
local prelude = require("user.prelude")
local copy_line_diagnostics_to_clipboard = prelude.copy_line_diagnostics_to_clipboard

local M = {}
-- Add this after your colorscheme is loaded
vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { fg = "#82b1ff", bg = "NONE", bold = false })
vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { fg = "#c792ea", bg = "NONE", bold = false })
vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { fg = "#ffcb6b", bg = "NONE", bold = false })
vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { fg = "#f78c6c", bg = "NONE", bold = false })
vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { fg = "#c3e88d", bg = "NONE", bold = false })
vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { fg = "#ff5370", bg = "NONE", bold = false })

-- Normal Mode --
-- Disable Space bar since it'll be used as the leader key
vim.keymap.set("n", "<space>", "<nop>")

-- Window navigation
vim.keymap.set("n", "<C-j>", function()
	if vim.fn.exists(":NvimTmuxNavigateDown") ~= 0 then
		vim.cmd.NvimTmuxNavigateDown()
	else
		vim.cmd.wincmd("j")
	end
end, { desc = "Navigate down" })

vim.keymap.set("n", "<C-k>", function()
	if vim.fn.exists(":NvimTmuxNavigateUp") ~= 0 then
		vim.cmd.NvimTmuxNavigateUp()
	else
		vim.cmd.wincmd("k")
	end
end, { desc = "Navigate up" })

vim.keymap.set("n", "<C-l>", function()
	if vim.fn.exists(":NvimTmuxNavigateRight") ~= 0 then
		vim.cmd.NvimTmuxNavigateRight()
	else
		vim.cmd.wincmd("l")
	end
end, { desc = "Navigate right" })

vim.keymap.set("n", "<C-h>", function()
	if vim.fn.exists(":NvimTmuxNavigateLeft") ~= 0 then
		vim.cmd.NvimTmuxNavigateLeft()
	else
		vim.cmd.wincmd("h")
	end
end, { desc = "Navigate left" })

-- Resize with arrows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", { desc = "Resize up" })
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", { desc = "Resize down" })
vim.keymap.set("n", "<C-Left>", ":vertical resize +2<CR>", { desc = "Resize left" })
vim.keymap.set("n", "<C-Right>", ":vertical resize -2<CR>", { desc = "Resize right" })

vim.keymap.set("n", "<leader>cl", "oconsole.log()<Left>", { desc = "Insert console.log" })

-- Toggle TSContext
vim.keymap.set("n", "<leader>ct", ":TSContext toggle<cr>", { desc = "TS[C]ontext [T]oggle" })

-- Swap between last two buffers
vim.keymap.set("n", "<leader>'", "<C-^>", { desc = "Switch to last buffer" })

-- Save File
vim.keymap.set("n", "<C-s>", "<cmd>w<cr>", { silent = false, desc = "Save File" })

-- Quit with leader key
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { silent = false, desc = "Quit Buffer" })

-- Save and Quit with leader key
vim.keymap.set("n", "<leader>z", "<cmd>wq<cr>", { silent = false, desc = "Save and Quit" })

-- Toggle File Tree
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<cr>", { desc = "Toggle File Tree" })

-- Select all
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Toggle AI
vim.keymap.set("n", "<leader>i", function()
	if supermaven.is_running() then
		supermaven.stop()
		vim.notify("AI disabled", vim.log.levels.INFO, { title = "Supermaven" })
	else
		supermaven.start()
		vim.notify("AI enabled", vim.log.levels.INFO, { title = "Supermaven" })
	end
end, { desc = "Toggle AI" })

-- Center buffer while navigating
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "{", "{zz", { desc = "Previous paragraph and center" })
vim.keymap.set("n", "}", "}zz", { desc = "Next paragraph and center" })
vim.keymap.set("n", "N", "Nzz", { desc = "Previous search and center" })
vim.keymap.set("n", "n", "nzz", { desc = "Next search and center" })
vim.keymap.set("n", "G", "Gzz", { desc = "Go to end and center" })
vim.keymap.set("n", "gg", "ggzz", { desc = "Go to start and center" })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { desc = "Jump forward and center" })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { desc = "Jump backward and center" })
vim.keymap.set("n", "%", "%zz", { desc = "Jump to matching bracket and center" })
vim.keymap.set("n", "*", "*zz", { desc = "Search word forward and center" })
vim.keymap.set("n", "#", "#zz", { desc = "Search word backward and center" })

-- Press 'S' for quick find/replace for the word under the cursor
vim.keymap.set("n", "S", function()
	local cmd = ":%s/<C-r><C-w>/<C-r><C-w>/gcI<Left><Left><Left><Left>"
	local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
	vim.api.nvim_feedkeys(keys, "n", false)
end, { desc = "Quick find/replace word under cursor" })

-- Open Spectre for global find/replace
vim.keymap.set("n", "<leader>S", function()
	require("spectre").toggle()
end, { desc = "Open Spectre for global find/replace" })

-- Open Spectre for global find/replace for the word under the cursor in normal mode
vim.keymap.set("n", "<leader>sw", function()
	require("spectre").open_visual({ select_word = true })
end, { desc = "Search current word" })

-- Jump to start/end of a line (first/last char)
vim.keymap.set("n", "L", "$", { desc = "Jump to end of a line" })
vim.keymap.set("n", "H", "^", { desc = "Jump to start of a line" })

-- Turn off highlighted results
vim.keymap.set("n", "<Esc>", "<cmd>nohl<cr>", { desc = "Turn off highlighted results" })

-- Diagnostics

-- Goto next diagnostic of any severity
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Next diagnostic and center" })

-- Goto previous diagnostic of any severity
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Previous diagnostic and center" })

-- Goto next error diagnostic
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Next error and center" })

-- Goto previous error diagnostic
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Previous error and center" })

-- Goto next warning diagnostic
vim.keymap.set("n", "]w", function()
	vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Next warning and center" })

-- Goto previous warning diagnostic
vim.keymap.set("n", "[w", function()
	vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Previous warning and center" })

vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.open_float({
		border = "rounded",
	})
end, { desc = "Open diagnostic float" })

vim.keymap.set("n", "<leader>cd", copy_line_diagnostics_to_clipboard, { desc = "[C]opy line [D]iagnostics" })

-- Place all dignostics into a qflist
vim.keymap.set("n", "<leader>ld", vim.diagnostic.setqflist, { desc = "Quickfix [L]ist [D]iagnostics" })

-- Navigate to next qflist item
vim.keymap.set("n", "<leader>cn", ":cnext<cr>zz", { desc = "Navigate to next qflist item" })

-- Navigate to previos qflist item
vim.keymap.set("n", "<leader>cp", ":cprevious<cr>zz", { desc = "Navigate to previous qflist item" })

-- Open the qflist
vim.keymap.set("n", "<leader>co", ":copen<cr>zz", { desc = "Open the qflist" })

-- Close the qflist
vim.keymap.set("n", "<leader>cc", ":cclose<cr>zz", { desc = "Close the qflist" })

-- Map MaximizerToggle (szw/vim-maximizer) to leader-m
vim.keymap.set("n", "<leader>m", ":MaximizerToggle<cr>", { desc = "[M]aximize Buffer" })

-- Resize split windows to be equal size
vim.keymap.set("n", "<leader>=", "<C-w>=", { desc = "Resize split windows to be equal size" })

-- Press leader rw to rotate open windows
vim.keymap.set("n", "<leader>rw", ":RotateWindows<cr>", { desc = "[R]otate [W]indows" })

-- Press gx to open the link under the cursor
vim.keymap.set("n", "gx", ":sil !open <cWORD><cr>", { silent = true, desc = "Open link" })

-- TSC autocommand keybind to run TypeScripts tsc
vim.keymap.set("n", "<leader>tc", ":TSC<cr>", { desc = "[T]ypeScript [C]ompile" })

-- Harpoon keybinds --
-- Open harpoon ui
vim.keymap.set("n", "<leader>ho", function()
	harpoon_ui.toggle_quick_menu()
end, { desc = "[H]arpoon [O]pen" })

-- Add current file to harpoon
vim.keymap.set("n", "<leader>ha", function()
	harpoon_mark.add_file()
end, { desc = "[H]arpoon [A]dd File" })

-- Remove current file from harpoon
vim.keymap.set("n", "<leader>hr", function()
	harpoon_mark.rm_file()
end, { desc = "[H]arpoon [R]emove File" })

-- Remove all files from harpoon
vim.keymap.set("n", "<leader>hc", function()
	harpoon_mark.clear_all()
end, { desc = "[H]arpoon [C]lear" })

-- Quickly jump to harpooned files
vim.keymap.set("n", "<leader>1", function()
	harpoon_ui.nav_file(1)
end, { desc = "Harpoon 1" })

vim.keymap.set("n", "<leader>2", function()
	harpoon_ui.nav_file(2)
end, { desc = "Harpoon 2" })

vim.keymap.set("n", "<leader>3", function()
	harpoon_ui.nav_file(3)
end, { desc = "Harpoon 3" })

vim.keymap.set("n", "<leader>4", function()
	harpoon_ui.nav_file(4)
end, { desc = "Harpoon 4" })

-- Git keymaps --

-- Open git fugitive
vim.keymap.set("n", "<leader>g", "<cmd>Git<cr>", { silent = false, desc = "Open Git fugitive" })

-- Telescope keybinds --
vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><leader>", require("telescope.builtin").buffers, { desc = "[S]earch Open Buffers" })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })

vim.keymap.set("n", "<leader>f", function()
	require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
end, { desc = "[F]iles" })

vim.keymap.set("n", "<leader>sf", function()
	require("telescope.builtin").lsp_dynamic_workspace_symbols({
		symbols = { "function", "method" },
	})
end, { desc = "[S]earch [F]unctions" })

vim.keymap.set("n", "<leader>sc", require("telescope.builtin").colorscheme, { desc = "[S]earch [C]olorschemes" })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set("n", "<leader>sn", function()
	require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

vim.keymap.set("n", "<leader>/", function()
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>ss", function()
	require("telescope.builtin").spell_suggest(require("telescope.themes").get_dropdown({
		previewer = false,
	}))
end, { desc = "[S]earch [S]pelling suggestions" })

-- LSP Keybinds (per-buffer)
M.map_lsp_keybinds = function(buffer_number)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: Rename symbol", buffer = buffer_number })
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code action", buffer = buffer_number })
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to definition", buffer = buffer_number })
	vim.keymap.set(
		"n",
		"gr",
		require("telescope.builtin").lsp_references,
		{ desc = "LSP: Go to references", buffer = buffer_number }
	)
	vim.keymap.set(
		"n",
		"gi",
		require("telescope.builtin").lsp_implementations,
		{ desc = "LSP: Go to implementations", buffer = buffer_number }
	)
	vim.keymap.set(
		"n",
		"<leader>bs",
		require("telescope.builtin").lsp_document_symbols,
		{ desc = "LSP: Document symbols", buffer = buffer_number }
	)
	vim.keymap.set(
		"n",
		"<leader>ps",
		require("telescope.builtin").lsp_workspace_symbols,
		{ desc = "LSP: Workspace symbols", buffer = buffer_number }
	)

	local signature_help = function()
		return vim.lsp.buf.signature_help({ border = "rounded" })
	end

	local hover = function()
		return vim.lsp.buf.hover({ border = "rounded" })
	end

	vim.keymap.set("n", "K", hover, { desc = "LSP: Signature help", buffer = buffer_number })

	vim.keymap.set("i", "<C-k>", signature_help, { desc = "LSP: Signature help", buffer = buffer_number })
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to declaration", buffer = buffer_number })
	vim.keymap.set("n", "td", vim.lsp.buf.type_definition, { desc = "LSP: Type definition", buffer = buffer_number })
end

-- Symbol Outline keybind
vim.keymap.set("n", "<leader>so", ":SymbolsOutline<cr>", { desc = "Toggle symbols outline" })

-- nvim-ufo keybinds
vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })

-- Insert Mode --
vim.keymap.set("i", "jk", "<esc>", { desc = "Exit insert mode (jk)" })
vim.keymap.set("i", "kj", "<esc>", { desc = "Exit insert mode (kj)" })

-- Visual Mode --
-- Disable Space bar since it'll be used as the leader key
vim.keymap.set("v", "<space>", "<nop>")

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
vim.keymap.set("v", "L", "$", { desc = "Jump to end of a line" })
vim.keymap.set("v", "H", "^", { desc = "Jump to start of a line" })

-- Paste without losing the contents of the register
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without losing the contents of the register" })

-- Move selected text up/down in visual mode
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Reselect the last visual selection
vim.keymap.set("x", "<<", function()
	vim.cmd("normal! <<")
	vim.cmd("normal! gv")
end, { desc = "Indent left and reselect" })

vim.keymap.set("x", ">>", function()
	vim.cmd("normal! >>")
	vim.cmd("normal! gv")
end, { desc = "Indent right and reselect" })

-- Terminal Mode --
-- Enter normal mode while in a terminal
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set("t", "jk", [[<C-\><C-n>]], { desc = "Exit terminal mode (jk)" })
vim.keymap.set("t", "kj", [[<C-\><C-n>]], { desc = "Exit terminal mode (kj)" })

-- Window navigation from terminal
vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], { desc = "Navigate left from terminal" })
vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], { desc = "Navigate down from terminal" })
vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], { desc = "Navigate up from terminal" })
vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], { desc = "Navigate right from terminal" })

-- Reenable default <space> functionality to prevent input delay
vim.keymap.set("t", "<space>", "<space>", { desc = "Space in terminal mode" })

return M
