local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SessionWaitingUI = require(script.Parent.SessionWaitingUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local e = React.createElement

local function TestUI()
	return e(React.Fragment, nil, {
		SessionWaitingUI = e(SessionWaitingUI, {
			currentSession = {
				code = "ABC123",
				playerCount = 4,
				seatedCount = 3,
				readyCount = 2,
				isOwner = false,
				isCurrentPlayerReady = false,
				showActionButton = true,
				actionEnabled = true,
				actionText = "Ready",
				helperText = "Click ready when you are set",
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
