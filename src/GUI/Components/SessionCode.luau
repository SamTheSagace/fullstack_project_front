local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

local function SessionCode(props)
	return e("Frame", {
		Size = UDim2.fromOffset(100, 30),
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(1, 88, 181),
		Position = UDim2.fromScale(0.02, 0.02),

		-- BorderSizePixel = 0,
	}, {
		CodeText = e("TextLabel", {
			Text = props.Text or "SessionCode",
			Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
			TextScaled = false,
            TextSize = 15,
			TextColor3 = Color3.fromRGB(255, 255, 255),
		}),
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),
	})
end

return SessionCode
