require("lazy").setup({
  -- Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd[[colorscheme tokyonight]]
    end
  },

  -- Status bar
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({ options = { theme = "tokyonight" } })
    end,
  },

  -- Mason: LSP installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason-lspconfig: auto-install LSP servers
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls" },
      })
    end,
  },

  -- LSP Configuration (Neovim 0.11+ native API)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Get capabilities from cmp for better completion
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure LSP servers using new vim.lsp.config API
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })
      vim.lsp.config("pyright", { capabilities = capabilities })
      vim.lsp.config("ts_ls", { capabilities = capabilities })

      -- Enable LSP servers
      vim.lsp.enable({ "lua_ls", "pyright", "ts_ls" })

      -- LSP keybindings (activated when LSP attaches to buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)         -- Go to definition
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)               -- Show hover info
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)     -- Go to implementation
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)         -- Find references
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)     -- Rename symbol
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)-- Code actions
        end,
      })
    end,
  },

  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    dependencies = {
      -- Collection of common snippets
      "rafamadriz/friendly-snippets",
    },
    config = function()
      -- Load snippets from friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- Autocompletion engine
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",  -- Only load when entering insert mode
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- LSP completion source
      "hrsh7th/cmp-buffer",    -- Buffer words completion source
      "hrsh7th/cmp-path",      -- File path completion source
      "saadparwaiz1/cmp_luasnip", -- Snippet completion source
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        -- Snippet expansion configuration
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- Keybindings for completion menu
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),      -- Scroll docs up
          ["<C-f>"] = cmp.mapping.scroll_docs(4),       -- Scroll docs down
          ["<C-Space>"] = cmp.mapping.complete(),       -- Trigger completion manually
          ["<C-e>"] = cmp.mapping.abort(),              -- Close completion menu
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm selection
          -- Tab for snippet jumping and selection
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        -- Completion sources (ordered by priority)
        sources = cmp.config.sources({
          { name = "nvim_lsp" },  -- LSP suggestions (highest priority)
          { name = "luasnip" },   -- Snippet suggestions
          { name = "buffer" },    -- Words from current buffer
          { name = "path" },      -- File paths
        }),

        -- Visual appearance
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    end,
  },
})
 