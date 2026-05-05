local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Card = require(StarterGui.GUI.Voted.CardBillBoard)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement
local endVote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("endVote")
local nextItem = ReplicatedStorage:WaitForChild("Events"):WaitForChild("nextItem")
type Props = {
	localPlayer: Player,
}
local function VotedUI(props: Props)
	local isVisible, setIsVisible = React.useState(false)

	local myData, setMyData = React.useState(nil)
	React.useEffect(function()
		local onEndVote = endVote.OnClientEvent:Connect(function(players)
			setIsVisible(true)

			for _, playerData in ipairs(players) do
				if playerData.UserId == props.localPlayer.UserId then
					setMyData(playerData)
					break
				end
			end
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
	if not myData then
		return nil
	end

	return e(Card, {
		value = myData.currentVote,
		selectedValue = myData.currentVote,
		setSelectedValue = function() end,
		LayoutOrder = 1,
		isFinished = true,
		isVisible = isVisible,
	})
end
return VotedUI
