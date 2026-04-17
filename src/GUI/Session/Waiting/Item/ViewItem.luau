local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemCard = require(script.Parent.ItemCard)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local listItemsSessionIdEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("listItemsSessionId")

local CommonTypes = require(ReplicatedStorage.Types.Common)
type Item = CommonTypes.Item

local function ViewItems()
	local ItemList, setItemList = React.useState({} :: { Item })

	React.useEffect(function()
		local onListItems = listItemsSessionIdEvent.OnClientEvent:Connect(function(items)
			if items == nil then
				setItemList({})
				return
			end

			setItemList(items)
		end)
		return function()
			onListItems:Disconnect()
		end
	end, {})

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

	local hasItems = false
	for index, value in ipairs(ItemList) do
		hasItems = true
		children[`Card_{index}`] = e("Frame", {
			Size = UDim2.fromScale(0.2, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
		}, {
			card = e(ItemCard, {
				title = value.title,
				description = value.description,
				cost = value.cost,
				LayoutOrder = value.position,
				userId = value.created_by_roblox_user_id,
			}),
		})
	end

	if not hasItems then
		children.EmptyState = e("TextLabel", {
			Size = UDim2.fromOffset(200, 50),
			BackgroundTransparency = 1,
			Text = "No items in this session",
			Font = Enum.Font.Gotham,
			TextSize = 16,
			TextColor3 = Color3.fromRGB(255, 255, 255),
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
