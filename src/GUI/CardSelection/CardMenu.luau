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
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
	}, {
		MainFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.8),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.5,
			Visible = props.isVisible,
		}, {
			cardsFrame,
		}),

		ButtonFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.5,
			Visible = props.isVisible,
		}, {
			OpenCardMenuButton = e(CustomButton, {
				Text = "Validate vote",
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.3, 0.5),
				BackgroundColor3 = isInteractable and Color3.fromRGB(1, 88, 181) or Color3.fromRGB(179, 180, 180),
				ButtonColor = isInteractable and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(210, 211, 211),
				TextColor3 = isInteractable and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(66, 66, 66),

				Interactable = isInteractable,
				onButtonClick = function()
					handleValidate()
				end,
			}),
		}),
	})
end

return CardMenu
