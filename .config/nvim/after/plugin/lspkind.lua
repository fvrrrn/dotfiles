local status, lspkind = pcall(require, "lspkind")
if not status then
	return
end

lspkind.init({
	-- enables text annotations
	--
	-- default: true
	mode = "text",
})
