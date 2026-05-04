local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local React = require(ReplicatedStorage.Packages.React)
local UiValues = require(ReplicatedStorage.Types.UiValues)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local SessionMenu = require(StarterGui.GUI.HUB.Menu.SessionMenu)
local e = React.createElement

local function HubUI()
	local isMenuVisible, setIsMenuVisible = React.useState(false)

	return e(React.Fragment, nil, {
		OpenSessionMenuButton = e(CustomButton, {
			Position = UDim2.fromScale(0.5, 0.925),
			Size = UDim2.fromScale(0.2, 0.1),
			Text = if isMenuVisible then "Close Session Menu" else "Open Session Menu",
			BackgroundColor3 = not isMenuVisible and UiValues.YesButtonSec or UiValues.NoButtonSec,
			ButtonColor = not isMenuVisible and UiValues.YesButtonMain or UiValues.NoButtonMain,
			onButtonClick = function()
				setIsMenuVisible(not isMenuVisible)
			end,
		}),

		SessionMenu = e(SessionMenu, {
			isVisible = isMenuVisible,
		}),
	})
end

return HubUI
