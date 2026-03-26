local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VoteMenu = require(script.Parent.VoteMenu)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = React.createElement(VoteMenu)
	root:render(app)

	return function()
		root:unmount()
	end
end
