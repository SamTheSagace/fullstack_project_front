local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.Packages.React)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local SessionMenu = require(StarterGui.GUI.Session.SessionMenu)
local e = React.createElement

local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local sessionStateEvent = eventsFolder:WaitForChild("sessionState")
local sessionErrorEvent = eventsFolder:WaitForChild("sessionError")
local leaveSessionEvent = eventsFolder:WaitForChild("leaveSession")

local function isPlayerInSession(snapshot, userId: number): boolean
	if type(snapshot) ~= "table" or type(snapshot.members) ~= "table" then
		return false
	end

	for _, member in ipairs(snapshot.members) do
		if type(member) == "table" and member.userId == userId then
			return true
		end
	end

	return false
end

local function isSessionActive(snapshot): boolean
	return type(snapshot) == "table" and snapshot.phase == "playing"
end

local function RootUI()
	local localPlayer = Players.LocalPlayer
	local isMenuVisible, setIsMenuVisible = React.useState(false)
	local currentSession, setCurrentSession = React.useState(nil)

	React.useEffect(function()
		local sessionStateConnection = sessionStateEvent.OnClientEvent:Connect(function(snapshot)
			if isPlayerInSession(snapshot, localPlayer.UserId) then
				setCurrentSession(snapshot)
			end
		end)

		local sessionErrorConnection = sessionErrorEvent.OnClientEvent:Connect(function(err)
			local message = if type(err) == "table" then err.message else tostring(err)
			if message == "Session closed by owner" or message == "You are not in a session" then
				setCurrentSession(nil)
				setIsMenuVisible(false)
			end
		end)

		return function()
			sessionStateConnection:Disconnect()
			sessionErrorConnection:Disconnect()
		end
	end, { localPlayer })

	local shouldShowLeaveButton = currentSession ~= nil and not isSessionActive(currentSession)
	local shouldShowMenuControls = not shouldShowLeaveButton

	local function handleLeaveSession()
		leaveSessionEvent:FireServer()
		setCurrentSession(nil)
		setIsMenuVisible(false)
	end

	return e(React.Fragment, nil, {
		OpenSessionMenuButton = shouldShowMenuControls and e(CustomButton, {
			Text = "Open Menu",
			Position = UDim2.fromScale(0.5, 0.925),
			Size = UDim2.fromScale(0.2, 0.1),
			BackgroundColor3 = Color3.fromRGB(1, 88, 181),
			ButtonColor = Color3.fromRGB(0, 122, 255),
			onButtonClick = function()
				setIsMenuVisible(not isMenuVisible)
			end,
		}) or nil,

		SessionMenu = e(SessionMenu, {
			isVisible = shouldShowMenuControls and isMenuVisible,
		}),

		LeaveSessionButton = shouldShowLeaveButton and e(CustomButton, {
			Text = "Leave Session",
			Position = UDim2.fromScale(0.5, 0.925),
			Size = UDim2.fromScale(0.22, 0.1),
			BackgroundColor3 = Color3.fromRGB(133, 26, 26),
			ButtonColor = Color3.fromRGB(184, 44, 44),
			onButtonClick = handleLeaveSession,
		}) or nil,
	})
end

return RootUI
