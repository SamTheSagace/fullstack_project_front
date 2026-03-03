local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local SessionCard = require(script.Parent.SessionCard)
local Card = require(StarterGui.GUI.Components.Card)
local React = require(ReplicatedStorage.Packages.React)
local SessionHelpers = require(ReplicatedStorage.Shared.SessionHelpers)
local Utils = require(ReplicatedStorage.Shared.Utils)

local e = React.createElement
local listSessionsEvent = ReplicatedStorage:WaitForChild("listSessions")
local createSessionEvent = ReplicatedStorage:WaitForChild("createSession")

type props = {
	isVisible: boolean,
}

local function SessionMenu(props: props)
	local sessionName, setSessionName = React.useState("")
	local sessions, setSessions = React.useState({})

	React.useEffect(function()
		print(props.isVisible)
		if props.isVisible then
			listSessionsEvent:FireServer()
		end
		local onSessionsReceived = listSessionsEvent.OnClientEvent:Connect(function(data)
			setSessions(SessionHelpers.extractSessionsFromArgs(data))
		end)
		return function()
			onSessionsReceived:Disconnect()
		end
	end, { props.isVisible })

	local sessionCards = {
		Layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
		}),
	}

	local hasSessions = false
	for index, sessionData in ipairs(sessions) do
		hasSessions = true

		sessionCards[`Session_{index}`] = e(SessionCard, {
			sessionData = sessionData,
			index = index,
		})
	end

	if not hasSessions then
		sessionCards.EmptyState = e("TextLabel", {
			LayoutOrder = 1,
			Size = UDim2.new(1, -10, 0, 80),
			BackgroundTransparency = 1,
			Text = "No sessions available",
			Font = Enum.Font.Gotham,
			TextSize = 16,
			TextColor3 = Color3.fromRGB(161, 179, 196),
		})
	end

	local function createSession()
		local cleanedName = Utils.trim(sessionName)
		if cleanedName == "" then
			return
		end
		createSessionEvent:FireServer(cleanedName)
		setSessionName("")
		listSessionsEvent:FireServer()
	end

	return e(Card, {
		Size = UDim2.fromScale(0.8, 0.72),
		Position = UDim2.fromScale(0.5, 0.45),
		BackgroundColor3 = Color3.fromRGB(8, 18, 31),
		BorderColor = Color3.fromRGB(35, 64, 92),
		isVisible = props.isVisible,
		BorderRadius = UDim.new(0, 15),
		Children = {
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
					BackgroundColor3 = Color3.fromRGB(13, 29, 48),
				}, {
					Corner = e("UICorner", {
						CornerRadius = UDim.new(0, 12),
					}),
					Stroke = e("UIStroke", {
						Color = Color3.fromRGB(44, 73, 103),
						Thickness = 1.5,
					}),
					Header = e("TextLabel", {
						Text = "Create Session",
						Position = UDim2.fromOffset(14, 12),
						Size = UDim2.new(1, -28, 0, 28),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						TextSize = 22,
						TextColor3 = Color3.fromRGB(230, 237, 242),
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
						TextColor3 = Color3.fromRGB(167, 184, 202),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
					NameInput = e("TextBox", {
						Position = UDim2.fromOffset(14, 94),
						Size = UDim2.new(1, -28, 0, 42),
						PlaceholderText = "Session name",
						Text = sessionName,
						ClearTextOnFocus = false,
						Font = Enum.Font.Gotham,
						TextSize = 16,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Color3.fromRGB(237, 243, 247),
						BackgroundColor3 = Color3.fromRGB(20, 39, 62),
						PlaceholderColor3 = Color3.fromRGB(122, 147, 175),
						[React.Change.Text] = function(textBox)
							setSessionName(textBox.Text)
						end,
						[React.Event.FocusLost] = function(_, enterPressed)
							if enterPressed then
								createSession()
							end
						end,
					}, {
						Corner = e("UICorner", {
							CornerRadius = UDim.new(0, 8),
						}),
						Stroke = e("UIStroke", {
							Color = Color3.fromRGB(54, 86, 117),
							Thickness = 1,
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
						BackgroundColor3 = Color3.fromRGB(20, 114, 255),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Font = Enum.Font.GothamBold,
						TextSize = 16,
						AutoButtonColor = Utils.trim(sessionName) ~= "",
						[React.Event.Activated] = createSession,
					}, {
						Corner = e("UICorner", {
							CornerRadius = UDim.new(0, 8),
						}),
					}),
				}),
				RightPanel = e("Frame", {
					Position = UDim2.fromScale(0.39, 0),
					Size = UDim2.fromScale(0.61, 1),
					BackgroundColor3 = Color3.fromRGB(13, 29, 48),
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
						TextColor3 = Color3.fromRGB(230, 237, 242),
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
					SessionList = e("ScrollingFrame", {
						Position = UDim2.fromOffset(14, 48),
						Size = UDim2.new(1, -28, 1, -62),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						CanvasSize = UDim2.fromScale(0, 0),
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						ScrollBarImageColor3 = Color3.fromRGB(88, 124, 159),
						ScrollBarThickness = 6,
					}, sessionCards),
				}),
			}),
		},
	})
end

return SessionMenu
