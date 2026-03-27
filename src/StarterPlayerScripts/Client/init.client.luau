local Players = game:GetService("Players")
local Player = game:GetService("Players").LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local sessionState = eventsFolder:WaitForChild("sessionState")
local sessionError = eventsFolder:WaitForChild("sessionError")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local MountUI = require(StarterGui.GUI.MountUI)

MountUI()
DataService:init()

sessionState.OnClientEvent:Connect(function(snapshot)
	print("Received session snapshot:", snapshot)
end)

sessionError.OnClientEvent:Connect(function(err)
	local message = if type(err) == "table" then err.message else tostring(err)
	warn("Session error:", message)
end)
