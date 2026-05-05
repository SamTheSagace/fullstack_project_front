local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Card = require(StarterGui.GUI.Voted.CardBillBoard)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type Props = {
	value: number,
}
local function VotedUI(props: Props)
	return e(Card, {
		value = props.value,
		selectedValue = props.value,
		setSelectedValue = {},
		LayoutOrder = 1,
		isFinished = true,
	})
end
return VotedUI
