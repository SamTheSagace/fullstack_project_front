local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local CardMenu = require(StarterGui.GUI.CardSelection.CardMenu)
local React = require(ReplicatedStorage.Packages.React)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local e = React.createElement

local function VoteMenu()
	local isMenuVisible, setIsMenuVisible = React.useState(false)

	return e(React.Fragment, nil, {
		OpenSessionMenuButton = e(CustomButton, {
			Text = "Open Menu",
			Position = UDim2.fromScale(0.5, 0.925),
			Size = UDim2.fromScale(0.2, 0.1),
			BackgroundColor3 = Color3.fromRGB(1, 88, 181),
			ButtonColor = Color3.fromRGB(0, 122, 255),
			onButtonClick = function()
				setIsMenuVisible(not isMenuVisible)
			end,
		}),

		SessionMenu = e(CardMenu, {
			isVisible = true,
		}),
	})
end

return VoteMenu
