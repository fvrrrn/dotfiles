local status, configs = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

---@diagnostic disable-next-line: missing-fields
configs.setup({
	ensure_installed = {
		"javascript",
		"typescript",
		"tsx",
		"css",
		"scss",
		"html",
		"lua",
		"json",
		"toml",
		"bash",
	},
	sync_install = false,
	ignore_install = { "" }, -- List of parsers to ignore installing
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "" }, -- list of language that will be disabled
		additional_vim_regex_highlighting = false,
	},
	indent = { enable = true, disable = { "yaml" } },
incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn", -- set to `false` to disable one of the mappings
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
})
