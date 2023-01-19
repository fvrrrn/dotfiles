local keymap = vim.keymap

keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local options = {
	silent = true,
	noremap = true,
}

keymap.set("n", "x", '"_x') -- don't yank when x-ing
keymap.set("n", "<leader>f", ":Telescope live_grep<cr>", options)
keymap.set("n", "<leader>e", ":Telescope find_files<cr>", options)

--[[ keymap.set("n", "f", ":HopWord<cr>", options) ]]

keymap.set("n", "<leader>v", "<C-v>")

keymap.set("n", "<S-k>", ":BufferLineCycleNext<cr>", options)
keymap.set("n", "<S-j>", ":BufferLineCyclePrev<cr>", options)

keymap.set("n", "<leader>w", ":Bdelete %<cr>", options)
-- VISUAL
keymap.set("v", "<S-k>", ":m '<-2<cr>gv=gv")
keymap.set("v", "<S-j>", ":m '<+1<cr>gv=gv")
