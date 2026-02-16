return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		cmd = { "LspInfo", "LspInstall", "LspUninstall", "Mason" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"j-hui/fidget.nvim",
		},
		config = function()
			local map_lsp_keybinds = require("user.keymaps").map_lsp_keybinds

			-- Custom LspRestart that actually works
			vim.api.nvim_create_user_command("LspRestart", function()
				vim.lsp.stop_client(vim.lsp.get_clients())
				vim.defer_fn(function()
					vim.cmd("edit")
				end, 100)
			end, { desc = "Restart all LSP clients" })

			-- LSP server configurations
			local servers = {
				bashls = {},
				cssls = {},
				gopls = {
					root_markers = { "go.mod", ".git" },
				},
				clangd = {
					autostart = true,
					cmd = { "clangd" },
					filetypes = { "c", "h" },
					root_markers = {
						"compile_commands.json",
						"compile_flags.txt",
						".git",
					},
				},
				eslint = {
					autostart = false,
					cmd = { "vscode-eslint-language-server", "--stdio", "--max-old-space-size=12288" },
					settings = {
						format = false,
					},
				},
				html = {},
				jsonls = {},
				lua_ls = {
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
								library = {
									"${3rd}/luv/library",
									unpack(vim.api.nvim_get_runtime_file("", true)),
								},
							},
							telemetry = { enabled = false },
						},
					},
				},
				marksman = {},
				sqlls = {},
				oxc_language_server = {
					cmd = { "oxc_language_server" },
					root_markers = { "package.json", "tsconfig.json", ".git" },
					settings = {
						oxc = {
							typeAware = true,
						},
					},
				},
				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							check = {
								command = "clippy",
							},
						},
					},
				},
				tailwindcss = {},
				yamlls = {},
			}

			local formatters = {
				prettierd = {},
				stylua = {},
			}

			local mason_tools_to_install = vim.tbl_keys(vim.tbl_deep_extend("force", {}, servers, formatters))

			require("mason-tool-installer").setup({
				auto_update = true,
				run_on_start = true,
				start_delay = 3000,
				debounce_hours = 12,
				ensure_installed = mason_tools_to_install,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- Use Blink.cmp capabilities if available, fallback to cmp_nvim_lsp
			local has_blink, blink = pcall(require, "blink.cmp")
			if has_blink then
				capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities())
			else
				local has_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
				if has_cmp then
					capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
				end
			end

			-- Setup LspAttach autocmd for keybindings (replaces on_attach)
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local bufnr = event.buf
					local bufname = vim.api.nvim_buf_get_name(bufnr)

					-- Detach from non-file buffers (diffview, fugitive, etc.)
					if bufname == "" or bufname:match("^diffview://") or bufname:match("^fugitive://") then
						vim.schedule(function()
							vim.lsp.buf_detach_client(bufnr, event.data.client_id)
						end)
						return
					end

					map_lsp_keybinds(bufnr)
				end,
			})

			-- Setup each LSP server using the new vim.lsp.config API
			for name, config in pairs(servers) do
				-- Configure the server (only pass non-nil values)
				local lsp_config = { capabilities = capabilities }
				if config.cmd then
					lsp_config.cmd = config.cmd
				end
				if config.filetypes then
					lsp_config.filetypes = config.filetypes
				end
				if config.settings then
					lsp_config.settings = config.settings
				end
				if config.root_dir then
					lsp_config.root_dir = config.root_dir
				end
				if config.root_markers then
					lsp_config.root_markers = config.root_markers
				end

				vim.lsp.config(name, lsp_config)

				-- Enable the server (with autostart setting if specified)
				if config.autostart == false then
					-- Don't auto-enable servers with autostart = false
					-- Users can manually enable with :lua vim.lsp.enable(name)
				else
					vim.lsp.enable(name)
				end
			end

			-- Setup mason
			require("mason").setup({
				ui = {
					border = "rounded",
				},
			})

			require("mason-lspconfig").setup()

			-- Configure diagnostics border
			vim.diagnostic.config({
				float = {
					border = "rounded",
				},
			})
		end,
	},
}
