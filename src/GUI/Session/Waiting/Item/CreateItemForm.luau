local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local function CreateItemForm()
	local ItemName, setItemName = React.useState("")
	local ItemDescription, setItemDescription = React.useState("")
	local function handleReset()
		setItemDescription("")
		setItemName("")
	end
	local function handleCreate()
		print(ItemName, ItemDescription)
	end
	local canCreate = ItemName ~= "" and ItemDescription ~= ""
	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		Border = e("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
		}),
		NameFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.25),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
		}, {
			NameLabel = e("TextLabel", {
				Text = "Item name :",
				Position = UDim2.fromScale(0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				Size = UDim2.fromScale(1, 0.3),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextYAlignment = Enum.TextYAlignment.Top,
				TextXAlignment = Enum.TextXAlignment.Center,
			}),
			NameInput = e("TextBox", {
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.fromScale(1, 0.7),
				PlaceholderText = "Placeholder",
				Text = ItemDescription,
				ClearTextOnFocus = false,
				Font = Enum.Font.Gotham,
				TextSize = 16,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextXAlignment = Enum.TextXAlignment.Center,
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				PlaceholderColor3 = Color3.fromRGB(196, 206, 218),
				[React.Change.Text] = function(textBox)
					setItemDescription(textBox.Text)
				end,
			}),
		}),
		DescriptionFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.5),
			Position = UDim2.fromScale(0.5, 0.25),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
		}, {
			NameLabel = e("TextLabel", {
				Text = "Item Description :",
				Position = UDim2.fromScale(0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				Size = UDim2.fromScale(1, 0.25),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),
			NameInput = e("TextBox", {
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.fromScale(1, 0.75),
				PlaceholderText = "Description Placeholder",
				Text = ItemName,
				ClearTextOnFocus = false,
				Font = Enum.Font.Gotham,
				TextSize = 16,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextXAlignment = Enum.TextXAlignment.Center,
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				PlaceholderColor3 = Color3.fromRGB(196, 206, 218),
				[React.Change.Text] = function(textBox)
					setItemName(textBox.Text)
				end,
			}),
		}),
		ButtonsFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.25),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
		}, {
			Cancel = e(CustomButton, {
				Text = "Cancel",
				Position = UDim2.fromScale(0.25, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.25, 0.5),
				BackgroundColor3 = Color3.fromRGB(61, 61, 61),
				ButtonColor = Color3.fromRGB(163, 163, 163),
				onButtonClick = function()
					handleReset()
				end,
			}),
			Validate = e(CustomButton, {
				Text = "Validate",
				Position = UDim2.fromScale(0.75, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.25, 0.5),
				BackgroundColor3 = canCreate and Color3.fromRGB(18, 61, 90) or Color3.fromRGB(61, 61, 61),
				ButtonColor = canCreate and Color3.fromRGB(50, 128, 184) or Color3.fromRGB(163, 163, 163),
				Interactable = canCreate,
				onButtonClick = function()
					handleCreate()
				end,
			}),
		}),
	})
end

return CreateItemForm
