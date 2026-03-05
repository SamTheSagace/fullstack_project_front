local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SessionApi = require(ReplicatedStorage.Api.SessionApi)

local listSessions = ReplicatedStorage:WaitForChild("listSessions")
local createSession = ReplicatedStorage:WaitForChild("createSession")
local joinSession = ReplicatedStorage:WaitForChild("joinSession")

local DTO = require(ReplicatedStorage.Types.DTO)
type CreateSessionInput = DTO.CreateSessionInput

-- local result = Session.GetSessions()

listSessions.OnServerEvent:Connect(function(player)
	local result = SessionApi:GetSessions()
	print(result)
	listSessions:FireClient(player, result)
end)

createSession.OnServerEvent:Connect(function(player, sessionName: string)
	local createSessionInput = {
		owner_roblox_user_id = player.UserId,
		name = sessionName,
	}
	local result = SessionApi:CreateSession(createSessionInput)
	local sessionCode = result and result["code"]
	print(sessionCode)
	joinSession:FireClient(player, { sessionCode, true }) -- auto-join the session after creating
	createSession:FireClient(player, result)
end)
