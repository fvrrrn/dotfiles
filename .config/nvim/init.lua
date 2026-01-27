vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Quick config editing
vim.keymap.set("n", "<leader>rc", ":e $MYVIMRC<CR>", { desc = "Edit config" })
vim.keymap.set("n", "<leader>rl", ":so $MYVIMRC<CR>", { desc = "Reload config" })

-- Basic settings
vim.opt.number = false                              -- Line numbers
vim.opt.relativenumber = false                      -- Relative line numbers
vim.opt.cursorline = false                          -- Highlight current line
vim.opt.wrap = false                               -- Don't wrap lines
vim.opt.linebreak = false -- don't split words (works with wrap)
vim.opt.scrolloff = 10                             -- Keep 10 lines above/below cursor 
vim.opt.sidescrolloff = 8                          -- Keep 8 columns left/right of cursor

-- Indentation
vim.opt.tabstop = 2                                -- Tab width
vim.opt.shiftwidth = 2                             -- Indent width
vim.opt.softtabstop = 2                            -- Soft tab stop
vim.opt.expandtab = true                           -- Use spaces instead of tabs
vim.opt.smartindent = true                         -- Smart auto-indenting
vim.opt.autoindent = true                          -- Copy indent from current line

-- Search settings
vim.opt.ignorecase = true                          -- Case insensitive search
vim.opt.smartcase = true                           -- Case sensitive if uppercase in search
vim.opt.hlsearch = false                           -- Don't highlight search results 
vim.opt.incsearch = true                           -- Show matches as you type

-- Visual settings
vim.opt.termguicolors = true                       -- Enable 24-bit colors
vim.opt.signcolumn = "yes"                         -- Always show sign column
vim.opt.showmatch = true                           -- Highlight matching brackets
vim.opt.matchtime = 2                              -- How long to show matching bracket
vim.opt.cmdheight = 1                              -- Command line height
vim.opt.completeopt = "menuone,noinsert,noselect"  -- Completion options 
vim.opt.showmode = false                           -- Don't show mode in command line 
vim.opt.pumheight = 10                             -- Popup menu height 
vim.opt.pumblend = 10                              -- Popup menu transparency 
vim.opt.winblend = 0                               -- Floating window transparency 
vim.opt.conceallevel = 0                           -- Don't hide markup 
vim.opt.concealcursor = ""                         -- Don't hide cursor line markup 
vim.opt.lazyredraw = true                          -- Don't redraw during macros
vim.opt.showcmd = false -- don't show keys pressed in command line
vim.opt.laststatus = 2 -- show status line always

-- File handling
vim.opt.backup = false                             -- Don't create backup files
vim.opt.writebackup = false                        -- Don't create backup before writing
vim.opt.swapfile = false                           -- Don't create swap files
vim.opt.undofile = true                            -- Persistent undo
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")  -- Undo directory
vim.opt.updatetime = 300                           -- Faster completion
vim.opt.timeoutlen = 500                           -- Key timeout duration
vim.opt.ttimeoutlen = 0                            -- Key code timeout
vim.opt.autoread = true                            -- Auto reload files changed outside vim
vim.opt.autowrite = false                          -- Don't auto save

-- Behavior settings
vim.opt.hidden = true                              -- Allow hidden buffers
vim.opt.errorbells = false                         -- No error bells
vim.opt.backspace = "indent,eol,start"             -- Better backspace behavior
vim.opt.autochdir = false                          -- Don't auto change directory
vim.opt.iskeyword:append("-")                      -- Treat dash as part of word
vim.opt.path:append("**")                          -- include subdirectories in search
vim.opt.selection = "exclusive"                    -- Selection behavior
vim.opt.mouse = "a"                                -- Enable mouse support
-- TODO: check if append needed vim.opt.clipboard:append("unnamedplus")            -- Use system clipboard
vim.opt.clipboard = "unnamedplus"
vim.opt.modifiable = true                          -- Allow buffer modifications
vim.opt.encoding = "UTF-8"                         -- Set encoding
vim.script_encoding = "utf-8" -- set default encoding to UTF-8
vim.fileencoding = "utf-8" -- set save encoding to UTF-8

-- Split behavior
vim.opt.splitbelow = true                          -- Horizontal splits go below
vim.opt.splitright = true                          -- Vertical splits go right

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Quick file navigation
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>ff", ":find ", { desc = "Find file" })

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
vim.keymap.set("n", "<leader>wv", "<C-w>v") -- split window vertically
vim.keymap.set("n", "<leader>wh", "<C-w>s") -- split window horizontally
vim.keymap.set("n", "<leader>we", "<C-w>=") -- make split windows equal width & height
vim.keymap.set("n", "<leader>wx", ":close<CR>") -- close current split window

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- deprecated
-- vim.keymap.set("n", "m", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
-- vim.keymap.set("n", "M", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "<leader>m", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- navigate windows
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- move line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

vim.cmd("set keymap=russian-jcukenwin")
vim.cmd("set iminsert=0")
vim.cmd("set imsearch=0")

vim.opt.shell = "zsh" -- sets default terminal/shell to ZSH

vim.lsp.enable('lua_ls')
