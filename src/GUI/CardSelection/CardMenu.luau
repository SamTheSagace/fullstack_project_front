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
	local numbersList = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
	-- This component make an array of cards based on a list of number, to select one from it
	local selectedValue, setSelectedValue = React.useState(nil)
	local Finished, setFinished = React.useState(false)
	local isInteractable = selectedValue ~= nil
	
	local cardsFrame = {
		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.01, 0.1),
		}),
	}
	for index, value in ipairs(numbersList) do
		cardsFrame[`Card_{index}`] = e(Card, {
			value = value,
			selectedValue = selectedValue,
			setSelectedValue = setSelectedValue,
			LayoutOrder = index,
			isFinished = Finished,
		})
	end
	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Visible = props.isVisible,
	}, {
		MainFrame = e("Frame", {
			Size = UDim2.fromScale(0.8, 0.4),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
		}, {
			cardsFrame,
		}),
		OpenSessionMenuButton = e(CustomButton, {
			Text = "Finish Vote",
			Position = UDim2.fromScale(0.5, 0.925),
			Size = UDim2.fromScale(0.2, 0.1),
			BackgroundColor3 = Color3.fromRGB(1, 88, 181),
			ButtonColor = Color3.fromRGB(0, 122, 255),
			onButtonClick = function()
				setFinished(not Finished)
			end,
		}),
	})
end

return CardMenu
