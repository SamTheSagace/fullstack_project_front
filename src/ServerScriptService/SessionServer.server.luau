local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = script.Parent:WaitForChild("Services")
local SessionService = require(Services:WaitForChild("SessionService"))
local RoomService = require(Services:WaitForChild("RoomService"))

local DataService = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("DataService")).server

DataService:init({
	template = {
		session_code = nil,
		is_seated = false,
		is_ready = false,
		current_vote = nil,
	},
})

local function trim(value: string): string
	return string.gsub(value, "^%s*(.-)%s*$", "%1")
end

local function ensureRemoteEvent(parent: Instance, name: string): RemoteEvent
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = parent
	return remote
end

local function ensureRemotes()
	local remotes = ReplicatedStorage:FindFirstChild("Events")
	if remotes == nil then
		remotes = Instance.new("Folder")
		remotes.Name = "Events"
		remotes.Parent = ReplicatedStorage
	end

	return {
		JoinSession = ensureRemoteEvent(remotes, "JoinSession"),
		CreateSession = ensureRemoteEvent(remotes, "CreateSession"),
		SessionState = ensureRemoteEvent(remotes, "SessionState"),
		SessionError = ensureRemoteEvent(remotes, "SessionError"),
	}
end

local Remotes = ensureRemotes()

local function sendError(player: Player, message: string)
	Remotes.SessionError:FireClient(player, { message = message })
end

local function setPlayerState(player: Player, code: string?, isSeated: boolean)
	local function updateField(key: string, value: any)
		local ok, err = pcall(function()
			DataService:update(player, key, function()
				return value
			end)
		end)
		if not ok then
			warn("[SessionServer] DataService update failed:", key, err)
		end
	end

	updateField("session_code", code)
	updateField("is_seated", isSeated)
	updateField("is_ready", false)
	updateField("current_vote", nil)
end

local function broadcastSnapshot(snapshot)
	if snapshot == nil then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if DataService:get(player, "session_code") == snapshot.code then
			Remotes.SessionState:FireClient(player, snapshot)
		end
	end
end

Remotes.CreateSession.OnServerEvent:Connect(function(player: Player, payload)
	local name = if type(payload) == "table" then payload.name else payload
	if type(name) ~= "string" then
		sendError(player, "Invalid session name")
		return
	end

	name = trim(name)
	if name == "" then
		sendError(player, "Session name is required")
		return
	end

	local ok, result = SessionService.createSession(player, name)
	if not ok then
		sendError(player, result)
		return
	end

	RoomService.ensureRoomSpawned()

	local seatIndex = RoomService.assignSeat(player)
	if seatIndex ~= nil then
		SessionService.setSeated(player.UserId, seatIndex)
	end

	local snapshot = SessionService.getSnapshot(result.code) or result
	setPlayerState(player, snapshot.code, seatIndex ~= nil)
	broadcastSnapshot(snapshot)
end)

Remotes.JoinSession.OnServerEvent:Connect(function(player: Player, payload)
	if type(payload) ~= "table" then
		sendError(player, "Invalid join payload")
		return
	end

	local code = payload.code
	local participate = payload.participate == true

	if type(code) ~= "string" then
		sendError(player, "Invalid session code")
		return
	end

	code = string.upper(trim(code))
	if code == "" then
		sendError(player, "Session code is required")
		return
	end

	local ok, result = SessionService.joinSession(player, code, participate)
	if not ok then
		sendError(player, result)
		return
	end

	local seatIndex = nil
	if participate then
		seatIndex = RoomService.assignSeat(player)
		if seatIndex ~= nil then
			SessionService.setSeated(player.UserId, seatIndex)
		end
	else
		SessionService.setSeated(player.UserId, nil)
	end

	local snapshot = SessionService.getSnapshot(code) or result
	setPlayerState(player, code, seatIndex ~= nil)
	broadcastSnapshot(snapshot)
end)
