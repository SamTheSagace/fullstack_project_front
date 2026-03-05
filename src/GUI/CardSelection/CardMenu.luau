local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local SessionCard = require(script.Parent.SessionCard)
local Card = require(script.Parent.Card)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type props = {
	isVisible: boolean,
}

local function CardMenu(props: props)
	local numbersList = { 1, 2, 3, 5, 8, 13, 20, 40 }
	local selectedValue, setSelectedValue = React.useState(nil)
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
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.5,
		Visible = props.isVisible,
	}, { cardsFrame })
end

return CardMenu
