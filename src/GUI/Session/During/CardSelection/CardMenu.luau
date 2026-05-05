local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
-- local SessionCard = require(script.Parent.SessionCard)
local Card = require(script.Parent.Card)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local ItemCard = require(StarterGui.GUI.Session.Waiting.Item.ItemCard)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement
local CommonTypes = require(ReplicatedStorage.Types.Common)
type Item = CommonTypes.Item

local confirmVoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("confirmVote")
local canFinishVoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("canFinishVote")

type props = {
	isVisible: boolean,
	currentItem: Item,
	resetCardMenu: (resetFn: () -> ()) -> (),
}

local function CardMenu(props: props)
	local numbersList = { 1, 2, 3, 5, 8, 13 }
	-- This component make an array of cards based on a list of number, to select one from it
	local selectedValue, setSelectedValue = React.useState(nil)
	local Finished, setFinished = React.useState(false)
	local ItemShow, setItemShow = React.useState(false)
	local VoteShow, setVoteShow = React.useState(false)
	local isInteractable = selectedValue ~= nil

	React.useEffect(function()
		if props.resetCardMenu then
			props.resetCardMenu(function()
				setSelectedValue(nil)
				setFinished(false)
				setItemShow(false)
			end)
		end
	end)

	local function handleConfirmVote()
		confirmVoteEvent:FireServer({
			itemId = props.currentItem.id,
			robloxUserId = Players.LocalPlayer.UserId,
			value = selectedValue,
		})
		canFinishVoteEvent:FireServer()
	end

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

	local ItemFrame = if ItemShow
		then e("Frame", {
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
					title = props.currentItem.title,
					description = props.currentItem.description,
					cost = props.currentItem.cost,
					userId = props.currentItem.created_by_roblox_user_id,
				}),
			}),
		})
		else nil

	local ButtonsFrame = if VoteShow
		then e("Frame", {
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			ItemButton = e(CustomButton, {
				Text = if not ItemShow then "Show Item" else "Hide Item",
				Size = UDim2.fromScale(0.3, 1),
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(1, 88, 181),
				ButtonColor = Color3.fromRGB(0, 122, 255),
				onButtonClick = function()
					local newFinished = not ItemShow
					setItemShow(newFinished)
				end,
			}),

			ModalButton = e(CustomButton, {
				Text = "Close",
				BackgroundColor3 = Color3.fromRGB(1, 88, 181),
				Size = UDim2.fromScale(0.3, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ButtonColor = Color3.fromRGB(0, 122, 255),
				onButtonClick = function()
					setVoteShow(false)
				end,
			}),
			VoteButton = e(CustomButton, {
				Text = if Finished then "Change Vote" else "Confirm Vote",
				Size = UDim2.fromScale(0.3, 1),
				Position = UDim2.fromScale(1, 0.5),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = isInteractable and Color3.fromRGB(1, 88, 181) or Color3.fromRGB(1, 88, 181),
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
		else e(CustomButton, {
			Text = "Open Vote",
			BackgroundColor3 = Color3.fromRGB(1, 88, 181),
			Size = UDim2.fromScale(0.3, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ButtonColor = Color3.fromRGB(0, 122, 255),
			onButtonClick = function()
				setVoteShow(true)
			end,
		})

	return e(React.Fragment, nil, {
		Menu = e("Frame", {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Visible = props.isVisible,
		}, {
			ItemFrame = ItemFrame,
			VoteFrame = e("Frame", {
				Size = UDim2.fromScale(0.8, 0.4),
				Position = UDim2.fromScale(0.5, 0.85),
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				ZIndex = 3,
			}, {
				if VoteShow then cardsFrame else nil,
			}),
			ButtonsFrame = e("Frame", {
				Position = UDim2.fromScale(0.5, 0.96),
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.fromScale(0.7, 0.1),
				BackgroundTransparency = 1,
			}, { ButtonsFrame }),
		}),
	})
end

return CardMenu
