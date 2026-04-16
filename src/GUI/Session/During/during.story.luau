local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SessionDuringUI = require(script.Parent.SessionDuringUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local e = React.createElement

local function TestUI()
	return e(React.Fragment, nil, {
		SessionDuringUI = e(SessionDuringUI, {
			currentSession = {
				code = "ABC123",
			},
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
