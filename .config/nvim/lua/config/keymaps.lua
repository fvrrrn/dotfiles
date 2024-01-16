vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

vim.keymap.set("", "f", function()
  require("hop").hint_words()
end, { remap = true })

-- window management
vim.keymap.set("n", "<leader>wv", "<C-w>v") -- split window vertically
vim.keymap.set("n", "<leader>wh", "<C-w>s") -- split window horizontally
vim.keymap.set("n", "<leader>we", "<C-w>=") -- make split windows equal width & height
vim.keymap.set("n", "<leader>wx", ":close<CR>") -- close current split window

-- navigate windows
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
