local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local GUI = require(StarterGui.GUI.GUI)
local HeadBillboard = require(StarterGui.GUI.HeadBillboard)
local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local sessionState = eventsFolder:WaitForChild("sessionState")
local closeVote = eventsFolder:WaitForChild("closeVote")
local errorEvent = eventsFolder:WaitForChild("errorEvent")

local DataService = require(ReplicatedStorage.Packages.DataService).client

GUI()

DataService:init()

sessionState.OnClientEvent:Connect(function(snapshot)
	print("Received session snapshot:", snapshot)
end)

errorEvent.OnClientEvent:Connect(function(err)
	local message = if type(err) == "table" then err.message else tostring(err)
	warn("Session error:", message)
end)

closeVote.OnClientEvent:Connect(function(snapshot)
	HeadBillboard(1)
end)
