local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type props = {
	Text: string,
	Size: UDim2,
	Position: UDim2,
	AnchorPoint: Vector2,
	BackgroundTransparency: number,
	BackgroundColor3: Color3,
	ButtonColor: Color3,
	TextScaled: boolean,
	TextColor3: Color3,
	onButtonClick: () -> (),
	Interactable: boolean,
	Visible: boolean?,
}

local function CustomButton(props: props)
	local isVisible = props.Visible ~= false
	return isVisible
		and e("Frame", {
			Size = props.Size or UDim2.fromScale(0.2, 0.1),
			Position = props.Position or UDim2.fromScale(0.5, 0.5),
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			BackgroundTransparency = props.BackgroundTransparency or 0,
			BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(1, 88, 181),
			-- BorderSizePixel = 0,
		}, {
			button = e("TextButton", {
				Text = props.Text or "Button",
				Size = UDim2.fromScale(1, 0.875),
				Position = UDim2.fromOffset(0, 0),
				BackgroundTransparency = props.BackgroundTransparency or 0,
				BackgroundColor3 = props.ButtonColor or Color3.fromRGB(0, 122, 255),
				TextScaled = props.TextScaled or true,
				TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
				Interactable = props.Interactable,
				[React.Event.Activated] = function()
					props.onButtonClick()
				end,
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(0.2, 0),
				}),
				UIPadding = e("UIPadding", {
					PaddingLeft = UDim.new(0.1, 0),
					PaddingRight = UDim.new(0.1, 0),
					PaddingTop = UDim.new(0.1, 0),
					PaddingBottom = UDim.new(0.1, 0),
				}),
			}),
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0.2, 0),
			}),
		})
end

return CustomButton
