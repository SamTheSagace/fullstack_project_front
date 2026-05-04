local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = script.Parent.Parent:WaitForChild("Services")
local ItemService = require(ServerScriptService.Services.ItemService)
local SessionNotifier = require(ServerScriptService.Services.SessionNotifier)
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

-- Global events
local errorEvent = ensureRemoteEvent("errorEvent")

-- Session events
local listSessions = ensureRemoteEvent("listSessions")
local createSession = ensureRemoteEvent("createSession")
local joinSession = ensureRemoteEvent("joinSession")
local leaveSession = ensureRemoteEvent("leaveSession")
local toggleReady = ensureRemoteEvent("toggleReady")
local startSession = ensureRemoteEvent("startSession")
local sessionState = ensureRemoteEvent("sessionState")
local nextItem = ensureRemoteEvent("nextItem")

-- Votes events
local confirmVote = ensureRemoteEvent("confirmVote")

-- Item events
local listItemsSessionId = ensureRemoteEvent("listItemsSessionId")
local createItem = ensureRemoteEvent("createItem")
local deleteItem = ensureRemoteEvent("deleteItem")

SessionService.init({
	errorEvent = errorEvent,
	listSessions = listSessions,
	createSession = createSession,
	joinSession = joinSession,
	leaveSession = leaveSession,
	toggleReady = toggleReady,
	startSession = startSession,
	nextItem = nextItem,
})

SessionNotifier.init({
	errorEvent = errorEvent,
	sessionState = sessionState,
})

ItemService.init({
	errorEvent = errorEvent,
	listItemsSessionId = listItemsSessionId,
	createItem = createItem,
	deleteItem = deleteItem,
})

VotesService.init({
	errorEvent = errorEvent,
	confirmVote = confirmVote,
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

nextItem.OnServerEvent:Connect(function(player)
	SessionService.handleNextItem(player)
end)

Players.PlayerRemoving:Connect(function(player)
	SessionService.handlePlayerRemoving(player)
end)

confirmVote.OnServerEvent:Connect(function(player, payload)
	VotesService.confirmVote(player, payload)
end)

listItemsSessionId.OnServerEvent:Connect(function(player)
	ItemService.handleListItemsBySessionId(player)
end)

createItem.OnServerEvent:Connect(function(player, payload)
	ItemService.handleCreateItem(player, payload)
end)

deleteItem.OnServerEvent:Connect(function(player, payload)
	ItemService.handleDeleteItem(player, payload)
end)
