local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = playerGui:WaitForChild("InsertedObjects")
local button = screenGui:WaitForChild("CreateRoomButton")

print(button.Parent, button.Name, button.Position)

button.MouseButton1Click:Connect(function()
	print("Create Room Button Clicked")
	ReplicatedStorage:WaitForChild("b_createRoom"):FireServer()
end)
