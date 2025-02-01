return{
    {
        "pappasam/jedi-language-server",
        config = function()
            require("lspconfig").jedi_language_server.setup({
                cmd = { "jedi-language-server" },
                filetypes = { "python" },
                root_dir = require("lspconfig").util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt"),
                settings = {
                    jedi = {
                        enable = true,
                    },
                },
            })
        end
    },
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls"}
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            local lspconfig = require("lspconfig")
            lspconfig.lua_ls.setup({
                capabilities = capabilities
            })

            lspconfig.clangd.setup({
                capabilities = capabilities,
                cmd = { "clangd" },  -- Assure-toi que clangd est bien installé
                filetypes = { "c", "cpp", "objc", "objcpp" },
                root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
            })

            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
        end
    },
}
