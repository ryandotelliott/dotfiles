-- Ensurelazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load lazy.nvim
require("lazy").setup({

    -- Gruvbox color scheme
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            vim.o.background = "dark"
            require("gruvbox").setup()
            vim.cmd("colorscheme gruvbox")
        end,
    },

    -- Mason (LSP Installer)
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright", "ts_ls" },
            })
        end,
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")
            lspconfig.lua_ls.setup({
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" }
                        }
                    }
                }
            })
            lspconfig.pyright.setup({})
            lspconfig.ts_ls.setup({})
        end,
    },

    -- Autocompletion framework
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",    -- LSP source
            "hrsh7th/cmp-buffer",      -- Buffer source
            "hrsh7th/cmp-path",        -- Path source
            "hrsh7th/cmp-cmdline",     -- Command line completion
            "L3MON4D3/LuaSnip",        -- Snippet engine
            "saadparwaiz1/cmp_luasnip" -- Snippet completions
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },

    -- Tree-sitter for better syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "python", "javascript", "bash" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- File explorer (NvimTree)
    -- {
    --     "nvim-tree/nvim-tree.lua",
    --     dependencies = { "nvim-tree/nvim-web-devicons" },
    --     config = function()
    --         require("nvim-tree").setup({})
    --         vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
    --     end,
    -- },

    -- Telescoping File Browser
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    },

    -- Status line (Lualine)
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({ options = { theme = "gruvbox" } })
        end,
    },

    -- Fuzzy finder (Telescope)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup()
            vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
            vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")
        end,
    },


    -- Which Key
    {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup()
        end,
    },

    -- Targets
    {
        'wellle/targets.vim',
    },

    -- Nvim Surround
    {
        "kylechui/nvim-surround",
        version = "^3.0.0",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end
    },

    -- Nvim Autopairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true
    }

    -- Vim Easymotion


})


-- Key Mappings
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })
vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "Show hover info" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action (autofix)" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostics in float" })
-- vim.keymap.set("n", "<leader>t", function()
--     require("nvim-tree.api").tree.toggle()
-- end, { desc = "Toggle file tree" })
vim.keymap.set(
    "n",
    "<space>fb",
    function()
        require("telescope").extensions.file_browser.file_browser({
        path = "%:p:h",
        select_buffer = true,
        initial_mode = "normal",
    })
    end,
    { noremap = true, silent = true }
)

-- Autorun Commands
local function open_nvim_tree(data)
    local directory = vim.fn.isdirectory(data.file) == 1

    if not directory then return end
    vim.cmd.cd(data.file)
    require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = open_nvim_tree,
})


vim.g.clipboard = {
    name = "wsl-clip",
    copy = {
        ["+"] = "clip.exe",
        ["*"] = "clip.exe",
    },
    paste = {
        ["+"] = "powershell.exe -noprofile -command Get-Clipboard",
        ["*"] = "powershell.exe -noprofile -command Get-Clipboard",

    },
    cache_enabled = false,
}
