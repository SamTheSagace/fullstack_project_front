local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local ItemMenu = require(script.Parent.ItemMenu)
local React = require(ReplicatedStorage.Packages.React)
local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local e = React.createElement

local function RootUI()
	local isMenuVisible, setIsMenuVisible = React.useState(true)

	return e(React.Fragment, nil, {
		OpenSessionMenuButton = e(CustomButton, {
			Text = "Item Menu",
			Position = UDim2.fromScale(0.5, 0.925),
			Size = UDim2.fromScale(0.2, 0.1),
			BackgroundColor3 = Color3.fromRGB(1, 88, 181),
			ButtonColor = Color3.fromRGB(0, 122, 255),
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
