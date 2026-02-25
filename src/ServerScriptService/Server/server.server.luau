local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Session = require(ReplicatedStorage.Api.Session)
local b_createRoom = ReplicatedStorage:WaitForChild("b_createRoom")
-- local result = Session.GetSessions()

b_createRoom.OnServerEvent:Connect(function(player)
	local result = Session.GetSessions()
	print("Sessions retrieved:", result)
end)