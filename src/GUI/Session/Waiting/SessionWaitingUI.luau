local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local React = require(ReplicatedStorage.Packages.React)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local SessionCode = require(StarterGui.GUI.Components.SessionCode)
local WaitingStateButton = require(StarterGui.GUI.Components.WaitingStateButton)
local RootUIItem = require(StarterGui.GUI.Session.Waiting.Item.RootUIItem)
local e = React.createElement
local CommonTypes = require(ReplicatedStorage.Types.Common)
type SessionSnapshot = CommonTypes.SessionSnapshot
type SessionSnapshotMember = CommonTypes.SessionSnapshotMember

local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local leaveSessionEvent = eventsFolder:WaitForChild("leaveSession")
local toggleReadyEvent = eventsFolder:WaitForChild("toggleReady")
local startSessionEvent = eventsFolder:WaitForChild("startSession")

type Props = {
	currentSession: SessionSnapshot,
}

local function getLocalMember(currentSession: SessionSnapshot, userId: number): SessionSnapshotMember?
	for _, member in ipairs(currentSession.members or {}) do
		if member.userId == userId then
			return member
		end
	end

	return nil
end

local function buildMemberStatusLines(currentSession: SessionSnapshot): string
	local lines = {}
	for _, member in ipairs(currentSession.members or {}) do
		local seatLabel = if member.isSeated then "seated" else "standing"
		local readyLabel = if member.isReady then "ready" else "not ready"
		table.insert(lines, string.format("%s - %s - %s", member.name, seatLabel, readyLabel))
	end

	return table.concat(lines, "\n")
end

local function canOwnerStart(currentSession: SessionSnapshot): boolean
	for _, member in ipairs(currentSession.members or {}) do
		if member.isSeated ~= true then
			return false
		end

		local isOwner = member.userId == currentSession.hostUserId
		if not isOwner and member.isReady ~= true then
			return false
		end
	end

	return true
end

local function SessionWaitingUI(props: Props)
	local currentSession = props.currentSession
	local localPlayer = Players.LocalPlayer
	local localMember = getLocalMember(currentSession, localPlayer.UserId)
	local isOwner = currentSession.hostUserId == localPlayer.UserId
	local isSeated = localMember ~= nil and localMember.isSeated == true
	local isReady = localMember ~= nil and localMember.isReady == true
	local isSessionWaiting = currentSession.phase == "waiting"
	local ownerCanStart = isOwner and canOwnerStart(currentSession)

	local helperText = ""
	if not isSessionWaiting then
		helperText = "Session already started"
	elseif not isSeated then
		helperText = "Sit on a chair to enable ready/start"
	elseif isOwner and not ownerCanStart then
		helperText = "Waiting for all seated players to be ready"
	elseif isOwner then
		helperText = "Start when all other seated players are ready"
	elseif isReady then
		helperText = "You are ready"
	else
		helperText = "Click ready when you are set"
	end

	local canAct = isSessionWaiting and isSeated
	local canPressAction = canAct and (not isOwner or ownerCanStart)
	local actionText = if isOwner then "Start Session" else if isReady then "Unready" else "Ready"
	local isMenuVisible, setIsMenuVisible = React.useState(false)

	local function handleLeaveSession()
		leaveSessionEvent:FireServer()
	end

	local function handleWaitingAction()
		if not canPressAction then
			return
		end

		if isOwner then
			startSessionEvent:FireServer()
		else
			toggleReadyEvent:FireServer()
		end
	end

	return e(React.Fragment, nil, {
		SessionCode = e(SessionCode, {
			Text = currentSession.code or "",
		}),

		WaitingStateButton = e(WaitingStateButton, {
			playerCount = currentSession.playerCount or #(currentSession.members or {}),
			seatedCount = currentSession.seatedCount or 0,
			readyCount = currentSession.readyCount or 0,
			isOwner = isOwner,
			isCurrentPlayerReady = isReady,
			showActionButton = isSeated and isSessionWaiting,
			actionEnabled = canPressAction,
			actionText = actionText,
			helperText = helperText,
			onAction = handleWaitingAction,
			isMenuVisible = isMenuVisible,
		}),

		RootUIItem = e(RootUIItem, {
			Position = UDim2.fromScale(0.05, 0.925),
			AnchorPoint = Vector2.new(0, 0.5),
			isMenuVisible = isMenuVisible,
			setIsMenuVisible = setIsMenuVisible,
		}),

		LeaveSessionButton = e(CustomButton, {
			Text = "Leave Session",
			Position = UDim2.fromScale(0.95, 0.925),
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromScale(0.22, 0.1),
			BackgroundColor3 = Color3.fromRGB(133, 26, 26),
			ButtonColor = Color3.fromRGB(184, 44, 44),
			onButtonClick = handleLeaveSession,
		}),
	})
end

return SessionWaitingUI
