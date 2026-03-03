local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Card = require(StarterGui.GUI.Components.Card)
local React = require(ReplicatedStorage.Packages.React)
local SessionHelpers = require(ReplicatedStorage.Shared.SessionHelpers)

local e = React.createElement

type props = {
	sessionData: any,
	index: number,
}

local function SessionCard(props: props)
	local playerIds = SessionHelpers.getSessionPlayerIds(props.sessionData)
	local playersChildren = {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}),
	}

	for playerIndex, userId in ipairs(playerIds) do
		playersChildren[`Avatar_{playerIndex}`] = e("ImageLabel", {
			Size = UDim2.fromOffset(38, 38),
			BackgroundColor3 = Color3.fromRGB(39, 55, 75),
			Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=100&h=100`,
			ScaleType = Enum.ScaleType.Crop,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(79, 102, 128),
				Thickness = 1,
			}),
		})
	end

	return e(Card, {
		LayoutOrder = props.index,
		Size = UDim2.new(1, -10, 0, 86),
		BackgroundColor3 = Color3.fromRGB(17, 26, 39),
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0, 2),
		}),
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(42, 62, 84),
			Thickness = 1,
		}),
		NameLabel = e("TextLabel", {
			Text = SessionHelpers.getSessionName(props.sessionData, props.index),
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.new(1, -24, 0, 26),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = Color3.fromRGB(238, 243, 247),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		PlayersRow = e("Frame", {
			Position = UDim2.fromOffset(12, 40),
			Size = UDim2.new(1, -24, 0, 38),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, playersChildren),
	})
end

return SessionCard
