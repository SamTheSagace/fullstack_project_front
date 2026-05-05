local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Card = require(StarterGui.GUI.Voted.CardBillBoard)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement
local endVote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("endVote")
local nextItem = ReplicatedStorage:WaitForChild("Events"):WaitForChild("nextItem")
type Props = {
	value: number,
}
local function VotedUI(props: Props)
	local isVisible, setIsVisible = React.useState(false)
	React.useEffect(function()
		local onEndVote = endVote.OnClientEvent:Connect(function(players)
			setIsVisible(true)
			print(players)
		end)
		return function()
			onEndVote:Disconnect()
		end
	end, {})
	React.useEffect(function()
		local onSessionsReceived = nextItem.OnClientEvent:Connect(function()
			setIsVisible(false)
		end)
		return function()
			onSessionsReceived:Disconnect()
		end
	end, {})
	return e(Card, {
		value = props.value,
		selectedValue = props.value,
		setSelectedValue = {},
		LayoutOrder = 1,
		isFinished = true,
		isVisible = isVisible,
	})
end
return VotedUI
