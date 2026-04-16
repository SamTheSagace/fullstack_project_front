local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HubUI = require(script.Parent.HubUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = React.createElement(HubUI)
	root:render(app)

	return function()
		root:unmount()
	end
end
