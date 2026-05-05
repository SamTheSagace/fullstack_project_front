local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local GUI = require(StarterGui.GUI.GUI)
local HeadBillboard = require(StarterGui.GUI.HeadBillboard)
local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local sessionState = eventsFolder:WaitForChild("sessionState")
local errorEvent = eventsFolder:WaitForChild("errorEvent")

local DataService = require(ReplicatedStorage.Packages.DataService).client

GUI()
for _, player in Players:GetPlayers() do
	HeadBillboard(player)
end
DataService:init()

Players.PlayerAdded:Connect(function(player)
	HeadBillboard(player)
end)

sessionState.OnClientEvent:Connect(function(snapshot)
	print("Received session snapshot:", snapshot)
end)

errorEvent.OnClientEvent:Connect(function(err)
	local message = if type(err) == "table" then err.message else tostring(err)
	warn("Session error:", message)
end)
