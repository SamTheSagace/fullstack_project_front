local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
-- local SessionCard = require(script.Parent.SessionCard)
local Card = require(script.Parent.Card)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local ItemCard = require(StarterGui.GUI.Session.Waiting.Item.ItemCard)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local confirmVoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("confirmVote")

type props = {
	isVisible: boolean,
	currentItemId: number,
}

local function CardMenu(props: props)
	type Item = { itemName: string, itemDescription: string, cost: number | nil, userId: number }
	local numbersList = { 1, 2, 3, 5, 8, 13 }
	-- This component make an array of cards based on a list of number, to select one from it
	local selectedValue, setSelectedValue = React.useState(nil)
	local Finished, setFinished = React.useState(false)
	local isInteractable = selectedValue ~= nil

	local function handleConfirmVote()
		confirmVoteEvent:FireServer({
			itemId = props.currentItemId,
			robloxUserId = Players.LocalPlayer.UserId,
			value = selectedValue,
		})
	end
	local ItemList: Item = {
		itemName = "Vote",
		itemDescription = "As a user i want : click on a buttton to be able to : vote on the current Item",
		cost = 3,
		userId = 3,
	}

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
		ItemFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.5),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
		}, {
			Frame = e("Frame", {
				Size = UDim2.fromScale(0.2, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
			}, {
				CurrentItem = e(ItemCard, {
					title = ItemList.itemName,
					description = ItemList.itemDescription,
					cost = ItemList.cost,
					userId = ItemList.userId,
				}),
			}),
		}),
		VoteFrame = e("Frame", {
			Size = UDim2.fromScale(0.8, 0.4),
			Position = UDim2.fromScale(0.5, 0.85),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			ZIndex = 3,
		}, {
			cardsFrame,
		}),
		OpenSessionMenuButton = e(CustomButton, {
			Text = if Finished then "Change Vote" else "Finish Vote",
			Position = UDim2.fromScale(0.5, 0.96),
			AnchorPoint = Vector2.new(0.5, 1),
			Size = UDim2.fromScale(0.2, 0.1),
			BackgroundColor3 = Color3.fromRGB(1, 88, 181),
			ButtonColor = Color3.fromRGB(0, 122, 255),
			Interactable = isInteractable,
			onButtonClick = function()
				local newFinished = not Finished
				setFinished(newFinished)
				if newFinished then
					handleConfirmVote()
				end
			end,
		}),
	})
end

return CardMenu
