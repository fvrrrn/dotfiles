vim.opt.encoding = "utf-8" -- set default encoding to UTF-8
vim.script_encoding = "utf-8" -- set default encoding to UTF-8
vim.fileencoding = "utf-8" -- set save encoding to UTF-8
-- vim.opt.shortmess:append("c") -- don't give |ins-completion-menu| messages
vim.opt.wildignore:append({ "*/node_modules/*" }) -- ignore folders to speed up search etc.
vim.opt.clipboard:append({ "unnamed" }) -- sync clipboard

vim.cmd("set keymap=russian-jcukenwin")
vim.cmd("set iminsert=0")
vim.cmd("set imsearch=0")

vim.g.zenbones = { darkness = "warm", italic_comments = false }
-- vim.g.zenbones_compat = 1

vim.opt.sidescrolloff = 10 -- minimal number of screen columns either side of cursor if wrap is `false`
vim.opt.scrolloff = 10 -- minimal number of screen columns either side of cursor if wrap is `false`
vim.opt.shell = "fish" -- sets default terminal/shell to FISH
vim.opt.ignorecase = true -- case insensitive searching UNLESS /C or capital in search
vim.opt.shiftwidth = 2 -- the number of spaces inserted for each indentation
vim.opt.tabstop = 2 -- insert 2 spaces for a tab
vim.opt.wrap = false -- display lines as one long line
vim.opt.linebreak = false -- don't split words (works with wrap)
vim.opt.cursorline = false -- highlight the current line
vim.opt.showcmd = false -- don't show keys pressed in command line
vim.opt.termguicolors = true -- allow more than 8-bit terminal colors
vim.opt.signcolumn = "yes" -- always show the sign column, otherwise it would shift the text each time
vim.opt.number = false -- show line number
vim.opt.autoindent = true -- apply the indentation of the current line to the next
vim.opt.smartcase = true -- smart case
vim.opt.smartindent = true -- reacts to the syntax/style of the code you are editing
vim.opt.swapfile = false -- creates a swapfile
vim.opt.hlsearch = true -- highlight search results after search completed
vim.opt.backup = false -- don't create backup file
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" } -- skip backup for these folders
vim.opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
vim.opt.cmdheight = 1 -- height of command line (one line)
vim.opt.showmode = true -- don't show mode (INSERT etc.)
vim.opt.laststatus = 2 -- show status line always
vim.opt.expandtab = true -- convert tab to spaces
