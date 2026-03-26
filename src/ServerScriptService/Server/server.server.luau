local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SessionApi = require(ReplicatedStorage.Api.SessionApi)
local DataService = require(ReplicatedStorage.Packages.DataService).server

DataService:init({
	template = {
		session_code = nil,
		is_seated = false,
		is_ready = false,
		current_vote = nil,
	},
})

local function ensureRemoteEvent(name: string): RemoteEvent
	local eventFolder = ReplicatedStorage:FindFirstChild("Events")
	if not eventFolder then
		eventFolder = Instance.new("Folder")
		eventFolder.Name = "Events"
		eventFolder.Parent = ReplicatedStorage
	end
	local existing = eventFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = eventFolder
	return remote
end

local listSessions = ensureRemoteEvent("listSessions")
local createSession = ensureRemoteEvent("createSession")
local joinSession = ensureRemoteEvent("joinSession")
local sessionState = ensureRemoteEvent("sessionState")
local sessionError = ensureRemoteEvent("sessionError")

local DTO = require(ReplicatedStorage.Types.DTO)
type CreateSessionInput = DTO.CreateSessionInput

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

local function teleportPlayerUpForTest(player: Player)
	local ok, err = pcall(function()
		local character = player.Character or player.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart")
		root.CFrame = root.CFrame + Vector3.new(0, 1000, 0)
	end)
	if not ok then
		warn("[Session] Teleport test failed:", err)
	end
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

	local snapshot = {
		code = code,
		name = "Session",
		phase = "waiting",
		hostUserId = members[1] and members[1].userId or 0,
		members = members,
		seatMap = {},
	}

	for _, plr in ipairs(Players:GetPlayers()) do
		if DataService:get(plr, "session_code") == code then
			sessionState:FireClient(plr, snapshot)
		end
	end
end

local function serverJoinSession(player: Player, code: string, participate: boolean)
	if type(code) ~= "string" then
		sessionError:FireClient(player, { message = "Invalid session code" })
		return false
	end

	local cleanedCode = string.upper(trim(code))
	if cleanedCode == "" then
		sessionError:FireClient(player, { message = "Session code is required" })
		return false
	end

	setPlayerSessionState(player, cleanedCode, participate)
	teleportPlayerUpForTest(player) -- temporary test behavior
	broadcastSessionState(cleanedCode)
	return true
end

listSessions.OnServerEvent:Connect(function(player)
	local result = SessionApi:GetSessions()
	print(result)
	listSessions:FireClient(player, result)
end)

createSession.OnServerEvent:Connect(function(player, sessionName: string)
	if type(sessionName) ~= "string" or trim(sessionName) == "" then
		sessionError:FireClient(player, { message = "Session name is required" })
		return
	end

	local createSessionInput = {
		owner_roblox_user_id = player.UserId,
		name = sessionName,
	}
	local result = SessionApi:CreateSession(createSessionInput)
	local sessionCode = result and result["code"]
	if not sessionCode then
		sessionError:FireClient(player, { message = "Session creation failed" })
		return
	end

	-- Auto-join the creator to the newly created session.
	serverJoinSession(player, sessionCode, true)

	createSession:FireClient(player, result)
end)

joinSession.OnServerEvent:Connect(function(player, payload)
	if type(payload) ~= "table" then
		sessionError:FireClient(player, { message = "Invalid join payload" })
		return
	end

	local code = payload.code
	local participate = payload.participate == true
	serverJoinSession(player, code, participate)
end)
