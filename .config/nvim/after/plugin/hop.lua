local status, hop = pcall(require, "hop")
if not status then
	return
end

vim.keymap.set("", "f", function()
	hop.hint_words({ multi_windows = true })
end, { remap = true })
