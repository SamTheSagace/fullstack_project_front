local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local SessionCard = require(script.Parent.SessionCard)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type CardProps = {
	value: number,
	selectedValue: number?,
	setSelectedValue: (number?) -> (),
}
local function Card(props: CardProps)
	local TweenService = game:GetService("TweenService")
	local frameRef = React.useRef(nil)
	local flipped, setFlipped = React.useState(false)
	local animating, setAnimating = React.useState(false)

	React.useEffect(function()
		local shouldBeFront = props.selectedValue == props.value
		if props.selectedValue == nil then
			return
		end
		-- if already correct, do nothing
		if shouldBeFront ~= flipped then
			return
		end

		if animating then
			return
		end

		setAnimating(true)

		local frame = frameRef.current
		if not frame then
			return
		end

		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		-- shrink
		local shrink = TweenService:Create(frame, tweenInfo, {
			Size = UDim2.fromScale(0, 1),
		})

		shrink:Play()
		shrink.Completed:Wait()

		-- update visual state (invert)
		setFlipped(not shouldBeFront)

		-- grow
		local grow = TweenService:Create(frame, tweenInfo, {
			Size = UDim2.fromScale(1, 1),
		})

		grow:Play()
		-- grow.Completed:Wait()

		setAnimating(false)
	end, { props.selectedValue })

	return e("Frame", {
		Size = UDim2.fromScale(0.15, 0.4),
		BackgroundTransparency = 1,
	}, {
		Content = e("TextButton", {
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Text = "",
			AutoButtonColor = false,
			ClipsDescendants = true,

			ref = frameRef,

			[React.Event.Activated] = function()
				if animating then
					return
				end

				props.setSelectedValue(props.value)
			end,
		}, {
			Label = e("TextLabel", {
				Text = flipped and "Back" or tostring(props.value),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				TextColor3 = Color3.fromRGB(0, 0, 0),
			}),
		}),
	})
end

return Card
