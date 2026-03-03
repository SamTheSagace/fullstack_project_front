local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type props = {
	Children: React.ReactChild,
	Size: UDim2,
	Position: UDim2,
	AnchorPoint: Vector2,
	BackgroundTransparency: number,
	BackgroundColor3: Color3,
	BorderColor: Color3 | "None",
	BorderRadius: UDim,
	isVisible: boolean,
	onButtonClick: () -> (),
}

local function Card(props: props)
	React.useEffect(function()
		print(props.isVisible)
	end, {})
	return e("Frame", {
		Size = props.Size or UDim2.fromScale(0.3, 0.3),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundTransparency = props.BackgroundTransparency or 0,
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(1, 181, 28),
		Visible = props.isVisible,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = props.BorderRadius or UDim.new(0.2, 0),
		}),
		Border = e("UIStroke", {
			Color = props.BorderColor == "None" and Color3.fromRGB(0, 0, 0) or props.BorderColor,
			Thickness = 2,
		}),
	}, props.Children)
end

return Card
