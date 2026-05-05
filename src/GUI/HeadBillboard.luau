local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VotedUI = require(script.Parent.VotedUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return function(localPlayer: Player)
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local head = character:WaitForChild("Head")

	local container: BillboardGui = Instance.new("BillboardGui")
	container.Name = "React"
	container.Size = UDim2.fromOffset(60, 60)
	container.StudsOffset = Vector3.new(0, 3, 0) -- lift above head
	container.AlwaysOnTop = true
	container.Parent = head

	local root = ReactRoblox.createRoot(container)
	local app = React.createElement(VotedUI, {
		localPlayer = localPlayer,
	})

	root:render(app)
end
