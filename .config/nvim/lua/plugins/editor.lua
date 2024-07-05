return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-ui-select.nvim" },
    -- keys = {
    --   { "n", "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Fuzzy find files in cwd" },
    --   { "n", "<leader>fs", "<cmd>Telescope live_grep<CR>", desc = "Fuzzy find string in cwd" },
    --   { "n", "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find string in cwd" },
    --   { "n", "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Find string under cursor in cwd" },
    -- },
    config = function()
      local telescope = require("telescope")

      -- vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Fuzzy find files in cwd" })
      -- vim.keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<CR>", { desc = "Fuzzy find string in cwd" })
      -- vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find string in cwd" })
      -- vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Find string under cursor in cwd" })

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            "yarn%.lock",
            "node_modules/",
            "raycast/",
            "dist/",
            "%.next",
            "%.git/",
            "%.gitlab/",
            "build/",
            "target/",
            "package%-lock%.json",
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
        -- pickers = {
        --   find_files = {
        --     find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
        --   },
        -- },
      })

      -- TODO: add fzf
      telescope.load_extension("ui-select")

      -- See `:help telescope.builtin`
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>r", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[ ] Find existing buffers" })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = true,
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- import nvim-treesitter plugin
      local treesitter = require("nvim-treesitter.configs")

      -- configure treesitter
      treesitter.setup({ -- enable syntax highlighting
        highlight = {
          enable = true,
        },
        -- enable indentation
        indent = { enable = false },
        -- ensure these language parsers are installed
        ensure_installed = {
          -- web
          "html",
          "css",
          "javascript",
          "typescript",
          "tsx",

          "haskell",

          -- config
          "json",
          "yaml",
          "toml",

          -- scripts
          "bash",
          "lua",

          -- documentation
          "markdown",
          "markdown_inline",
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            node_incremental = "i",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },
          lsp_interop = {
            enable = true,
            border = "none",
            floating_preview_opts = {},
            peek_definition_code = {
              ["<leader>df"] = "@function.outer",
              ["<leader>dF"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      -- import comment plugin safely
      local comment = require("Comment")

      local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

      -- enable comment
      comment.setup({
        -- for commenting tsx and jsx files
        pre_hook = ts_context_commentstring.create_pre_hook(),
      })
    end,
  },
  {
    "smoka7/hop.nvim",
    version = "*",
    -- keys = {
    --   { "<silent>", "f", "<cmd>HopAnywhere<CR>", desc = "Start search for word start anywhere", silent = true },
    -- },
    opts = function()
      vim.keymap.set("", "f", "<cmd>HopWord<CR>", { desc = "Start search for word start anywhere" })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },
}
