local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SessionPlayerService = require(script.Parent.SessionPlayerService)
local SessionApi = require(ReplicatedStorage.Api.SessionApi)
local ItemApi = require(ReplicatedStorage.Api.ItemApi)
local SessionHelpers = require(ReplicatedStorage.Shared.SessionHelpers)
local Utils = require(ReplicatedStorage.Shared.Utils)
local DataService = require(ReplicatedStorage.Packages.DataService).server

local RoomService = require(script.Parent:WaitForChild("RoomService"))
local ItemService = require(script.Parent:WaitForChild("ItemService"))

local CommonTypes = require(ReplicatedStorage.Types.Common)
type Item = CommonTypes.Item
type Vote = CommonTypes.Vote

local SessionStore = require(script.Parent.Parent:WaitForChild("Store"):WaitForChild("SessionStore"))
local SessionNotifier = require(script.Parent.SessionNotifier)

local SessionService = {}

local remotes = nil
local isInitialized = false

local function isSessionOwner(player: Player, code: string): boolean
	local meta = SessionStore.get(code)
	return meta ~= nil and meta.hostUserId == player.UserId
end

local function getSessionPhase(code: string): string
	local meta = SessionStore.get(code)
	local phase = meta and meta.phase
	if type(phase) == "string" and phase ~= "" then
		return phase
	end

	return "waiting"
end

local function canVote(player: Player): boolean
	local playerState = SessionPlayerService.getPlayerSessionState(player)
	local code = playerState and playerState.sessionCode
	local sessionId = playerState and playerState.sessionId
	local meta = SessionStore.get(code)
	local currentItemResponse: Item = ItemApi:GetItemBySessionIdAndPosition(sessionId, meta.currentItem.position)
	local membersLength: number = meta.members and #meta.members
	local votesLength: number = currentItemResponse and currentItemResponse.votes and #currentItemResponse.votes
	return votesLength == membersLength
end

local function getFinalValue(player: Player): number
	local playerState = SessionPlayerService.getPlayerSessionState(player)
	local code = playerState and playerState.sessionCode
	local sessionId = playerState and playerState.sessionId
	local meta = SessionStore.get(code)
	local currentItemResponse: Item = ItemApi:GetItemBySessionIdAndPosition(sessionId, meta.currentItem.position)
	local votes: { Vote } = currentItemResponse and currentItemResponse.votes or {}
	local moyVotes = 0
	for _, v in pairs(votes) do
		moyVotes += tonumber(v.value)
	end
	moyVotes = moyVotes / #votes
	return SessionHelpers.closestFibonacci(moyVotes)
end

local function canOwnerStartSession(code: string): (boolean, string?)
	local players = SessionPlayerService.getPlayersInSession(code)
	if #players == 0 then
		return false, "No players are in this session"
	end

	for _, member in ipairs(players) do
		if DataService:get(member, "is_seated") ~= true then
			return false, "All players must be seated before the owner can start"
		end

		local isOwner = isSessionOwner(member, code)
		if not isOwner and DataService:get(member, "is_ready") ~= true then
			return false, "All seated players must be ready before the owner can start"
		end
	end

	return true, nil
end

local function joinBackendSession(player: Player, code: string): boolean
	local ok, response = pcall(function()
		return SessionApi:JoinSession(tostring(code), {
			roblox_user_id = player.UserId,
			display_name = player.DisplayName,
		})
	end)

	if not ok or response == nil then
		warn("[SessionService] Failed to join session:", response)
		return false
	end

	return true
end

local function leaveBackendSession(player: Player, code: string)
	local ok, response = pcall(function()
		return SessionApi:LeaveSession(tostring(code), {
			roblox_user_id = player.UserId,
		})
	end)

	if not ok then
		warn("[SessionService] Failed to leave session:", response)
	end
end

local function teardownSession(code: string)
	for _, player in ipairs(SessionPlayerService.getPlayersInSession(code)) do
		RoomService.teleportPlayerToSpawn(player)
		SessionPlayerService.clearPlayerSessionState(player)
		Utils.fireError(player, "Session closed by owner", remotes)
	end

	RoomService.destroyRoomForSession(code)
	SessionStore.remove(code)
end

local function getPlayerSessionCode(player: Player): string?
	local code = DataService:get(player, "session_code")
	if type(code) == "string" and code ~= "" then
		return code
	end

	for candidateCode, meta in pairs(SessionStore.getAll()) do
		if meta and meta.hostUserId == player.UserId then
			return candidateCode
		end
	end

	return nil
end

local function joinLocalSession(player: Player, code: string, isOwner: boolean): boolean
	if SessionStore.get(code) == nil then
		SessionStore.set(code, {
			name = "Session",
			hostUserId = 0,
			phase = "waiting",
		})
	end

	local roomModel, roomError = RoomService.ensureRoomForSession(code)
	if roomModel == nil then
		Utils.fireError(player, roomError or "Could not create/load room", remotes)
		return false
	end

	local meta = SessionStore.get(code)
	local sessionId = meta and meta.sessionId
	SessionPlayerService.setPlayerSessionState(player, code, sessionId, false)
	local teleported = RoomService.teleportPlayerToSessionRoom(player, code, isOwner)
	if not teleported then
		SessionPlayerService.clearPlayerSessionState(player)
		Utils.fireError(player, "Could not move player into the session room", remotes)
		return false
	end

	if isOwner then
		local seated, seatError = RoomService.seatPlayerInOwnerChair(player, code)
		if not seated then
			SessionPlayerService.clearPlayerSessionState(player)
			RoomService.teleportPlayerToSpawn(player)
			Utils.fireError(player, seatError or "Could not seat the session owner", remotes)
			return false
		end
	end

	SessionPlayerService.syncSessionSeatingState(code)
	SessionNotifier.broadcastSessionState(code)
	return true
end

function SessionService.init(remoteMap)
	remotes = remoteMap

	if isInitialized then
		return
	end

	RoomService.setSeatStateChangedHandler(function(code: string)
		SessionPlayerService.syncSessionSeatingState(code)
		SessionNotifier.broadcastSessionState(code)
	end)

	isInitialized = true
end

function SessionService.handleListSessions(player: Player)
	local result = SessionApi:GetSessions()
	if remotes then
		remotes.listSessions:FireClient(player, result)
	end
end

function SessionService.handleCreateSession(player: Player, sessionName: string)
	if type(sessionName) ~= "string" or Utils.trim(sessionName) == "" then
		Utils.fireError(player, "Session name is required", remotes)
		return
	end

	local serv_id = game.PlaceId
	local result = SessionApi:CreateSession({
		owner_roblox_user_id = player.UserId,
		display_name = player.DisplayName,
		name = sessionName,
		owner_server_id = serv_id,
	})

	local rawCode = result and result.code
	if type(rawCode) ~= "string" then
		Utils.fireError(player, "Session creation failed", remotes)
		return
	end

	local code = string.upper(Utils.trim(rawCode))
	SessionStore.set(code, {
		name = result.name or sessionName,
		hostUserId = player.UserId,
		sessionId = result.id,
		phase = "waiting",
	})

	local joinedLocally = joinLocalSession(player, code, true)
	if not joinedLocally then
		SessionStore.remove(code)
		return
	end

	if remotes then
		remotes.createSession:FireClient(player, result)
	end
end

function SessionService.handleToggleReady(player: Player)
	local code = getPlayerSessionCode(player)
	if code == nil then
		Utils.fireError(player, "You are not in a session", remotes)
		return
	end

	if getSessionPhase(code) ~= "waiting" then
		Utils.fireError(player, "The session has already started", remotes)
		return
	end

	if isSessionOwner(player, code) then
		Utils.fireError(player, "The owner starts the session directly", remotes)
		return
	end

	if DataService:get(player, "is_seated") ~= true then
		Utils.fireError(player, "You must be seated before getting ready", remotes)
		return
	end

	local nextReadyState = DataService:get(player, "is_ready") ~= true
	SessionPlayerService.setPlayerReadyState(player, nextReadyState)
	SessionNotifier.broadcastSessionState(code)
end

function SessionService.handleStartSession(player: Player)
	local playerState = SessionPlayerService.getPlayerSessionState(player)
	local code = playerState and playerState.sessionCode
	local sessionId = playerState and playerState.sessionId

	if code == nil or sessionId == nil then
		Utils.fireError(player, "You are not in a session", remotes)
		return
	end

	if not isSessionOwner(player, code) then
		Utils.fireError(player, "Only the owner can start the session", remotes)
		return
	end

	if getSessionPhase(code) ~= "waiting" then
		Utils.fireError(player, "The session has already started", remotes)
		return
	end

	SessionPlayerService.syncSessionSeatingState(code)

	local canStart, startError = canOwnerStartSession(code)
	if not canStart then
		Utils.fireError(player, startError or "Session cannot be started yet", remotes)
		SessionNotifier.broadcastSessionState(code)
		return
	end

	local result = SessionApi:StartSession(sessionId)
	local session = SessionApi:GetSessionByCode(code)
	local items: { Item } = result and result.items or {}
	local listItems = ItemService.handleListItemsBySessionId(player)
	if listItems then
		items = listItems
	end
	local currentItem: Item
	for _, item in ipairs(items) do
		if item.position == 1 then
			currentItem = item
			break
		end
	end

	SessionStore.update(code, function(meta)
		meta.phase = "playing"
		meta.items = items
		meta.currentItem = currentItem
		meta.members = session.members or meta.members
	end)

	SessionNotifier.broadcastSessionState(code)
end

function SessionService.handleEndSession(player: Player)
	local playerState = SessionPlayerService.getPlayerSessionState(player)
	local code = playerState and playerState.sessionCode

	if code == nil then
		Utils.fireError(player, "You are not in a session", remotes)
		return
	end

	SessionStore.update(code, function(meta)
		meta.phase = "waiting"
	end)
	SessionNotifier.broadcastSessionState(code)
end

function SessionService.canFinishVote(player: Player)
	local canFinishVote = canVote(player)
	local finalValue = getFinalValue(player)

	remotes.canFinishVote:FireClient(player, { canFinishVote = canFinishVote, finalValue = finalValue })
end

function SessionService.handleNextItem(player: Player)
	local playerState = SessionPlayerService.getPlayerSessionState(player)
	local code = playerState and playerState.sessionCode
	local sessionId = playerState and playerState.sessionId

	if code == nil or sessionId == nil then
		Utils.fireError(player, "You are not in a session", remotes)
		return
	end

	local canFinishVote = canVote(player)
	if not canFinishVote then
		Utils.fireError(player, "Not all players have voted on the current item", remotes)
		return
	end

	local finalValue = getFinalValue(player)
	local getMeta = SessionStore.get(code)
	ItemApi:SaveFinalValue(getMeta.currentItem.id, finalValue)

	SessionStore.update(code, function(meta)
		if meta.phase ~= "playing" then
			Utils.fireError(player, "Session is not in playing phase", remotes)
			return
		end

		if meta.currentItem == nil then
			Utils.fireError(player, "Current item is missing", remotes)
			return
		end

		meta.currentItem = meta.items[meta.currentItem.position + 1]
	end)

	remotes.nextItem:FireClient(player, SessionStore.get(code))
end

function SessionService.handleJoinSession(player: Player, payload)
	if type(payload) ~= "table" then
		Utils.fireError(player, "Invalid join payload", remotes)
		return
	end

	local code = payload.code
	if type(code) ~= "string" then
		Utils.fireError(player, "Invalid session code", remotes)
		return
	end

	local cleanedCode = string.upper(Utils.trim(code))
	if cleanedCode == "" then
		Utils.fireError(player, "Session code is required", remotes)
		return
	end

	local joinedBackend = joinBackendSession(player, cleanedCode)
	if not joinedBackend then
		Utils.fireError(player, "Failed to join session", remotes)
		return
	end

	local joinedLocally = joinLocalSession(player, cleanedCode, false)
	if not joinedLocally then
		leaveBackendSession(player, cleanedCode)
	end
end

function SessionService.handleLeaveSession(player: Player): boolean
	local code = getPlayerSessionCode(player)
	if code == nil then
		Utils.fireError(player, "You are not in a session", remotes)
		return false
	end

	leaveBackendSession(player, code)

	local meta = SessionStore.get(code)
	local isOwner = meta and meta.hostUserId == player.UserId

	if isOwner then
		teardownSession(code)
		return true
	end

	SessionPlayerService.clearPlayerSessionState(player)
	RoomService.teleportPlayerToSpawn(player)
	if remotes then
		remotes.sessionState:FireClient(player, nil)
	end
	SessionPlayerService.syncSessionSeatingState(code)
	SessionNotifier.broadcastSessionState(code)
	return true
end

function SessionService.handlePlayerRemoving(player: Player)
	local code = getPlayerSessionCode(player)
	if code == nil then
		return
	end

	leaveBackendSession(player, code)

	local meta = SessionStore.get(code)
	local isOwner = meta and meta.hostUserId == player.UserId

	if isOwner then
		teardownSession(code)
		return
	end

	RoomService.releasePlayerSeatLock(player)
	SessionPlayerService.clearPlayerSessionState(player)
	SessionPlayerService.syncSessionSeatingState(code)
	SessionNotifier.broadcastSessionState(code)
end

return SessionService
