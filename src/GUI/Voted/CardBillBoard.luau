local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local UiValues = require(ReplicatedStorage.Types.UiValues)
local e = React.createElement

type CardProps = {
	value: number,
	selectedValue: number?,
	setSelectedValue: (number?) -> (),
	LayoutOrder: number,
	isFinished: boolean,
}

local function CardBillBoard(props: CardProps)
	local frameRef = React.useRef(nil)

	return e("Frame", {
		Size = UDim2.fromScale(0.8, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
	}, {
		Content = e("TextButton", {
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = UiValues.activeColor,
			Text = "",
			AutoButtonColor = false,
			ClipsDescendants = true,
			ref = frameRef,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 2),
			}),
			Border = e("UIStroke", {
				Thickness = 2,
				Color = UiValues.MainGreenColor,
				Enabled = true,
				ApplyStrokeMode = "Border",
			}),
			Label = e("TextLabel", {
				Text = tostring(props.value),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 30,
				TextColor3 = UiValues.activeText,
			}),
		}),
	})
end

return CardBillBoard
