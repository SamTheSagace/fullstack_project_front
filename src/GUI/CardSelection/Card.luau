local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type CardProps = {
	value: number,
	selectedValue: number?,
	setSelectedValue: (number?) -> (),
	LayoutOrder: number,
	isFinished: boolean,
}

local function Card(props: CardProps)
	local TweenService = game:GetService("TweenService")

	local frameRef = React.useRef(nil)

	local flipped, setFlipped = React.useState(false)
	local animating, setAnimating = React.useState(false)

	local isSelected = props.selectedValue == props.value

	-- 🔧 Helper to play tween without blocking others
	local function playTween(frame, tweenInfo, goal)
		local tween = TweenService:Create(frame, tweenInfo, goal)
		tween:Play()
		return tween
	end

	--  Move card up/down when selected changes
	React.useEffect(function()
		local frame = frameRef.current
		if not frame then
			return
		end

		local goalPosition = isSelected and UDim2.fromScale(0.5, 0.3) -- UP
			or UDim2.fromScale(0.5, 0.5) -- DOWN

		local tween = TweenService:Create(
			frame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = goalPosition }
		)

		tween:Play()
	end, { props.selectedValue })

	--  Flip animation triggered by isFinished
	React.useEffect(function()
		if not props.isFinished then
			if flipped then
				setFlipped(false)
			end
			return
		end

		-- Skip selected card
		if props.selectedValue == props.value then
			return
		end

		if animating then
			return
		end

		local frame = frameRef.current
		if not frame then
			return
		end

		setAnimating(true)

		local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		task.spawn(function()
			playTween(frame, tweenInfo, { Size = UDim2.fromScale(0.2, 1) })
			task.wait(0.12)

			setFlipped(true)

			playTween(frame, tweenInfo, { Size = UDim2.fromScale(0, 1) })
			task.wait(0.12)

			playTween(frame, tweenInfo, { Size = UDim2.fromScale(0.3, 1) })
			task.wait(0.12)

			playTween(frame, tweenInfo, { Size = UDim2.fromScale(1, 1) })
			task.wait(0.12)

			setAnimating(false)
		end)
	end, { props.isFinished })

	React.useEffect(function()
		if props.isFinished then
			if isSelected then
				setFlipped(false) -- show front
			end
			if not isSelected then
				setFlipped(true) -- show front
			end
		end
	end, { props.selectedValue })

	return e("Frame", {
		Size = UDim2.fromScale(0.08, 0.4),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
	}, {
		Content = e("TextButton", {
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(127, 174, 218),
			Text = "",
			AutoButtonColor = false,
			ClipsDescendants = true,
			ref = frameRef,
			[React.Event.Activated] = function()
				if animating then
					return
				end
				if props.isFinished then
					return
				end
				if isSelected then
					props.setSelectedValue(nil)
				else
					props.setSelectedValue(props.value)
				end
			end,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 2),
			}),
			Border = e("UIStroke", {
				Thickness = 2,
				Color = Color3.fromRGB(20, 78, 70),
				Enabled = true,
				ApplyStrokeMode = "Border",
			}),
			Label = e("TextLabel", {
				Text = flipped and "Back" or tostring(props.value),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				TextSize = 20,
				TextColor3 = Color3.fromRGB(20, 78, 70),
			}),
		}),
	})
end

return Card
