vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/stevearc/oil.nvim",
  { src = "https://github.com/smoka7/hop.nvim", version = vim.version.range("*") },
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/rktjmp/lush.nvim",
  "https://github.com/mcchrish/zenbones.nvim",
  "https://github.com/hkupty/iron.nvim",
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("*") },
  "https://github.com/mg979/vim-visual-multi",
})

-- NAVIGATION/FZF-LUA
local fzf = require("fzf-lua")
fzf.setup({
  "ivy",
  winopts = { preview = { winopts = { number = false } } },
})
fzf.register_ui_select()
vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "Search help" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "Search keymaps" })
vim.keymap.set("n", "<C-f>", fzf.files, { desc = "Search files" })
vim.keymap.set("n", "<S-f>", fzf.live_grep, { desc = "Search by grep" })
vim.keymap.set("n", "<leader>fd", fzf.diagnostics_workspace, { desc = "Search diagnostics" })
vim.keymap.set("n", "<leader>r", fzf.resume, { desc = "Search resume" })
vim.keymap.set("n", "<leader>s.", fzf.oldfiles, { desc = "Search recent files" })
vim.keymap.set("n", "<C-b>", fzf.buffers, { desc = "Search buffers" })
vim.keymap.set("n", "<leader>/", fzf.lgrep_curbuf, { desc = "Search current buffer" })

-- OIL
require("oil").setup({})

-- NAVIGATION/HOP
require("hop").setup({})
vim.keymap.set("", "f", "<cmd>HopWord<CR>", { desc = "Start search for word start anywhere" })

-- GIT
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map("n", "q", function()
      if vim.wo.diff then
        vim.cmd.normal({ "q", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, { desc = "Jump to next git [c]hange", silent = true })

    map("n", "Q", function()
      if vim.wo.diff then
        vim.cmd.normal({ "q", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, { desc = "Jump to previous git [c]hange", silent = true })

    map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk" })
    map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
    map("v", "<leader>hs", function()
      gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "Stage hunk" })
    map("v", "<leader>hr", function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "Reset hunk" })
    map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage buffer" })
    map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
    map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset buffer" })
    map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
    map("n", "<leader>hb", function()
      gitsigns.blame_line({ full = true })
    end, { desc = "Blame line" })
    map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle current line blame" })
    map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff buffer" })
    map("n", "<leader>hD", function()
      gitsigns.diffthis("~")
    end)
    map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "Toggle deleted" })
  end,
})

-- FORMATTING
require("conform").setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    return {
      timeout_ms = 500,
      lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
    }
  end,
  formatters_by_ft = {
    python = { "ruff_format", "ruff_organize_imports" },
    lua = { "stylua" },
    nix = { "alejandra" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    cmake = { "cmake_format" },
    sh = { "shfmt" },
    json = { "jq" },
    javascript = { "biome-organize-imports", "biome" },
    jsx = { "biome-organize-imports", "biome" },
    tsx = { "biome-organize-imports", "biome" },
    typescript = { "biome-organize-imports", "biome" },
    tex = { "tex-fmt" },
  },
})

-- COLOR SCHEME
local grpid = vim.api.nvim_create_augroup("custom_highlights", {})
vim.api.nvim_create_autocmd("ColorScheme", {
  group = grpid,
  pattern = "*bones",
  command = "hi Comment  gui=NONE |" .. "hi Constant gui=NONE",
})
vim.api.nvim_command("colorscheme zenbones")
vim.o.background = "dark"

-- IRON
local common = require("iron.fts.common")
local iron = require("iron.core")
local view = require("iron.view")

iron.setup({
  config = {
    scratch_repl = true,
    repl_definition = {
      sh = {
        command = { "zsh" },
      },
      python = {
        command = { "python3" },
        format = common.bracketed_paste_python,
        block_dividers = { "# %%", "#%%" },
        env = { PYTHON_BASIC_REPL = "1" },
      },
    },
    repl_filetype = function(_, ft)
      return ft
    end,
    repl_open_cmd = view.split.vertical.botright(50),
  },
  keymaps = {
    toggle_repl = "<space>rr",
    restart_repl = "<space>rR",
    send_motion = "<space>sc",
    visual_send = "<space>sc",
    send_file = "<space>sf",
    send_line = "<space>sl",
    send_paragraph = "<space>sp",
    send_until_cursor = "<space>su",
    send_mark = "<space>sm",
    send_code_block = "<space>sb",
    send_code_block_and_move = "<space>sn",
    mark_motion = "<space>mc",
    mark_visual = "<space>mc",
    remove_mark = "<space>md",
    cr = "<space>s<cr>",
    interrupt = "<space>s<space>",
    exit = "<space>sq",
    clear = "<space>cl",
  },
  highlight = {
    italic = true,
  },
  ignore_blank_lines = true,
})

-- COMPLETION
require("blink.cmp").setup({
  keymap = {
    ["<CR>"] = { "accept", "fallback" },
    ["<C-e>"] = { "hide", "fallback" },
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev" },
  },
})

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.python3_host_prog = vim.fn.exepath("python3")

-- Quick config editing
vim.keymap.set("n", "<leader>rc", ":e $MYVIMRC<CR>", { desc = "Edit config" })
vim.keymap.set("n", "<leader>rl", ":so $MYVIMRC<CR>", { desc = "Reload config" })

-- Basic settings
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.cursorline = false
vim.opt.wrap = false
vim.opt.linebreak = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Visual settings
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.cmdheight = 1

vim.o.completeopt = "menu,noinsert,popup,fuzzy"
vim.opt.showmode = false
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.winblend = 0
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
vim.opt.lazyredraw = true
vim.opt.showcmd = false
vim.opt.laststatus = 2

-- File handling
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.autowrite = false

-- Behavior settings
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.autochdir = false
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")
vim.opt.selection = "inclusive"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.modifiable = true
vim.opt.encoding = "UTF-8"
vim.script_encoding = "utf-8"
vim.fileencoding = "utf-8"

-- Split behavior
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Do things without affecting the registers
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "<silent>p", '"0p')
vim.keymap.set("n", "<silent>P", '"0P')
vim.keymap.set("v", "<silent>p", '"0p')
vim.keymap.set("n", "<silent>c", '"_c')
vim.keymap.set("n", "<silent>C", '"_C')
vim.keymap.set("v", "<silent>c", '"_c')
vim.keymap.set("v", "<silent>C", '"_C')
vim.keymap.set("n", "<silent>d", '"_d')
vim.keymap.set("n", "<silent>D", '"_D')
vim.keymap.set("v", "<silent>d", '"_d')
vim.keymap.set("v", "<silent>D", '"_D')

-- window management
vim.keymap.set("n", "<leader>wv", "<C-w>v")
vim.keymap.set("n", "<leader>wh", "<C-w>s")
vim.keymap.set("n", "<leader>we", "<C-w>=")
vim.keymap.set("n", "<leader>wx", ":close<CR>")

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>m", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- navigate windows
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- move line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.cmd("set keymap=russian-jcukenwin")
vim.cmd("set iminsert=0")
vim.cmd("set imsearch=0")
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

vim.opt.shell = "zsh"

local capabilities = vim.lsp.protocol.make_client_capabilities()

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".stylua.toml",
    "stylua.toml",
    ".git",
  },
  capabilities = capabilities,
  settings = {
    Lua = {
      completion = { callSnippet = "Replace" },
    },
  },
})

vim.lsp.config("biome", {
  cmd = { "biome", "lsp-proxy" },
  filetypes = {
    "astro",
    "css",
    "graphql",
    "javascript",
    "javascriptreact",
    "json",
    "jsonc",
    "svelte",
    "typescript",
    "typescriptreact",
    "vue",
  },
  capabilities = capabilities,
  workspace_required = true,
})

vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  capabilities = capabilities,
  root_markers = { "setup.py", "setup.cfg", "requirements.txt", "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        typeCheckingMode = "standard",
        diagnosticMode = "openFilesOnly",
      },
    },
  },
})

vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
})

vim.lsp.config("taplo", {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  root_markers = { ".taplo.toml", "taplo.toml", ".git" },
})

vim.lsp.config("nil", {
  cmd = { "nil" },
  capabilities = capabilities,
  filetypes = { "nix" },
  root_markers = { "flake.nix", ".git" },
})

vim.lsp.config("texlab", {
  filetypes = { "tex", "plaintex", "bib" },
  cmd = { "texlab" },
  root_markers = { ".git", "main.tex" },
  settings = {
    texlab = {
      bibtexFormatter = "texlab",
      build = {
        onSave = false,
        onType = false,
      },
      diagnosticDelay = 100,
      formatterLineLength = 80,
      forwardSearch = {
        args = {},
      },
    },
  },
  single_file_support = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "m", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts)
    vim.keymap.set("n", "M", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts)
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

vim.lsp.enable({ "lua_ls", "basedpyright", "ruff", "nil", "biome", "texlab", "taplo" })

-- TREESITTER
require("nvim-treesitter").setup()

vim.api.nvim_create_autocmd("FileType", { -- enable treesitter highlighting and indents
  callback = function(args)
    local filetype = args.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if vim.treesitter.language.add(lang) then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.treesitter.start()
    end
  end,
})

vim.keymap.set("v", "v", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require("vim.treesitter._select").select_parent(vim.v.count1)
  else
    vim.lsp.buf.selection_range(vim.v.count1)
  end
end, { desc = "Select parent treesitter node or outer incremental lsp selections" })

vim.keymap.set("v", "V", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require("vim.treesitter._select").select_child(vim.v.count1)
  else
    vim.lsp.buf.selection_range(-vim.v.count1)
  end
end, { desc = "Select child treesitter node or inner incremental lsp selections" })
