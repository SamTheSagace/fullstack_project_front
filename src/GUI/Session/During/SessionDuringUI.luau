local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local React = require(ReplicatedStorage.Packages.React)
local SessionCode = require(StarterGui.GUI.Components.SessionCode)
local e = React.createElement
local CommonTypes = require(ReplicatedStorage.Types.Common)
type SessionSnapshot = CommonTypes.SessionSnapshot

local eventsFolder = ReplicatedStorage:WaitForChild("Events")

type Props = {
	currentSession: SessionSnapshot,
}

local function SessionDuringUI(props: Props)
	local currentSession = props.currentSession

	return e(React.Fragment, nil, {
		SessionCode = e(SessionCode, {
			Text = currentSession.code or "",
		}),

		SessionStartedText = e("TextLabel", {
			Size = UDim2.fromOffset(200, 50),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Text = "Session has started!",
			Font = Enum.Font.Gotham,
			TextSize = 16,
			TextColor3 = Color3.fromRGB(255, 255, 255),
		}),
	})
end

return SessionDuringUI
