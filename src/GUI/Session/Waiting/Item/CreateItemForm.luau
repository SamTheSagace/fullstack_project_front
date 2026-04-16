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
	local unactiveColor = Color3.fromRGB(79, 104, 110)
	local textColor = Color3.fromRGB(80, 45, 16)
	local PlaceHolderTextColor = Color3.fromRGB(92, 71, 55)

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 0.5),
		}),
		NameFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.25),
			Position = UDim2.fromScale(0.5, 0.05),
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
				TextColor3 = textColor,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextXAlignment = Enum.TextXAlignment.Center,
			}),
			NameInputFrame = e("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.fromScale(0.5, 0.7),
			}, {
				NameInput = e("TextBox", {
					TextColor3 = textColor,
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromScale(1, 0.5),
					PlaceholderText = "Placeholder",
					Text = ItemName,
					ClearTextOnFocus = false,
					Font = Enum.Font.Gotham,
					TextSize = 16,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextXAlignment = Enum.TextXAlignment.Center,
					BackgroundTransparency = 0.5,
					BackgroundColor3 = unactiveColor,
					BorderSizePixel = 0,
					PlaceholderColor3 = PlaceHolderTextColor,
					[React.Change.Text] = function(textBox)
						setItemName(textBox.Text)
					end,
					ZIndex = 3,
				}),
			}),
		}),
		DescriptionFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.45),
			Position = UDim2.fromScale(0.5, 0.3),
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
				TextColor3 = textColor,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),
			NameInput = e("TextBox", {
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.fromScale(0.5, 0.75),
				PlaceholderText = "Description Placeholder",
				Text = ItemDescription,
				ClearTextOnFocus = false,
				Font = Enum.Font.Gotham,
				TextSize = 16,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextXAlignment = Enum.TextXAlignment.Center,
				BackgroundTransparency = 0.5,
				BackgroundColor3 = unactiveColor,
				BorderSizePixel = 0,
				TextColor3 = textColor,
				PlaceholderColor3 = PlaceHolderTextColor,
				[React.Change.Text] = function(textBox)
					setItemDescription(textBox.Text)
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
				Text = "Reset",
				Position = UDim2.fromScale(0.25, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.25, 0.5),
				BackgroundColor3 = canCreate and Color3.fromRGB(109, 61, 61) or Color3.fromRGB(61, 61, 61),
				ButtonColor = canCreate and Color3.fromRGB(199, 139, 139) or Color3.fromRGB(107, 107, 107),
				Interactable = canCreate,
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
				ButtonColor = canCreate and Color3.fromRGB(50, 128, 184) or Color3.fromRGB(107, 107, 107),
				Interactable = canCreate,
				onButtonClick = function()
					handleCreate()
				end,
			}),
		}),
	})
end

return CreateItemForm
