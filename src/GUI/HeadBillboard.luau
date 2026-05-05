local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VotedUI = require(script.Parent.VotedUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return function()
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local head = character:WaitForChild("Head")

	local container: BillboardGui = Instance.new("BillboardGui")
	container.Name = "React"
	container.Size = UDim2.fromOffset(60, 60)
	container.StudsOffset = Vector3.new(0, 3, 0) -- lift above head
	container.AlwaysOnTop = true
	container.Parent = head

	local root = ReactRoblox.createRoot(container)
	local app = React.createElement(VotedUI)

	root:render(app)
end
