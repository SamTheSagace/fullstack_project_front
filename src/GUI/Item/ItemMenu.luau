local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local CreateItemForm = require(script.Parent.CreateItemForm)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type props = {
	isVisible: boolean,
}

local function ItemMenu(props: props)
	local isCreate, setIsCreate = React.useState(true)

	return e("Frame", {
		Size = UDim2.fromScale(0.8, 0.72),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(8, 18, 31),
		-- Visible = props.isVisible,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),
		TopFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
		}, {
			CreateTab = e(CustomButton, {
				Text = "Create an Item",
				Position = UDim2.fromScale(0.25, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.5, 1),
				BackgroundColor3 = not isCreate and Color3.fromRGB(175, 175, 175) or Color3.fromRGB(8, 18, 31),
				ButtonColor = not isCreate and Color3.fromRGB(175, 175, 175) or Color3.fromRGB(8, 18, 31),
				Interactable = not isCreate,
				onButtonClick = function()
					setIsCreate(true)
				end,
			}),
			ViewTab = e(CustomButton, {
				Text = "View Item(s)",
				Position = UDim2.fromScale(0.75, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.5, 1),
				BackgroundColor3 = isCreate and Color3.fromRGB(175, 175, 175) or Color3.fromRGB(8, 18, 31),
				ButtonColor = isCreate and Color3.fromRGB(175, 175, 175) or Color3.fromRGB(8, 18, 31),
				Interactable = isCreate,
				onButtonClick = function()
					setIsCreate(false)
				end,
			}),
		}),
		BottomFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.75),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
		}, {
			CreateItemForm = e(CreateItemForm),
		}),
	})
end

return ItemMenu
