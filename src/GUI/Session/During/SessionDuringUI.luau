local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local CustomButton = require(StarterGui.GUI.Components.CustomButton)
local React = require(ReplicatedStorage.Packages.React)
local SessionCode = require(StarterGui.GUI.Components.SessionCode)
local CardMenu = require(StarterGui.GUI.Session.During.CardSelection.CardMenu)
local e = React.createElement
local CommonTypes = require(ReplicatedStorage.Types.Common)
type SessionSnapshot = CommonTypes.SessionSnapshot

local nextItemEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("nextItem")

type Props = {
	currentSession: SessionSnapshot,
}

local function SessionDuringUI(props: Props)
	local currentSession, setCurrentSession = React.useState(props.currentSession)
	local resetCardMenuRef = React.useRef(nil)
	local nextItemEnable, setNextItemEnable = React.useState(false)
	local isOwner = currentSession.hostUserId == game.Players.LocalPlayer.UserId

	local showText, setShowText = React.useState(true)

	local function handleNextItem()
		nextItemEvent:FireServer()
	end

	local function handleFinishVote()
		setNextItemEnable(true)
	end

	React.useEffect(function()
		local thread = task.delay(3, function()
			setShowText(false)
		end)

		return function()
			task.cancel(thread)
		end
	end, {})

	React.useEffect(function()
		local onSessionsReceived = nextItemEvent.OnClientEvent:Connect(function(...)
			setCurrentSession(...)
			if resetCardMenuRef.current then
				resetCardMenuRef.current()
			end
			setNextItemEnable(false)
		end)
		return function()
			onSessionsReceived:Disconnect()
		end
	end, {})

	return e(React.Fragment, nil, {
		SessionCode = e(SessionCode, {
			Text = currentSession.code or "",
		}),

		SessionStartedText = showText and e("TextLabel", {
			Size = UDim2.fromOffset(200, 50),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Text = "Session has started!",
			Font = Enum.Font.Gotham,
			TextSize = 16,
			TextColor3 = Color3.fromRGB(255, 255, 255),
		}) or nil,

		CardMenu = e(CardMenu, {
			isVisible = not showText and not nextItemEnable,
			currentItem = currentSession.currentItem,
			resetCardMenu = function(resetFn)
				resetCardMenuRef.current = resetFn
			end,
		}),

		nextItemButton = isOwner and not showText and nextItemEnable and e(CustomButton, {
			Size = UDim2.fromOffset(100, 50),
			Position = UDim2.fromScale(0.9, 0.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "Next Item",
			BackgroundColor3 = Color3.fromRGB(1, 88, 181),
			ButtonColor = Color3.fromRGB(0, 122, 255),
			onButtonClick = handleNextItem,
		}) or nil,

		finishVoteButton = isOwner and not showText and not nextItemEnable and e(CustomButton, {
			Size = UDim2.fromOffset(100, 50),
			Position = UDim2.fromScale(0.9, 0.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "Finish Vote",
			BackgroundColor3 = Color3.fromRGB(1, 88, 181),
			ButtonColor = Color3.fromRGB(0, 122, 255),
			onButtonClick = handleFinishVote,
		}) or nil,
	})
end

return SessionDuringUI
