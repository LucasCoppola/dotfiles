return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost" },
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

			local ts_ls_inlay_hints = {
				includeInlayEnumMemberValueHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
			}

			local on_attach = function(_client, buffer_number)
				map_lsp_keybinds(buffer_number)
			end

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

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
				tailwindcss = {},
				ts_ls = {
					root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
					settings = {
						typescript = {
							inlayHints = ts_ls_inlay_hints,
						},
						javascript = {
							inlayHints = ts_ls_inlay_hints,
						},
						completions = {
							completeFunctionCalls = true,
						},
					},
				},
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

			-- Configure each LSP server
			for name, config in pairs(servers) do
				vim.lsp.config(name, {
					cmd = config.cmd,
					capabilities = capabilities,
					filetypes = config.filetypes,
					handlers = config.handlers,
					root_markers = config.root_markers, -- Use root_markers, not root_dir
					settings = config.settings,
				})
			end

			-- Enable LSP servers on appropriate filetypes
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					-- Map of filetypes to LSP server names
					local filetype_to_lsp = {
						sh = "bashls",
						css = "cssls",
						go = "gopls",
						c = "clangd",
						h = "clangd",
						html = "html",
						json = "jsonls",
						lua = "lua_ls",
						markdown = "marksman",
						sql = "sqlls",
						typescript = "ts_ls",
						typescriptreact = "ts_ls",
						javascript = "ts_ls",
						javascriptreact = "ts_ls",
						yaml = "yamlls",
					}

					local lsp_name = filetype_to_lsp[event.match]
					if lsp_name then
						vim.lsp.enable(lsp_name)
						-- Run on_attach callback
						on_attach(nil, event.buf)
					end
				end,
			})

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
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
			notify_on_error = false,
			default_format_opts = {
				async = true,
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			format_after_save = {
				async = true,
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				javascript = { "prettierd" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				lua = { "stylua" },
			},
		},
	},
}
