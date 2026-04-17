local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local ItemCard = require(script.Parent.ItemCard)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local function ViewItems()
	type Item = { itemName: string, itemDescription: string, cost: number | nil, userId: number }

	local ItemList: { Item } = {
		{
			itemName = "Vote",
			itemDescription = "As a user i want : click on a buttton to be able to : vote on the current Item",
			cost = 3,
			userId = 3,
		},
		{
			itemName = "Create a new story",
			itemDescription = "As a user i want : create a new story to be able to: let other user vote ",
			cost = nil,
			userId = 2,
		},
		{
			itemName = "Welcome to the jungle",
			itemDescription = "As a user i want : welcome to the jungle to be able to: ouga bouga ",
			cost = nil,
			userId = 2,
		},
		{
			itemName = "Test of knowledge",
			itemDescription = "As a user i want : to be able to ",
			cost = nil,
			userId = 3,
		},
		{
			itemName = "Windows est mieux que Mac",
			itemDescription = "As a user i want : to be able to ",
			cost = nil,
			userId = 3,
		},
		{ itemName = "test", itemDescription = "As a user i want : to be able to ", cost = nil, userId = 3 },
		{ itemName = "test", itemDescription = "As a user i want : to be able to ", cost = nil, userId = 3 },
	}

	local children = {
		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Wraps = true,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 30),
		}),
	}

	for index, value in ipairs(ItemList) do
		children[`Card_{index}`] = e("Frame", {
			Size = UDim2.fromScale(0.2, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
		}, {
			card = e(ItemCard, {
				title = value.itemName,
				description = value.itemDescription,
				cost = value.cost,
				LayoutOrder = index,
				userId = value.userId,
			}),
		})
	end

	local ItemFrame = e("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
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
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
		}, {
			ItemFrame = ItemFrame,
		}),
	})
end

return ViewItems
