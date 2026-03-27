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

local function setPlayerSessionState(player: Player, code: string, participate: boolean)
	DataService:update(player, "session_code", function()
		return code
	end)
	DataService:update(player, "is_seated", function()
		return participate
	end)
	DataService:update(player, "is_ready", function()
		return false
	end)
	DataService:update(player, "current_vote", function()
		return nil
	end)
end

local function clearPlayerSessionState(player: Player)
	DataService:update(player, "session_code", function()
		return nil
	end)
	DataService:update(player, "is_seated", function()
		return false
	end)
	DataService:update(player, "is_ready", function()
		return false
	end)
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

local function broadcastSessionState(code: string)
	if remotes == nil then
		return
	end

	local members = {}
	for _, player in ipairs(getPlayersInSession(code)) do
		table.insert(members, {
			userId = player.UserId,
			name = player.Name,
			participate = DataService:get(player, "is_seated") == true,
			isReady = DataService:get(player, "is_ready") == true,
			isSeated = DataService:get(player, "is_seated") == true,
		})
	end

	local meta = sessionMetaByCode[code]
	local snapshot = {
		code = code,
		name = (meta and meta.name) or "Session",
		phase = "waiting",
		hostUserId = (meta and meta.hostUserId) or (members[1] and members[1].userId) or 0,
		members = members,
		seatMap = {},
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
	RoomService.destroyRoomForSession(code)

	for _, player in ipairs(getPlayersInSession(code)) do
		RoomService.teleportPlayerToSpawn(player)
		clearPlayerSessionState(player)
		fireError(player, "Session closed by owner")
	end

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

local function joinLocalSession(player: Player, code: string): boolean
	if sessionMetaByCode[code] == nil then
		sessionMetaByCode[code] = {
			name = "Session",
			hostUserId = 0,
		}
	end

	local roomModel, roomError = RoomService.ensureRoomForSession(code)
	if roomModel == nil then
		fireError(player, roomError or "Could not create/load room")
		return false
	end

	setPlayerSessionState(player, code, true)
	RoomService.teleportPlayerToSessionRoom(player, code)
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

	local result = SessionApi:CreateSession({
		owner_roblox_user_id = player.UserId,
		display_name = player.DisplayName,
		name = sessionName,
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
	}

	joinLocalSession(player, code)

	if remotes then
		remotes.createSession:FireClient(player, result)
	end
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

	joinLocalSession(player, cleanedCode)
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

	clearPlayerSessionState(player)
	broadcastSessionState(code)
end

return SessionService
