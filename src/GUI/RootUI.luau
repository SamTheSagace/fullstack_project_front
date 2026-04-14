local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local HubUI = require(StarterGui.GUI.HUB.HubUI)
local SessionDuringUI = require(StarterGui.GUI.Session.During.SessionDuringUI)
local SessionWaitingUI = require(StarterGui.GUI.Session.Waiting.SessionWaitingUI)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local sessionStateEvent = eventsFolder:WaitForChild("sessionState")
local sessionErrorEvent = eventsFolder:WaitForChild("sessionError")

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
			end
		end)

		return function()
			sessionStateConnection:Disconnect()
			sessionErrorConnection:Disconnect()
		end
	end, { localPlayer })

	local shouldShowSessionWaitingUI = currentSession ~= nil and not isSessionActive(currentSession)
	local shouldShowSessionDuringUI = currentSession ~= nil and isSessionActive(currentSession)

	if shouldShowSessionWaitingUI then
		return e(React.Fragment, nil, {
			SessionWaitingUI = e(SessionWaitingUI, {
				currentSession = currentSession,
			}),
		})
	end
	if shouldShowSessionDuringUI then
		return e(React.Fragment, nil, {
			SessionDuringUI = e(SessionDuringUI, {
				currentSession = currentSession,
			}),
		})
	end
	return e(React.Fragment, nil, { e(HubUI) })
end

return RootUI
