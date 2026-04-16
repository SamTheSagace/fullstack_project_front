local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type ItemProps = {
	title: string,
	description: string,
	cost: number?,
	LayoutOrder: number,
	length: number,
	userId: number,
}

local function ItemCard(props: ItemProps)
	local user = 2
	local isUser = user == props.userId
	local textCost = "Cost : " .. tostring(props.cost)
	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder,
		BackgroundTransparency = 1,
	}, {
		MainFrame = e("Frame", {
			Size = UDim2.fromScale(1, 0.95),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(224, 209, 160),
		}, {
			{
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}),
				Border = e("UIStroke", {
					Thickness = 2,
					Color = Color3.fromRGB(20, 78, 70),
					Enabled = true,
					ApplyStrokeMode = "Border",
				}),
				Content = e("Frame", {
					Size = UDim2.fromScale(0.9, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 10),
					}),

					TitleFrame = e("Frame", {
						Size = UDim2.fromScale(1, 0.25),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0),
						BackgroundTransparency = 1,
					}, {
						TitleBorder = e("Frame", {
							Size = UDim2.fromScale(1, 0.8),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(121, 94, 36),
						}, {
							Corner = e("UICorner", {
								CornerRadius = UDim.new(0, 05),
							}),
							Text = e("TextLabel", {
								Text = props.title,
								Size = UDim2.fromScale(0.9, 1),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								BackgroundTransparency = 1,
								Font = Enum.Font.GothamBold,
								TextSize = 20,
								TextColor3 = Color3.fromRGB(255, 255, 255),
								TextWrapped = true,
							}),
						}),
					}),

					ContentFrame = e("Frame", {
						Size = UDim2.fromScale(1, 0.75),
						AnchorPoint = Vector2.new(0.5, 1),
						Position = UDim2.fromScale(0.5, 1),
						BackgroundTransparency = 1,
					}, {
						DescriptionFrame = e("Frame", {
							Size = UDim2.fromScale(1, 0.75),
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.fromScale(0.5, 0),
							BackgroundTransparency = 1,
						}, {
							Text = e("TextLabel", {
								Text = props.description,
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								Font = Enum.Font.GothamMedium,
								TextSize = 18,
								TextColor3 = Color3.fromRGB(0, 0, 0),
								TextWrapped = true,
							}),
						}),
						Ligne = e("Frame", {
							Size = UDim2.fromScale(1, 0.01),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.78),
							BackgroundColor3 = Color3.fromRGB(121, 94, 36),
							BorderSizePixel = 0,
						}),
						CostFrame = e("Frame", {
							Size = UDim2.fromScale(1, 0.25),
							AnchorPoint = Vector2.new(0.5, 1),
							Position = UDim2.fromScale(0.5, 1),
							BackgroundTransparency = 1,
						}, {
							Text = e("TextLabel", {
								Text = props.cost and textCost or "Cost : not choosen yet",
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								Font = Enum.Font.GothamBold,
								TextSize = 16,
								TextColor3 = Color3.fromRGB(0, 0, 0),
							}),
						}),
					}),
				}),
			},
		}),
	})
end

return ItemCard
