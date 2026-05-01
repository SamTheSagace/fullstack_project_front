local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type Props = {
	playerCount: number?,
	seatedCount: number?,
	readyCount: number?,
	isOwner: boolean?,
	isCurrentPlayerReady: boolean?,
	showActionButton: boolean?,
	actionEnabled: boolean?,
	actionText: string?,
	helperText: string?,
	isMenuVisible: boolean?,
	onAction: (() -> ())?,
}

local function WaitingStateButton(props: Props)
	local isOwner = props.isOwner == true
	local showActionButton = props.showActionButton == true
	local actionEnabled = props.actionEnabled ~= false
	local backgroundColor = if isOwner
		then Color3.fromRGB(18, 110, 62)
		else if props.isCurrentPlayerReady == true
			then Color3.fromRGB(184, 126, 21)
			else Color3.fromRGB(17, 93, 172)

	return e("Frame", {
		Size = UDim2.fromScale(0.3, 0.22),
		Position = UDim2.fromScale(0.5, 0.98),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Color3.fromRGB(8, 18, 31),
		Visible = not props.isMenuVisible,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.12, 0),
		}),
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0.06, 0),
			PaddingRight = UDim.new(0.06, 0),
			PaddingTop = UDim.new(0.08, 0),
			PaddingBottom = UDim.new(0.08, 0),
		}),
		Stats = e("TextLabel", {
			Size = UDim2.fromScale(1, 0.45),
			BackgroundTransparency = 1,
			Text = string.format(
				"Players: %d  Seated: %d  Ready: %d",
				props.playerCount or 0,
				props.seatedCount or 0,
				props.readyCount or 0
			),
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextWrapped = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
		}),
		Helper = e("TextLabel", {
			Size = UDim2.fromScale(1, if showActionButton then 0.15 else 0.45),
			Position = UDim2.fromScale(0, 0.45),
			BackgroundTransparency = 1,
			Text = props.helperText or "",
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextWrapped = true,
			TextColor3 = Color3.fromRGB(196, 206, 218),
			Visible = (props.helperText or "") ~= "",
		}),
		ActionButton = showActionButton and e("TextButton", {
			Size = UDim2.fromScale(1, 0.32),
			Position = UDim2.fromScale(0, 0.68),
			BackgroundColor3 = if actionEnabled then backgroundColor else Color3.fromRGB(90, 90, 90),
			Text = props.actionText or (if isOwner then "Start Session" else "Ready"),
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			AutoButtonColor = actionEnabled,
			Active = actionEnabled,
			Selectable = actionEnabled,
			[React.Event.Activated] = function()
				if actionEnabled and props.onAction then
					props.onAction()
				end
			end,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0.18, 0),
			}),
		}) or nil,
	})
end

return WaitingStateButton
