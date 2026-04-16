local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local ItemCard = require(script.Parent.ItemCard)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local function ViewItems()
	local ItemList = {
		{
			itemName = "Vote",
			itemDescription = "As a user i want : click on a buttton to be able to : vote on the current Item",
			cost = 3,
		},
		{
			itemName = "Create a new story",
			itemDescription = "As a user i want : create a new story to be able to: let other user vote ",
			cost = nil,
		},
		{
			itemName = "Welcome to the jungle",
			itemDescription = "As a user i want : welcome to the jungle to be able to: ouga bouga ",
			cost = nil,
		},
		{ itemName = "Test of knowledge", itemDescription = "As a user i want : to be able to ", cost = nil },
		{ itemName = "Windows est mieux que Mac", itemDescription = "As a user i want : to be able to ", cost = nil },
		{ itemName = "test", itemDescription = "As a user i want : to be able to ", cost = nil },
		{ itemName = "test", itemDescription = "As a user i want : to be able to ", cost = nil },
	}

	local children = {
		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Wraps = true,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.05, 0),
		}),
	}

	for index, value in ipairs(ItemList) do
		children[`Card_{index}`] = e(ItemCard, {
			title = value.itemName,
			description = value.itemDescription,
			cost = value.cost,
			LayoutOrder = index,
		})
	end

	local ItemFrame = e("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		BackgroundTransparency = 1,
	}, children)

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 0.5),
		}),
		MainFrame = e("Frame", {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
		}, {
			ItemFrame = ItemFrame,
		}),
	})
end

return ViewItems
