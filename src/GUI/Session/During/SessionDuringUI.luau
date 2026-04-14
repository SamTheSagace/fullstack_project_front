local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.Packages.React)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local SessionCode = require(StarterGui.GUI.Components.SessionCode)
local e = React.createElement
local CommonTypes = require(ReplicatedStorage.Types.Common)
type Session = CommonTypes.Session

local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local leaveSessionEvent = eventsFolder:WaitForChild("leaveSession")

local function SessionDuringUI(currentSession: Session)
	local function handleLeaveSession()
		leaveSessionEvent:FireServer()
	end

	return e(React.Fragment, nil, {
		SessionCode = e(SessionCode, {
			Text = currentSession.code or "",
		}) or nil,

		LeaveSessionButton =  e(CustomButton, {
			Text = "Leave Session",
			Position = UDim2.fromScale(0.5, 0.925),
			Size = UDim2.fromScale(0.22, 0.1),
			BackgroundColor3 = Color3.fromRGB(133, 26, 26),
			ButtonColor = Color3.fromRGB(184, 44, 44),
			onButtonClick = handleLeaveSession,
		}) or nil,
	})
end

return SessionDuringUI