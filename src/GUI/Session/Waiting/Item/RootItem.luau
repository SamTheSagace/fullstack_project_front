local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local ItemMenu = require(script.Parent.ItemMenu)
local React = require(ReplicatedStorage.Packages.React)
local UiValues = require(ReplicatedStorage.Types.UiValues)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local e = React.createElement

local function RootUI()
	local isMenuVisible, setIsMenuVisible = React.useState(true)

	return e(React.Fragment, nil, {
		OpenSessionMenuButton = e(CustomButton, {
			Position = UDim2.fromScale(0.5, 0.925),
			Size = UDim2.fromScale(0.2, 0.1),
			Text = if isMenuVisible then "Close Item Menu" else "Open Item Menu",
			BackgroundColor3 = not isMenuVisible and UiValues.YesButtonSec or UiValues.NoButtonSec,
			ButtonColor = not isMenuVisible and UiValues.YesButtonMain or UiValues.NoButtonMain,
			onButtonClick = function()
				setIsMenuVisible(not isMenuVisible)
			end,
		}),

		ItemMenu = e(ItemMenu, {
			isVisible = isMenuVisible,
		}),
	})
end

return RootUI
