local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
-- local SessionCard = require(script.Parent.SessionCard)
local Card = require(script.Parent.Card)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type props = {
	isVisible: boolean,
}

local function CardMenu(props: props)
	local numbersList = { 1, 2, 3, 5, 8, 13, 20, 40 }
	-- This component make an array of cards based on a list of number, to select one from it
	local selectedValue, setSelectedValue = React.useState(nil)
	local isInteractable = selectedValue ~= nil
	local function handleValidate()
		print("validate", selectedValue, selectedValue ~= nil)
	end
	local cardsFrame = {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.Name,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.1, 1),
			Wraps = true,
		}),
	}
	for index, value in ipairs(numbersList) do
		cardsFrame[`Card_{index}`] = e(Card, {
			value = value,
			selectedValue = selectedValue,
			setSelectedValue = setSelectedValue,
		})
	end
	return e("Frame", {
		Size = UDim2.fromScale(0.8, 0.8),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(8, 18, 31),
		Visible = props.isVisible,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 12),
		}),
		Border = e("UIStroke", {
			Color = Color3.fromRGB(44, 73, 103),
		}),
		MainFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.8),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
		}, {
			cardsFrame,
		}),

		ButtonFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
		}, {
			TextFrame = e("Frame", {
				Size = UDim2.fromScale(0.5, 1),
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
			}, {
				not isInteractable and {
					Description = e("TextLabel", {
						Text = "Choose a value to validate.",
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = UDim2.new(1, -28, 0, 36),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						TextWrapped = true,
						TextSize = 14,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				},
			}),
			ButtonFrame = e("Frame", {
				Size = UDim2.fromScale(0.5, 1),
				Position = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(1, 1),
				BackgroundTransparency = 1,
			}, {
				OpenCardMenuButton = e(CustomButton, {
					Text = "Validate vote",
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.5, 0.75),
					BackgroundColor3 = isInteractable and Color3.fromRGB(1, 88, 181) or Color3.fromRGB(179, 180, 180),
					ButtonColor = isInteractable and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(210, 211, 211),
					TextColor3 = isInteractable and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(66, 66, 66),

					Interactable = isInteractable,
					onButtonClick = function()
						handleValidate()
					end,
				}),
			}),
		}),
	})
end

return CardMenu
