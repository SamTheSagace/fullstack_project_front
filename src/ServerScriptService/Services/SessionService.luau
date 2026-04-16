local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SessionApi = require(ReplicatedStorage.Api.SessionApi)
local Utils = require(ReplicatedStorage.Shared.Utils)
local DataService = require(ReplicatedStorage.Packages.DataService).server

local RoomService = require(script.Parent:WaitForChild("RoomService"))

local SessionService = {}

local remotes = nil
local sessionMetaByCode = {}
local isInitialized = false

local function fireError(player: Player, message: string)
	if remotes then
		remotes.sessionError:FireClient(player, { message = message })
	end
end

local function setPlayerSeatedState(player: Player, isSeated: boolean)
	DataService:update(player, "is_seated", function()
		return isSeated
	end)
end

local function setPlayerReadyState(player: Player, isReady: boolean)
	DataService:update(player, "is_ready", function()
		return isReady
	end)
end

local function setPlayerSessionState(player: Player, code: string, isSeated: boolean)
	DataService:update(player, "session_code", function()
		return code
	end)
	setPlayerSeatedState(player, isSeated)
	setPlayerReadyState(player, false)
	DataService:update(player, "current_vote", function()
		return nil
	end)
end

local function clearPlayerSessionState(player: Player)
	DataService:update(player, "session_code", function()
		return nil
	end)
	setPlayerSeatedState(player, false)
	setPlayerReadyState(player, false)
	DataService:update(player, "current_vote", function()
		return nil
	end)
end

local function getPlayersInSession(code: string): { Player }
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if DataService:get(player, "session_code") == code then
			table.insert(list, player)
		end
	end
	return list
end

local function syncSessionSeatingState(code: string)
	local seatMap = RoomService.getSeatMap(code)
	for _, player in ipairs(getPlayersInSession(code)) do
		local isSeated = seatMap[player.UserId] ~= nil
		setPlayerSeatedState(player, isSeated)
		if not isSeated then
			setPlayerReadyState(player, false)
		end
	end
end

local function isSessionOwner(player: Player, code: string): boolean
	local meta = sessionMetaByCode[code]
	return meta ~= nil and meta.hostUserId == player.UserId
end

local function getSessionPhase(code: string): string
	local meta = sessionMetaByCode[code]
	local phase = meta and meta.phase
	if type(phase) == "string" and phase ~= "" then
		return phase
	end

	return "waiting"
end

local function canOwnerStartSession(code: string): (boolean, string?)
	local players = getPlayersInSession(code)
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

local function broadcastSessionState(code: string)
	if remotes == nil then
		return
	end

	local members = {}
	local readyCount = 0
	local seatedCount = 0
	for _, player in ipairs(getPlayersInSession(code)) do
		local isReady = DataService:get(player, "is_ready") == true
		local isSeated = DataService:get(player, "is_seated") == true
		if isReady then
			readyCount += 1
		end
		if isSeated then
			seatedCount += 1
		end

		table.insert(members, {
			userId = player.UserId,
			name = player.Name,
			participate = isSeated,
			isReady = isReady,
			isSeated = isSeated,
		})
	end

	local meta = sessionMetaByCode[code]
	local snapshot = {
		code = code,
		name = (meta and meta.name) or "Session",
		phase = getSessionPhase(code),
		hostUserId = (meta and meta.hostUserId) or (members[1] and members[1].userId) or 0,
		current_item_id = 1,
		members = members,
		seatMap = RoomService.getSeatMap(code),
		playerCount = #members,
		seatedCount = seatedCount,
		readyCount = readyCount,
	}

	for _, player in ipairs(getPlayersInSession(code)) do
		remotes.sessionState:FireClient(player, snapshot)
	end
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
	for _, player in ipairs(getPlayersInSession(code)) do
		RoomService.teleportPlayerToSpawn(player)
		clearPlayerSessionState(player)
		fireError(player, "Session closed by owner")
	end

	RoomService.destroyRoomForSession(code)
	sessionMetaByCode[code] = nil
end

local function getPlayerSessionCode(player: Player): string?
	local code = DataService:get(player, "session_code")
	if type(code) == "string" and code ~= "" then
		return code
	end

	for candidateCode, meta in pairs(sessionMetaByCode) do
		if meta and meta.hostUserId == player.UserId then
			return candidateCode
		end
	end

	return nil
end

local function joinLocalSession(player: Player, code: string, isOwner: boolean): boolean
	if sessionMetaByCode[code] == nil then
		sessionMetaByCode[code] = {
			name = "Session",
			hostUserId = 0,
			phase = "waiting",
		}
	end

	local roomModel, roomError = RoomService.ensureRoomForSession(code)
	if roomModel == nil then
		fireError(player, roomError or "Could not create/load room")
		return false
	end

	print("Join Local Session:", code, isOwner)

	setPlayerSessionState(player, code, false)
	local teleported = RoomService.teleportPlayerToSessionRoom(player, code, isOwner)
	if not teleported then
		clearPlayerSessionState(player)
		fireError(player, "Could not move player into the session room")
		return false
	end

	if isOwner then
		local seated, seatError = RoomService.seatPlayerInOwnerChair(player, code)
		if not seated then
			clearPlayerSessionState(player)
			RoomService.teleportPlayerToSpawn(player)
			fireError(player, seatError or "Could not seat the session owner")
			return false
		end
	end

	syncSessionSeatingState(code)
	broadcastSessionState(code)
	return true
end

function SessionService.init(remoteMap)
	remotes = remoteMap

	if isInitialized then
		return
	end

	DataService:init({
		template = {
			session_code = nil,
			is_seated = false,
			is_ready = false,
			current_vote = nil,
		},
	})

	RoomService.setSeatStateChangedHandler(function(code: string)
		syncSessionSeatingState(code)
		broadcastSessionState(code)
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
		fireError(player, "Session name is required")
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
		fireError(player, "Session creation failed")
		return
	end

	local code = string.upper(Utils.trim(rawCode))
	sessionMetaByCode[code] = {
		name = result.name or sessionName,
		hostUserId = player.UserId,
		sessionId = result.id,
		phase = "waiting",
	}

	local joinedLocally = joinLocalSession(player, code, true)
	if not joinedLocally then
		sessionMetaByCode[code] = nil
		return
	end

	if remotes then
		remotes.createSession:FireClient(player, result)
	end
end

function SessionService.handleToggleReady(player: Player)
	local code = getPlayerSessionCode(player)
	if code == nil then
		fireError(player, "You are not in a session")
		return
	end

	if getSessionPhase(code) ~= "waiting" then
		fireError(player, "The session has already started")
		return
	end

	if isSessionOwner(player, code) then
		fireError(player, "The owner starts the session directly")
		return
	end

	if DataService:get(player, "is_seated") ~= true then
		fireError(player, "You must be seated before getting ready")
		return
	end

	local nextReadyState = DataService:get(player, "is_ready") ~= true
	setPlayerReadyState(player, nextReadyState)
	broadcastSessionState(code)
end

function SessionService.handleStartSession(player: Player)
	local code = getPlayerSessionCode(player)
	if code == nil then
		fireError(player, "You are not in a session")
		return
	end

	if not isSessionOwner(player, code) then
		fireError(player, "Only the owner can start the session")
		return
	end

	if getSessionPhase(code) ~= "waiting" then
		fireError(player, "The session has already started")
		return
	end

	syncSessionSeatingState(code)

	local canStart, startError = canOwnerStartSession(code)
	if not canStart then
		fireError(player, startError or "Session cannot be started yet")
		broadcastSessionState(code)
		return
	end

	local meta = sessionMetaByCode[code]
	if meta then
		meta.phase = "playing"
	end

	broadcastSessionState(code)
end

function SessionService.handleJoinSession(player: Player, payload)
	if type(payload) ~= "table" then
		fireError(player, "Invalid join payload")
		return
	end

	local code = payload.code
	if type(code) ~= "string" then
		fireError(player, "Invalid session code")
		return
	end

	local cleanedCode = string.upper(Utils.trim(code))
	if cleanedCode == "" then
		fireError(player, "Session code is required")
		return
	end

	local joinedBackend = joinBackendSession(player, cleanedCode)
	if not joinedBackend then
		fireError(player, "Failed to join session")
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
		fireError(player, "You are not in a session")
		return false
	end

	leaveBackendSession(player, code)

	local meta = sessionMetaByCode[code]
	local isOwner = meta and meta.hostUserId == player.UserId

	if isOwner then
		teardownSession(code)
		return true
	end

	clearPlayerSessionState(player)
	RoomService.teleportPlayerToSpawn(player)
	if remotes then
		remotes.sessionState:FireClient(player, nil)
	end
	syncSessionSeatingState(code)
	broadcastSessionState(code)
	return true
end

function SessionService.handlePlayerRemoving(player: Player)
	local code = getPlayerSessionCode(player)
	if code == nil then
		return
	end

	leaveBackendSession(player, code)

	local meta = sessionMetaByCode[code]
	local isOwner = meta and meta.hostUserId == player.UserId

	if isOwner then
		teardownSession(code)
		return
	end

	RoomService.releasePlayerSeatLock(player)
	clearPlayerSessionState(player)
	syncSessionSeatingState(code)
	broadcastSessionState(code)
end

return SessionService
