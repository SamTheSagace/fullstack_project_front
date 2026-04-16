local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local CreateItemForm = require(script.Parent.CreateItemForm)
local ViewItems = require(script.Parent.ViewItem)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type props = {
	isVisible: boolean,
}

local function ItemMenu(props: props)
	local isCreate, setIsCreate = React.useState(false)
	local activeColor = Color3.fromRGB(106, 186, 206)
	local unactiveColor = Color3.fromRGB(216, 216, 216)
	return e("Frame", {
		Size = UDim2.fromScale(0.8, 0.72),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = activeColor,
		Visible = props.isVisible,
		ClipsDescendants = true,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 20),
		}),
		TopFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = activeColor,
			BorderSizePixel = 0,
		}, {
			CreateTab = e("TextButton", {
				Text = "Create an Item",
				Size = UDim2.fromScale(0.5, 1),
				Position = UDim2.fromScale(0.25, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = isCreate and activeColor or unactiveColor,
				TextScaled = true,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Interactable = not isCreate,
				[React.Event.Activated] = function()
					setIsCreate(true)
				end,
				BorderSizePixel = 0,
			}),
			ViewTab = e("TextButton", {
				Text = "View Item(s)",
				Position = UDim2.fromScale(0.75, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.5, 1),
				BackgroundColor3 = not isCreate and activeColor or unactiveColor,
				TextScaled = true,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Interactable = isCreate,
				[React.Event.Activated] = function()
					setIsCreate(false)
				end,
				BorderSizePixel = 0,
			}),
		}),
		BottomFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.75),
			Position = UDim2.fromScale(0.5, 0.90),
			AnchorPoint = Vector2.new(0.5, 0.90),
			BackgroundTransparency = 1,
		}, { isCreate and { CreateItemForm = e(CreateItemForm) } or { ViewItems = e(ViewItems) } }),
	})
end

return ItemMenu
