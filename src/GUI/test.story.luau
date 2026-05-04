local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local HubUI = require(StarterGui.GUI.HUB.HubUI)
local SessionEntry = require(StarterGui.GUI.HUB.Menu.SessionEntry)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local UiValues = require(ReplicatedStorage.Types.UiValues)
local e = React.createElement

local function TestUI()
	return e(React.Fragment, nil, {
		HubUI = e("Frame", {
			Size = UDim2.fromScale(0.8, 0.72),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = UiValues.unactiveColor,
			Visible = true,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
			Border = e("UIStroke", {
				Color = UiValues.MainGreenColor,
			}),
			Title = e("TextLabel", {
				Text = "Session Menu",
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 30,
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}),
			Content = e("Frame", {
				Position = UDim2.fromOffset(18, 56),
				Size = UDim2.new(1, -36, 1, -74),
				BackgroundTransparency = 1,
			}, {
				LeftPanel = e("Frame", {
					Size = UDim2.fromScale(0.36, 1),
					BackgroundColor3 = UiValues.activeColor,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 12),
					}),
					Stroke = e("UIStroke", {
						Color = UiValues.MainGreenColor,
						Thickness = 1.5,
					}),
					Header = e("TextLabel", {
						Text = "Create Session",
						Position = UDim2.fromOffset(14, 12),
						Size = UDim2.new(1, -28, 0, 28),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						TextSize = 22,
						TextColor3 = UiValues.activeText,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
					Description = e("TextLabel", {
						Text = "Choose a name then create a new lobby.",
						Position = UDim2.fromOffset(14, 42),
						Size = UDim2.new(1, -28, 0, 36),
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						TextWrapped = true,
						TextSize = 14,
						TextColor3 = UiValues.activeText,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
					NameInput = e("TextBox", {
						Position = UDim2.fromOffset(14, 94),
						Size = UDim2.new(1, -28, 0, 42),
						PlaceholderText = "Session name",
						Text = "sessionName",
						ClearTextOnFocus = false,
						Font = Enum.Font.Gotham,
						TextSize = 16,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundColor3 = UiValues.unactiveColor,
						PlaceholderColor3 = UiValues.PlaceHolderTextColor,
						BackgroundTransparency = 0.5,
					}, {
						Corner = e("UICorner", {
							CornerRadius = UDim.new(0, 8),
						}),
						Padding = e("UIPadding", {
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10),
						}),
					}),
					CreateButton = e("TextButton", {
						Text = "Create Session",
						Position = UDim2.fromOffset(14, 150),
						Size = UDim2.new(1, -28, 0, 42),
						BackgroundColor3 = UiValues.YesButtonMain,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Font = Enum.Font.GothamBold,
						TextSize = 16,
					}, {
						Corner = e("UICorner", {
							CornerRadius = UDim.new(0, 8),
						}),
					}),
				}),
				RightPanel = e("Frame", {
					Position = UDim2.fromScale(0.39, 0),
					Size = UDim2.fromScale(0.61, 1),
					BackgroundColor3 = UiValues.activeColor,
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 12),
					}),
					Stroke = e("UIStroke", {
						Color = Color3.fromRGB(44, 73, 103),
						Thickness = 1.5,
					}),
					Header = e("TextLabel", {
						Text = "Available Sessions",
						Position = UDim2.fromOffset(14, 12),
						Size = UDim2.new(1, -28, 0, 28),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						TextSize = 22,
						TextColor3 = UiValues.activeText,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
					SessionList = e(
						"ScrollingFrame",
						{
							Position = UDim2.fromOffset(14, 48),
							Size = UDim2.new(1, -28, 1, -62),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							CanvasSize = UDim2.fromScale(0, 0),
							AutomaticCanvasSize = Enum.AutomaticSize.Y,
							ScrollBarImageColor3 = Color3.fromRGB(88, 124, 159),
							ScrollBarThickness = 6,
						},
						e(SessionEntry, {
							sessionData = {
								id = 1,
								code = "fee",
								name = "hello",
								status = "waiting",
								session_members = {
									{ id = -2, roblox_user_id = -3, display_name = "test" },
								},
							},
							index = 1,
						})
					),
				}),
			}),
		}),
	})
end

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = React.createElement(TestUI)
	root:render(app)

	return function()
		root:unmount()
	end
end
