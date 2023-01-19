vim.cmd("autocmd!") -- prevents loading autocommands more that one time
vim.opt.encoding = "utf-8" -- set default encoding to UTF-8
vim.script_encoding = "utf-8" -- set default encoding to UTF-8
vim.fileencoding = "utf-8" -- set save encoding to UTF-8
vim.opt.shortmess:append("c") -- don't give |ins-completion-menu| messages
vim.opt.wildignore:append({ "*/node_modules/*" }) -- ignore folders to speed up search etc.
vim.cmd([[colorscheme darkplus]]) -- apply theme
-- disable netrw (default file browser) as there are telescope and nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local options = {
	termguicolors = true, -- allow more than 8-bit terminal colors
	signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
	number = true, -- show line number
	autoindent = true, -- apply the indentation of the current line to the next
	smartcase = true, -- smart case
	smartindent = true, -- reacts to the syntax/style of the code you are editing
	swapfile = false, -- creates a swapfile
	hlsearch = false, -- highlight search results after search completed
	backup = false, -- don't create backup file
	backupskip = { "/tmp/*", "/private/tmp/*" }, -- skip backup for these folders
	writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
	showcmd = false, -- don't show keys pressed in command line
	cmdheight = 1, -- height of command line (one line)
	showmode = false, -- don't show mode (INSERT etc.)
	laststatus = 2, -- show status line always
	expandtab = true, -- convert tab to spaces
	sidescrolloff = 10, -- minimal number of screen columns either side of cursor if wrap is `false`
	scrolloff = 10, -- minimal number of screen columns either side of cursor if wrap is `false`
	shell = "fish", -- sets default terminal/shell to FISH
	ignorecase = true, -- case insensitive searching UNLESS /C or capital in search
	shiftwidth = 2, -- the number of spaces inserted for each indentation
	tabstop = 2, -- insert 2 spaces for a tab
	wrap = false, -- display lines as one long line
	linebreak = false, -- don't split words (works with wrap)
	cursorline = true, -- highlight the current line
}

for k, v in pairs(options) do
	vim.opt[k] = v
end
