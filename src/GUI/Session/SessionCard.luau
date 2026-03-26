local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local React = require(ReplicatedStorage.Packages.React)
local SessionHelpers = require(ReplicatedStorage.Shared.SessionHelpers)

local e = React.createElement

type props = {
	sessionData: any,
	index: number,
}

local function SessionCard(props: props)
	local playerIds = SessionHelpers.getSessionPlayerIds(props.sessionData)
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
	local plrAvatar, isReady = Players:GetUserThumbnailAsync(911172336, ThumbType, ThumbSize) -- you could use the declared id variable or simply enter it here, to showcase both I put what it would look like if you used the ID like this instead of defining in a variable

	playersChildren[`Avatar_1`] = e("ImageLabel", {
		Size = UDim2.fromOffset(38, 38),
		BackgroundColor3 = Color3.fromRGB(39, 55, 75),
		Image = plrAvatar,
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

	for playerIndex, userId in ipairs(playerIds) do
		local plrAvatar, isReady = Players:GetUserThumbnailAsync(userId, ThumbType, ThumbSize) -- you could use the declared id variable or simply enter it here, to showcase both I put what it would look like if you used the ID like this instead of defining in a variable
		playersChildren[`Avatar_{playerIndex}`] = e("ImageLabel", {
			Size = UDim2.fromOffset(38, 38),
			BackgroundColor3 = Color3.fromRGB(39, 55, 75),
			Image = plrAvatar,
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

	return e("Frame", {
		LayoutOrder = props.index,
		Size = UDim2.fromScale(1, 0.25),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
	}, {
		Stroke = e("UIStroke", {
			Color = Color3.fromRGB(42, 62, 84),
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
			Size = UDim2.fromScale(1, 0.2),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = Color3.fromRGB(238, 243, 247),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		PlayersRow = e("Frame", {
			Position = UDim2.fromScale(0,1),
            AnchorPoint = Vector2.new(0, 1),
			Size = UDim2.fromScale(1, 0.8),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, playersChildren),
	})
end

return SessionCard
