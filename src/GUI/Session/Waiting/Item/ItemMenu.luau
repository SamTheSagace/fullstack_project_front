local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CreateItemForm = require(script.Parent.CreateItemForm)
local ViewItems = require(script.Parent.ViewItem)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type props = {
	isVisible: boolean,
}

local function ItemMenu(props: props)
	local isCreate, setIsCreate = React.useState(true)
	local activeColor = Color3.fromRGB(212, 210, 199)
	local unactiveColor = Color3.fromRGB(85, 79, 73)
	local activeText = Color3.fromRGB(80, 45, 16)
	local unactiveText = Color3.fromRGB(255, 255, 255)

	return e("Frame", {
		Size = UDim2.fromScale(0.8, 0.72),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = activeColor,
		Visible = props.isVisible,
		ClipsDescendants = true,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 20),
		}),
		TopFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.2),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			CreateTab = e("Frame", {
				Size = UDim2.fromScale(0.5, 1),
				Position = UDim2.fromScale(0.25, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = isCreate and activeColor or unactiveColor,
				BorderSizePixel = 0,
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(0, 20),
				}),
				BgFrame = e("Frame", {
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BorderSizePixel = 0,
					BackgroundColor3 = isCreate and activeColor or unactiveColor,
					ZIndex = 2,
				}, { UICorner = e("UICorner", {
					CornerRadius = UDim.new(0, 20),
				}) }),
				BottomLeft = e("Frame", {
					Size = UDim2.fromScale(0.5, 0.5),
					Position = UDim2.fromScale(0, 1),
					AnchorPoint = Vector2.new(0, 1),
					BorderSizePixel = 0,
					BackgroundColor3 = isCreate and activeColor or unactiveColor,
				}),
				TopRight = e("Frame", {
					Size = UDim2.fromScale(0.5, 0.5),
					Position = UDim2.fromScale(1, 0),
					AnchorPoint = Vector2.new(1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = unactiveColor,
				}),
				TabButton = e("TextButton", {
					Text = "Create an Item",
					Size = UDim2.fromScale(0.9, 0.7),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					TextScaled = true,
					TextColor3 = isCreate and activeText or unactiveText,
					Interactable = not isCreate,
					BackgroundTransparency = 1,
					[React.Event.Activated] = function()
						setIsCreate(true)
					end,
					BorderSizePixel = 0,
					ZIndex = 3,
				}),
			}),

			ViewTab = e("Frame", {
				Size = UDim2.fromScale(0.5, 1),
				Position = UDim2.fromScale(0.75, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = not isCreate and activeColor or unactiveColor,
				BorderSizePixel = 0,
				ZIndex = 2,
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(0, 20),
				}),
				BgFrame = e("Frame", {
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BorderSizePixel = 0,
					BackgroundColor3 = not isCreate and activeColor or unactiveColor,
					ZIndex = 2,
				}, { UICorner = e("UICorner", {
					CornerRadius = UDim.new(0, 20),
				}) }),

				BottomRight = e("Frame", {
					Size = UDim2.fromScale(0.5, 0.5),
					Position = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(1, 1),
					BorderSizePixel = 0,
					BackgroundColor3 = not isCreate and activeColor or unactiveColor,
				}),
				TopLeft = e("Frame", {
					Size = UDim2.fromScale(0.5, 0.5),
					Position = UDim2.fromScale(0, 0),
					AnchorPoint = Vector2.new(0, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = unactiveColor,
					ZIndex = 1,
				}),
				TabButton = e("TextButton", {
					Size = UDim2.fromScale(0.9, 0.7),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Text = "View Item(s)",
					BackgroundTransparency = 1,
					TextScaled = true,
					TextColor3 = not isCreate and activeText or unactiveText,
					Interactable = isCreate,
					[React.Event.Activated] = function()
						setIsCreate(false)
					end,
					BorderSizePixel = 0,
					ZIndex = 3,
				}),
			}),
		}),
		BottomFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.75),
			Position = UDim2.fromScale(0.5, 0.90),
			AnchorPoint = Vector2.new(0.5, 0.90),
			BackgroundTransparency = 1,
		}, { isCreate and { CreateItemForm = e(CreateItemForm) } or { ViewItems = e(ViewItems) } }),
	})
end

return ItemMenu
