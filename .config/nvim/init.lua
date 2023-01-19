require("fvrn.options")
require("fvrn.maps")
require("fvrn.plugins")

local has = vim.fn.has
local is_mac = has("macunix")
local is_win = has("win32")

if is_mac then
	require("fvrn.macos")
end
if is_win then
	require("fvrn.windows")
end
