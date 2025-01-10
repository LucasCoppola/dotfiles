-- Set up Windows-specific configurations
vim.opt.shell = 'pwsh.exe'  -- Use PowerShell as shell on Windows
vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
vim.opt.shellxquote = ''

-- Ensure correct path separators for Windows
vim.opt.shellslash = true

-- Set proper encoding
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- Load user configuration
require("user")
