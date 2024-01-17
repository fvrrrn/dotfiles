-- local present_virtual_text, dap_vt = pcall(require, "nvim-dap-virtual-text")
-- local present_dap_utils, dap_utils = pcall(require, "dap.utils")
-- local _, shade = pcall(require, "shade")

-- if not present_dapui or not present_dap or not present_virtual_text or not present_dap_utils then
--   vim.notify("Missing dap dependencies")
--   return
-- end
return {
  -- {
  --   "mfussenegger/nvim-dap",
  --   dependencies = {
  --     "rcarriga/nvim-dap-ui",
  --     -- "williamboman/mason-lspconfig.nvim",
  --     -- "williamboman/mason.nvim",
  --     "williamboman/mason-lspconfig.nvim",
  --     "mxsdev/nvim-dap-vscode-js",
  --   },
  --   config = function()
  --     local dap = require("dap")
  --     local dapui = require("dapui")
  --
  --     -- require("mason-lspconfig").setup({
  --     --   ensure_installed = {
  --     --     -- dap
  --     --     "js-debug-adapter",
  --     --   },
  --     --   automatic_installation = true,
  --     -- })
  --     --
  --     local keymap = vim.keymap.set
  --     local opts = { noremap = true, silent = true }
  --     -- -- ╭──────────────────────────────────────────────────────────╮
  --     -- -- │ DAP Virtual Text Setup                                   │
  --     -- -- ╰──────────────────────────────────────────────────────────╯
  --     -- dap_vt.setup({
  --     --   enabled = true, -- enable this plugin (the default)
  --     --   enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
  --     --   highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
  --     --   highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
  --     --   show_stop_reason = true, -- show stop reason when stopped for exceptions
  --     --   commented = false, -- prefix virtual text with comment string
  --     --   only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
  --     --   all_references = false, -- show virtual text on all all references of the variable (not only definitions)
  --     --   filter_references_pattern = "<module", -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
  --     --   -- Experimental Features:
  --     --   virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
  --     --   all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
  --     --   virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
  --     --   virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
  --     -- })
  --
  --     -- ╭──────────────────────────────────────────────────────────╮
  --     -- │ DAP UI Setup                                             │
  --     -- ╰──────────────────────────────────────────────────────────╯
  --     dapui.setup({
  --       icons = { expanded = "▾", collapsed = "▸" },
  --       mappings = {
  --         -- Use a table to apply multiple mappings
  --         expand = { "<CR>", "<2-LeftMouse>" },
  --         open = "o",
  --         remove = "d",
  --         edit = "e",
  --         repl = "r",
  --         toggle = "t",
  --       },
  --       -- Expand lines larger than the window
  --       -- Requires >= 0.7
  --       expand_lines = vim.fn.has("nvim-0.7"),
  --       -- Layouts define sections of the screen to place windows.
  --       -- The position can be "left", "right", "top" or "bottom".
  --       -- The size specifies the height/width depending on position. It can be an Int
  --       -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  --       -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  --       -- Elements are the elements shown in the layout (in order).
  --       -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  --       layouts = {
  --         {
  --           elements = {
  --             -- Elements can be strings or table with id and size keys.
  --             { id = "scopes", size = 0.25 },
  --             "breakpoints",
  --             "stacks",
  --             "watches",
  --           },
  --           size = 40, -- 40 columns
  --           position = "left",
  --         },
  --         {
  --           elements = {
  --             "repl",
  --             "console",
  --           },
  --           size = 0.25, -- 25% of total lines
  --           position = "bottom",
  --         },
  --       },
  --       floating = {
  --         max_height = nil, -- These can be integers or a float between 0 and 1.
  --         max_width = nil, -- Floats will be treated as percentage of your screen.
  --         border = "single", -- Border style. Can be "single", "double" or "rounded"
  --         mappings = {
  --           close = { "q", "<Esc>" },
  --         },
  --       },
  --       windows = { indent = 1 },
  --       render = {
  --         max_type_length = nil, -- Can be integer or nil.
  --       },
  --     })
  --
  --     -- ╭──────────────────────────────────────────────────────────╮
  --     -- │ DAP Setup                                                │
  --     -- ╰──────────────────────────────────────────────────────────╯
  --     dap.set_log_level("TRACE")
  --
  --     -- Automatically open UI
  --     dap.listeners.after.event_initialized["dapui_config"] = function()
  --       dapui.open()
  --       -- shade.toggle()
  --     end
  --     dap.listeners.after.event_terminated["dapui_config"] = function()
  --       dapui.close()
  --       -- shade.toggle()
  --     end
  --     dap.listeners.before.event_exited["dapui_config"] = function()
  --       dapui.close()
  --       -- shade.toggle()
  --     end
  --
  --     -- Enable virtual text
  --     vim.g.dap_virtual_text = true
  --
  --     -- -- ╭──────────────────────────────────────────────────────────╮
  --     -- -- │ Icons                                                    │
  --     -- -- ╰──────────────────────────────────────────────────────────╯
  --     -- vim.fn.sign_define("DapBreakpoint", { text = "🟥", texthl = "", linehl = "", numhl = "" })
  --     -- vim.fn.sign_define("DapStopped", { text = "⭐️", texthl = "", linehl = "", numhl = "" })
  --
  --     -- ╭──────────────────────────────────────────────────────────╮
  --     -- │ Keybindings                                              │
  --     -- ╰──────────────────────────────────────────────────────────╯
  --     keymap("n", "<Leader>da", "<CMD>lua require('dap').continue()<CR>", opts)
  --     keymap("n", "<Leader>db", "<CMD>lua require('dap').toggle_breakpoint()<CR>", opts)
  --     keymap("n", "<Leader>dc", "<CMD>lua require('dap').continue()<CR>", opts)
  --     keymap("n", "<Leader>dd", "<CMD>lua require('dap').continue()<CR>", opts)
  --     keymap("n", "<Leader>dh", "<CMD>lua require('dapui').eval()<CR>", opts)
  --     keymap("n", "<Leader>di", "<CMD>lua require('dap').step_into()<CR>", opts)
  --     keymap("n", "<Leader>do", "<CMD>lua require('dap').step_out()<CR>", opts)
  --     keymap("n", "<Leader>dO", "<CMD>lua require('dap').step_over()<CR>", opts)
  --     keymap("n", "<Leader>dt", "<CMD>lua require('dap').terminate()<CR>", opts)
  --     keymap("n", "<Leader>dU", "<CMD>lua require('dapui').open()<CR>", opts)
  --     keymap("n", "<Leader>dC", "<CMD>lua require('dapui').close()<CR>", opts)
  --
  --     keymap("n", "<Leader>dw", "<CMD>lua require('dapui').float_element('watches', { enter = true })<CR>", opts)
  --     keymap("n", "<Leader>ds", "<CMD>lua require('dapui').float_element('scopes', { enter = true })<CR>", opts)
  --     keymap("n", "<Leader>dr", "<CMD>lua require('dapui').float_element('repl', { enter = true })<CR>", opts)
  --
  --     -- ╭──────────────────────────────────────────────────────────╮
  --     -- │ Adapters                                                 │
  --     -- ╰──────────────────────────────────────────────────────────╯
  --
  --     -- VSCODE JS (Node/Chrome/Terminal/Jest)
  --     require("dap-vscode-js").setup({
  --       debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
  --       debugger_cmd = { "js-debug-adapter" },
  --       adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
  --     })
  --
  --     -- ╭──────────────────────────────────────────────────────────╮
  --     -- │ Configurations                                           │
  --     -- ╰──────────────────────────────────────────────────────────╯
  --     local exts = {
  --       "javascript",
  --       "typescript",
  --       "javascriptreact",
  --       "typescriptreact",
  --       "vue",
  --       "svelte",
  --     }
  --
  --     for i, ext in ipairs(exts) do
  --       dap.configurations[ext] = {
  --         {
  --           type = "pwa-chrome",
  --           request = "launch",
  --           name = 'Launch Chrome with "localhost"',
  --           url = "https://localapp.dev.cyberprod.ru:3443/",
  --           port = 9222,
  --           webRoot = "${workspaceFolder}",
  --         },
  --         {
  --           type = "pwa-node",
  --           request = "launch",
  --           name = "Launch Current File (pwa-node)",
  --           cwd = vim.fn.getcwd(),
  --           args = { "${file}" },
  --           sourceMaps = true,
  --           protocol = "inspector",
  --         },
  --         {
  --           type = "pwa-node",
  --           request = "launch",
  --           name = "Launch Current File (pwa-node with ts-node)",
  --           cwd = vim.fn.getcwd(),
  --           runtimeArgs = { "--loader", "ts-node/esm" },
  --           runtimeExecutable = "node",
  --           args = { "${file}" },
  --           sourceMaps = true,
  --           protocol = "inspector",
  --           skipFiles = { "<node_internals>/**", "node_modules/**" },
  --           resolveSourceMapLocations = {
  --             "${workspaceFolder}/**",
  --             "!**/node_modules/**",
  --           },
  --         },
  --         {
  --           type = "pwa-node",
  --           request = "launch",
  --           name = "Launch Current File (pwa-node with deno)",
  --           cwd = vim.fn.getcwd(),
  --           runtimeArgs = { "run", "--inspect-brk", "--allow-all", "${file}" },
  --           runtimeExecutable = "deno",
  --           attachSimplePort = 9229,
  --         },
  --         {
  --           type = "pwa-node",
  --           request = "launch",
  --           name = "Launch Test Current File (pwa-node with jest)",
  --           cwd = vim.fn.getcwd(),
  --           runtimeArgs = { "${workspaceFolder}/node_modules/.bin/jest" },
  --           runtimeExecutable = "node",
  --           args = { "${file}", "--coverage", "false" },
  --           rootPath = "${workspaceFolder}",
  --           sourceMaps = true,
  --           console = "integratedTerminal",
  --           internalConsoleOptions = "neverOpen",
  --           skipFiles = { "<node_internals>/**", "node_modules/**" },
  --         },
  --         {
  --           type = "pwa-node",
  --           request = "launch",
  --           name = "Launch Test Current File (pwa-node with vitest)",
  --           cwd = vim.fn.getcwd(),
  --           program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
  --           args = { "--inspect-brk", "--threads", "false", "run", "${file}" },
  --           autoAttachChildProcesses = true,
  --           smartStep = true,
  --           console = "integratedTerminal",
  --           skipFiles = { "<node_internals>/**", "node_modules/**" },
  --         },
  --         {
  --           type = "pwa-node",
  --           request = "launch",
  --           name = "Launch Test Current File (pwa-node with deno)",
  --           cwd = vim.fn.getcwd(),
  --           runtimeArgs = { "test", "--inspect-brk", "--allow-all", "${file}" },
  --           runtimeExecutable = "deno",
  --           attachSimplePort = 9229,
  --         },
  --         {
  --           type = "pwa-chrome",
  --           request = "attach",
  --           name = "Attach Program (pwa-chrome, select port)",
  --           program = "${file}",
  --           cwd = vim.fn.getcwd(),
  --           sourceMaps = true,
  --           port = function()
  --             return vim.fn.input("Select port: ", 9222)
  --           end,
  --           webRoot = "${workspaceFolder}",
  --         },
  --         -- {
  --         --   type = "pwa-node",
  --         --   request = "attach",
  --         --   name = "Attach Program (pwa-node, select pid)",
  --         --   cwd = vim.fn.getcwd(),
  --         --   processId = dap.utils.pick_process,
  --         --   skipFiles = { "<node_internals>/**" },
  --         -- },
  --       }
  --     end
  --   end,
  -- },
  {
    "mfussenegger/nvim-dap",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mxsdev/nvim-dap-vscode-js",
      -- build debugger from source
      {
        "microsoft/vscode-js-debug",
        version = "1.x",
        build = "npm i && npm run compile vsDebugServerBundle && mv dist out",
      },
    },
    keys = {
      -- normal mode is default
      {
        "<leader>d",
        function()
          require("dap").toggle_breakpoint()
        end,
      },
      {
        "<leader>c",
        function()
          require("dap").continue()
        end,
      },
      {
        "<C-'>",
        function()
          require("dap").step_over()
        end,
      },
      {
        "<C-;>",
        function()
          require("dap").step_into()
        end,
      },
      {
        "<C-:>",
        function()
          require("dap").step_out()
        end,
      },
    },
    config = function()
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
      })

      for _, language in ipairs({ "typescript", "javascript", "svelte", "typescriptreact", "javascriptreact" }) do
        require("dap").configurations[language] = {
          -- attach to a node process that has been started with
          -- `--inspect` for longrunning tasks or `--inspect-brk` for short tasks
          -- npm script -> `node --inspect-brk ./node_modules/.bin/vite dev`
          {
            -- use nvim-dap-vscode-js's pwa-node debug adapter
            type = "pwa-node",
            -- attach to an already running node process with --inspect flag
            -- default port: 9222
            request = "attach",
            -- allows us to pick the process using a picker
            processId = require("dap.utils").pick_process,
            -- name of the debug action you have to select for this config
            name = "Attach debugger to existing `node --inspect` process",
            -- for compiled languages like TypeScript or Svelte.js
            sourceMaps = true,
            -- resolve source maps in nested locations while ignoring node_modules
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
            -- path to src in vite based projects (and most other projects as well)
            cwd = "${workspaceFolder}/src",
            -- we don't want to debug code inside node_modules, so skip it!
            skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
          },
          {
            type = "pwa-chrome",
            name = "Launch Chrome to debug client",
            request = "launch",
            url = "http://localhost:5173",
            sourceMaps = true,
            protocol = "inspector",
            port = 9222,
            webRoot = "${workspaceFolder}/src",
            -- skip files from vite's hmr
            skipFiles = { "**/node_modules/**/*", "**/@vite/*", "**/src/client/*", "**/src/*" },
          },
          -- only if language is javascript, offer this debug action
          language == "javascript"
              and {
                -- use nvim-dap-vscode-js's pwa-node debug adapter
                type = "pwa-node",
                -- launch a new process to attach the debugger to
                request = "launch",
                -- name of the debug action you have to select for this config
                name = "Launch file in new node process",
                -- launch current file
                program = "${file}",
                cwd = "${workspaceFolder}",
              }
            or nil,
        }
      end

      require("dapui").setup()
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({ reset = true })
      end
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close
    end,
  },
}
