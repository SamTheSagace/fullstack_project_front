local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Services = script.Parent.Parent:WaitForChild("Services")
local SessionService = require(Services:WaitForChild("SessionService"))
local VotesService = require(Services:WaitForChild("VotesService"))

local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
if not eventsFolder then
	eventsFolder = Instance.new("Folder")
	eventsFolder.Name = "Events"
	eventsFolder.Parent = ReplicatedStorage
end

local function ensureRemoteEvent(name: string): RemoteEvent
	local existing = eventsFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = eventsFolder
	return remote
end

-- Session events
local listSessions = ensureRemoteEvent("listSessions")
local createSession = ensureRemoteEvent("createSession")
local joinSession = ensureRemoteEvent("joinSession")
local leaveSession = ensureRemoteEvent("leaveSession")
local toggleReady = ensureRemoteEvent("toggleReady")
local startSession = ensureRemoteEvent("startSession")
local sessionState = ensureRemoteEvent("sessionState")
local sessionError = ensureRemoteEvent("sessionError")
-- Votes events
local confirmVote = ensureRemoteEvent("confirmVote")

SessionService.init({
	listSessions = listSessions,
	createSession = createSession,
	joinSession = joinSession,
	leaveSession = leaveSession,
	toggleReady = toggleReady,
	startSession = startSession,
	sessionState = sessionState,
	sessionError = sessionError,
})

listSessions.OnServerEvent:Connect(function(player)
	SessionService.handleListSessions(player)
end)

createSession.OnServerEvent:Connect(function(player, sessionName)
	SessionService.handleCreateSession(player, sessionName)
end)

joinSession.OnServerEvent:Connect(function(player, payload)
	SessionService.handleJoinSession(player, payload)
end)

leaveSession.OnServerEvent:Connect(function(player)
	SessionService.handleLeaveSession(player)
end)

toggleReady.OnServerEvent:Connect(function(player)
	SessionService.handleToggleReady(player)
end)

startSession.OnServerEvent:Connect(function(player)
	SessionService.handleStartSession(player)
end)

Players.PlayerRemoving:Connect(function(player)
	SessionService.handlePlayerRemoving(player)
end)

confirmVote.OnServerEvent:Connect(function(player, payload)
	VotesService.confirmVote(player, payload)
end)
