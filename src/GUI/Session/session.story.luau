local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SessionCard = require(script.Parent.SessionCard)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = React.createElement(SessionCard)
	root:render(app)

	return function()
		root:unmount()
	end
end
