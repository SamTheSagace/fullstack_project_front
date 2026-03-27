local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SessionApi = require(ReplicatedStorage.Api.SessionApi)
local DataService = require(ReplicatedStorage.Packages.DataService).server
local Services = script.Parent.Parent:WaitForChild("Services")
local RoomService = require(Services:WaitForChild("RoomService"))

DataService:init({
	template = {
		session_code = nil,
		is_seated = false,
		is_ready = false,
		current_vote = nil,
	},
})

local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
if not eventsFolder then
	eventsFolder = Instance.new("Folder")
	eventsFolder.Name = "Events"
	eventsFolder.Parent = ReplicatedStorage
end

local sessionMetaByCode = {}

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

local listSessions = ensureRemoteEvent("listSessions")
local createSession = ensureRemoteEvent("createSession")
local joinSession = ensureRemoteEvent("joinSession")
local leaveSession = ensureRemoteEvent("leaveSession")
local sessionState = ensureRemoteEvent("sessionState")
local sessionError = ensureRemoteEvent("sessionError")

local function trim(value: string): string
	return string.gsub(value, "^%s*(.-)%s*$", "%1")
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
	for _, plr in ipairs(Players:GetPlayers()) do
		if DataService:get(plr, "session_code") == code then
			table.insert(list, plr)
		end
	end
	return list
end

local function broadcastSessionState(code: string)
	local members = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if DataService:get(plr, "session_code") == code then
			table.insert(members, {
				userId = plr.UserId,
				name = plr.Name,
				participate = DataService:get(plr, "is_seated") == true,
				isReady = DataService:get(plr, "is_ready") == true,
				isSeated = DataService:get(plr, "is_seated") == true,
			})
		end
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

	for _, plr in ipairs(Players:GetPlayers()) do
		if DataService:get(plr, "session_code") == code then
			sessionState:FireClient(plr, snapshot)
		end
	end
end

local function teardownSession(code: string)
	RoomService.destroyRoomForSession(code)

	local playersInSession = getPlayersInSession(code)
	for _, member in ipairs(playersInSession) do
		RoomService.teleportPlayerToSpawn(member)
		clearPlayerSessionState(member)
		sessionError:FireClient(member, { message = "Session closed by owner" })
	end
	sessionMetaByCode[code] = nil
end

local function leaveCurrentSession(player: Player): boolean
	local code = DataService:get(player, "session_code")
	if type(code) ~= "string" or code == "" then
		for candidateCode, meta in pairs(sessionMetaByCode) do
			if meta and meta.hostUserId == player.UserId then
				code = candidateCode
				break
			end
		end
	end
	if type(code) ~= "string" or code == "" then
		return false
	end

	local ok, err = pcall(function()
		SessionApi:LeaveSession(tostring(code), { roblox_user_id = player.UserId })
	end)
	if not ok then
		warn("[Session] Failed to leave session:", err)
	end

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

local function joinBackendSession(player: Player, code: string): boolean
	local ok, err = pcall(function()
		return SessionApi:JoinSession(tostring(code), {
			roblox_user_id = player.UserId,
			display_name = player.DisplayName,
		})
	end)
	if not ok then
		warn("[Session] Failed to join session:", err)
		return false
	end
	return true
end

local function serverJoinSession(player: Player, code: string): boolean
	if type(code) ~= "string" then
		sessionError:FireClient(player, { message = "Invalid session code" })
		return false
	end

	local cleanedCode = string.upper(trim(code))
	if cleanedCode == "" then
		sessionError:FireClient(player, { message = "Session code is required" })
		return false
	end

	if sessionMetaByCode[cleanedCode] == nil then
		sessionMetaByCode[cleanedCode] = {
			name = "Session",
			hostUserId = 0,
		}
	end

	local roomModel, roomError = RoomService.ensureRoomForSession(cleanedCode)
	if roomModel == nil then
		sessionError:FireClient(player, { message = roomError or "Could not create/load room" })
		return false
	end

	setPlayerSessionState(player, cleanedCode, true)
	RoomService.teleportPlayerToSessionRoom(player, cleanedCode)
	broadcastSessionState(cleanedCode)
	return true
end

listSessions.OnServerEvent:Connect(function(player)
	local result = SessionApi:GetSessions()
	listSessions:FireClient(player, result)
end)

createSession.OnServerEvent:Connect(function(player, sessionName: string)
	if type(sessionName) ~= "string" or trim(sessionName) == "" then
		sessionError:FireClient(player, { message = "Session name is required" })
		return
	end

	local serv_id = game.PlaceId
	local createSessionInput = {
		owner_roblox_user_id = player.UserId,
		display_name = player.DisplayName,
		name = sessionName,
		owner_server_id = serv_id,
	}
	local result = SessionApi:CreateSession(createSessionInput)
	local rawCode = result and result["code"]
	if type(rawCode) ~= "string" then
		sessionError:FireClient(player, { message = "Session creation failed" })
		return
	end

	local code = string.upper(trim(rawCode))
	sessionMetaByCode[code] = {
		name = result["name"] or sessionName,
		hostUserId = player.UserId,
		sessionId = result["id"],
	}

	-- Creator automatically joins and gets teleported into the room for this session.
	serverJoinSession(player, code)
	createSession:FireClient(player, result)
end)

joinSession.OnServerEvent:Connect(function(player, payload)
	if type(payload) ~= "table" then
		sessionError:FireClient(player, { message = "Invalid join payload" })
		return
	end

	local code = payload.code
	serverJoinSession(player, code)
	joinBackendSession(player, code)
end)

leaveSession.OnServerEvent:Connect(function(player)
	local left = leaveCurrentSession(player)
	if not left then
		sessionError:FireClient(player, { message = "You are not in a session" })
	end
end)

Players.PlayerRemoving:Connect(function(player)
	leaveCurrentSession(player)
end)
