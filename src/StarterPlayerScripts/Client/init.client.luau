local Players = game:GetService("Players")
local Player = game:GetService("Players").LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local sessionState = ReplicatedStorage:WaitForChild("sessionState")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local MountUI = require(StarterGui.GUI.MountUI)

MountUI()
DataService:init()

sessionState.OnClientEvent:Connect(function(snapshot)
	Player.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
	print("Received session snapshot:", snapshot)
end)
