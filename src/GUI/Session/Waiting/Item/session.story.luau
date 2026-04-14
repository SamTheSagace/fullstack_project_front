local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemMenu = require(script.Parent.RootItem)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = React.createElement(ItemMenu)
	root:render(app)

	return function()
		root:unmount()
	end
end
