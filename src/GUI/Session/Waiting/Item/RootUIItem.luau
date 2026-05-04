local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local ItemMenu = require(script.Parent.ItemMenu)
local React = require(ReplicatedStorage.Packages.React)
local UiValues = require(ReplicatedStorage.Types.UiValues)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local e = React.createElement

local function RootUIItem(props)
	return e(React.Fragment, nil, {
		OpenSessionMenuButton = e(CustomButton, {
			Position = props.Position or UDim2.fromScale(0.5, 0.925),
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			Size = UDim2.fromScale(0.2, 0.1),
			Text = if props.isMenuVisible then "Close Item Menu" else "Open Item Menu",
			BackgroundColor3 = not props.isMenuVisible and UiValues.YesButtonSec or UiValues.NoButtonSec,
			ButtonColor = not props.isMenuVisible and UiValues.YesButtonMain or UiValues.NoButtonMain,
			onButtonClick = function()
				props.setIsMenuVisible(not props.isMenuVisible)
			end,
		}),

		ItemMenu = e(ItemMenu, {
			isVisible = props.isMenuVisible,
		}),
	})
end

return RootUIItem
