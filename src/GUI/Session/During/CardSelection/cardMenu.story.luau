local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CardMenu = require(script.Parent.CardMenu)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = React.createElement(CardMenu)
	root:render(app)

	return function()
		root:unmount()
	end
end
