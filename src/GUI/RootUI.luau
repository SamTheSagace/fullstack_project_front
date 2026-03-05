local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local React = require(ReplicatedStorage.Packages.React)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local SessionMenu = require(StarterGui.GUI.Session.SessionMenu)
local e = React.createElement

local function RootUI()
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

		SessionMenu = e(SessionMenu, {
			isVisible = isMenuVisible,
		}),
	})
end

return RootUI
