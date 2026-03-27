local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local SessionCode = require(StarterGui.GUI.Components.SessionCode)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local e = React.createElement

local function TestUI()
	return e(React.Fragment, nil, {
		SessionCode = e(SessionCode, {
			Text= "ABD134",
		}),
	})
end

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = React.createElement(TestUI)
	root:render(app)

	return function()
		root:unmount()
	end
end
