# Neovim Keybindings Reference

## Normal Mode

### Navigation
- `<C-j>`: Navigate down (with tmux support)
- `<C-k>`: Navigate up (with tmux support)
- `<C-l>`: Navigate right (with tmux support)
- `<C-h>`: Navigate left (with tmux support)
- `<C-u>`: Scroll up and center
- `<C-d>`: Scroll down and center
- `{`: Previous paragraph and center
- `}`: Next paragraph and center
- `N`: Previous search and center
- `n`: Next search and center
- `G`: Go to end and center
- `gg`: Go to start and center
- `<C-i>`: Jump forward and center
- `<C-o>`: Jump backward and center
- `%`: Jump to matching bracket and center
- `*`: Search word forward and center
- `#`: Search word backward and center
- `L`: Jump to end of line
- `H`: Jump to start of line

### Window Management
- `<C-Up>`: Resize window up
- `<C-Down>`: Resize window down
- `<C-Left>`: Resize window left
- `<C-Right>`: Resize window right
- `<leader>m`: Maximize buffer
- `<leader>=`: Equalize window sizes
- `<leader>rw`: Rotate windows

### File Operations
- `<C-s>`: Save file
- `<leader>q`: Quit buffer
- `<leader>z`: Save and quit
- `<leader>e`: Toggle file tree (NvimTree)
- `<C-a>`: Select all
- `<leader>'`: Switch to last buffer

### Editing
- `<leader>cl`: Insert `console.log()`
- `<leader>ct`: Toggle TreeSitter context
- `<leader>i`: Toggle AI (Supermaven)
- `S`: Quick find/replace word under cursor
- `<leader>S`: Open Spectre for global find/replace
- `<leader>sw`: Search current word with Spectre
- `<Esc>`: Turn off highlighted search results
- `gx`: Open link under cursor

### Diagnostics
- `]d`: Next diagnostic and center
- `[d`: Previous diagnostic and center
- `]e`: Next error and center
- `[e`: Previous error and center
- `]w`: Next warning and center
- `[w`: Previous warning and center
- `<leader>d`: Open diagnostic float
- `<leader>cd`: Copy line diagnostics to clipboard
- `<leader>ld`: Place diagnostics in quickfix list
- `<leader>cn`: Navigate to next quickfix item
- `<leader>cp`: Navigate to previous quickfix item
- `<leader>co`: Open quickfix list
- `<leader>cc`: Close quickfix list

### LSP
- `<leader>rn`: Rename symbol
- `<leader>ca`: Code action
- `gd`: Go to definition
- `gr`: Go to references
- `gi`: Go to implementations
- `<leader>bs`: Document symbols
- `<leader>ps`: Workspace symbols
- `K`: Hover
- `gD`: Go to declaration
- `td`: Type definition
- `<leader>tc`: Run TypeScript compiler

### Git
- `<leader>g`: Open Git fugitive

### Telescope Search
- `<leader>?`: Find recently opened files
- `<leader><leader>`: Search open buffers
- `<leader>sh`: Search help tags
- `<leader>sg`: Live grep search
- `<leader>f`: Find files (including hidden)
- `<leader>sf`: Search functions/methods
- `<leader>sc`: Search colorschemes
- `<leader>sn`: Search Neovim config files
- `<leader>/`: Fuzzy search in current buffer
- `<leader>ss`: Search spelling suggestions

### Harpoon
- `<leader>ho`: Open Harpoon menu
- `<leader>ha`: Add file to Harpoon
- `<leader>hr`: Remove file from Harpoon
- `<leader>hc`: Clear all Harpoon files
- `<leader>1`: Jump to Harpoon file 1
- `<leader>2`: Jump to Harpoon file 2
- `<leader>3`: Jump to Harpoon file 3
- `<leader>4`: Jump to Harpoon file 4

### Folds
- `zR`: Open all folds
- `zM`: Close all folds

### Snacks/Toggles
- `<leader>bd`: Buffer delete
- `<leader>og`: Open git origin
- `<leader>nh`: Notification history
- `<leader>nd`: Notifications dismiss
- `<leader>ln`: Toggle relative line numbers
- `<leader>cl`: Toggle cursor line
- `<leader>td`: Toggle diagnostics
- `<leader>zm`: Toggle dim mode
- `<leader>tw`: Toggle line wrap
- `<leader>tx`: Toggle treesitter context
-`<leader>ih`: Toggle inlay hints
- `<leader>hl`: Toggle highlight colors
- `<leader>.`: Toggle scratch buffer
- `<leader>s.`: Search scratch buffers

### Miscellaneous
- `<leader>so`: Toggle symbols outline
- `<space>`: Leader key (disabled)

## Insert Mode

- `jk`: Exit insert mode
- `kj`: Exit insert mode
- `<C-k>`: LSP: Signature help

## Visual Mode

- `<space>`: Leader key (disabled)
- `L`: Jump to end of line
- `H`: Jump to start of line
- `<leader>p`: Paste without losing register contents
- `<A-j>`: Move selection down
- `<A-k>`: Move selection up
- `<<`: Indent left and reselect
- `>>`: Indent right and reselect

## Terminal Mode

- `<Esc>`: Exit terminal mode
- `jk`: Exit terminal mode
- `kj`: Exit terminal mode
- `<C-h>`: Navigate left
- `<C-j>`: Navigate down
- `<C-k>`: Navigate up
- `<C-l>`: Navigate right
- `<space>`: Insert space

## Commands (No Keybinds)

- `:ConformDisable`: Disable autoformatting on save
- `:ConformEnable`: Re-enable autoformatting on save
- `:lua vim.lsp.enable("eslint")`: Enable ESLint LSP server
- `:lua vim.lsp.disable("eslint")`: Disable ESLint LSP server
