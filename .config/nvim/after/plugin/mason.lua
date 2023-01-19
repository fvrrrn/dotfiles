local status, mason = pcall(require, "mason")
if not status then
	return
end

local mason_lspconfig_status, lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status then
	return
end

mason.setup()

lspconfig.setup({
	ensure_installed = { "tsserver", "sumneko_lua" },
})
