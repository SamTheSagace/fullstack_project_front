local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SessionService = require(ReplicatedStorage.Shared.SessionService)

local Packages = ReplicatedStorage:WaitForChild("Packages")
local DataService = require(Packages.DataService).server -- per docs :contentReference[oaicite:2]{index=2}

DataService:init({
	template = {
		session_code = nil,
		role = "player",
		is_seated = false,
		is_ready = false,
		current_vote = nil,
	},
})

local JoinSession = ReplicatedStorage:WaitForChild("joinSession")
local SessionState = ReplicatedStorage:WaitForChild("sessionState")

local function pushStateToSession(code)
	local snapshot = SessionService:getSnapshot(code)
	-- send snapshot to all players in that session
	for _, plr in ipairs(Players:GetPlayers()) do
		if DataService:get(plr, "session_code") == code then
			SessionState:FireClient(plr, snapshot)
		end
	end
end

JoinSession.OnServerEvent:Connect(function(player, payload)
	-- payload = { code = "ABC123", participate = true/false }
	local code = payload and payload.code
	local participate = payload and payload.participate

	if type(code) ~= "string" or #code < 3 then
		return
	end

	local ok, err = SessionService:join(code, player.UserId, player.Name, participate)
	if not ok then
		-- optionally notify client of error
		return
	end

	-- update per-player data via DataService
	DataService:update(player, "session_code", function()
		return code
	end)
	DataService:update(player, "is_seated", function()
		return participate and true or false
	end)
	DataService:update(player, "role", function(current)
		return SessionService:isHost(code, player.UserId) and "host" or (participate and "player" or "observer")
	end)

	pushStateToSession(code)
end)
