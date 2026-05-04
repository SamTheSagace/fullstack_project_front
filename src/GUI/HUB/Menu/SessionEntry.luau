local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local SessionHelpers = require(ReplicatedStorage.Shared.SessionHelpers)
local UiValues = require(ReplicatedStorage.Types.UiValues)

local e = React.createElement

local joinSessionEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("joinSession")

type props = {
	sessionData: any,
	index: number,
}

local function SessionEntry(props: props)
	local playerIds = SessionHelpers.getSessionPlayerIds(props.sessionData)
	print(props.sessionData)
	local ThumbType = Enum.ThumbnailType.HeadShot
	local ThumbSize = Enum.ThumbnailSize.Size150x150

	local playersChildren = {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5),
		}),
	}

	local function handleJoinActivated()
		joinSessionEvent:FireServer({
			code = props.sessionData.code,
		})
	end

	for playerIndex, userId in ipairs(playerIds) do
		local plrAvatar = Players:GetUserThumbnailAsync(userId, ThumbType, ThumbSize)
		print("test", playerIndex, userId, plrAvatar)
		playersChildren[`Avatar_{playerIndex}`] = e("ImageLabel", {
			Size = UDim2.fromOffset(38, 38),
			BackgroundColor3 = UiValues.activeColor,
			Image = plrAvatar,
			ScaleType = Enum.ScaleType.Crop,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			Stroke = e("UIStroke", {
				Color = UiValues.MainGreenColor,
				Thickness = 1,
			}),
		})
	end

	return e("Frame", {
		LayoutOrder = props.index,
		Size = UDim2.fromScale(1, 0.25),
		BackgroundColor3 = UiValues.unactiveColor,
		BackgroundTransparency = 1,
	}, {
		Stroke = e("UIStroke", {
			Color = UiValues.MainGreenColor,
			Thickness = 1,
		}),
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5),
		}),
		NameLabel = e("TextLabel", {
			Text = SessionHelpers.getSessionName(props.sessionData, props.index),
			Position = UDim2.fromScale(0, 0),
			AnchorPoint = Vector2.new(0, 0),
			Size = UDim2.fromScale(1, 0.2),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = UiValues.activeText,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		JoinButton = e("TextButton", {
			Text = "Join",
			Position = UDim2.fromScale(1, 0.5),
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.fromScale(0.22, 0.7),
			BackgroundColor3 = UiValues.unactiveColor,
			TextColor3 = UiValues.unactiveText,
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			[React.Event.Activated] = handleJoinActivated,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			}),
		}),
		PlayersRow = e("Frame", {
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			Size = UDim2.fromScale(1, 0.8),
			BackgroundTransparency = 1,
		}, playersChildren),
	})
end

return SessionEntry
