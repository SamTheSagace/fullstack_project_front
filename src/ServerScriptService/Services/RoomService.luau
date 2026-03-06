local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local RoomService = {}

local ACTIVE_ROOM_NAME = "ActiveMeetingRoom"

local cachedRoomModel = nil
local cachedSeats = {}
local assignedSeatByUserId = {} -- [userId] = seatIndex
local assignedUserBySeatIndex = {} -- [seatIndex] = userId

local function collectSeats(roomModel: Model): { Seat }
	local seatsFolder = roomModel:FindFirstChild("Seats")
	if seatsFolder == nil then
		return {}
	end

	local seats = {}
	for _, child in ipairs(seatsFolder:GetChildren()) do
		if child:IsA("Seat") or child:IsA("VehicleSeat") then
			table.insert(seats, child)
		end
	end

	table.sort(seats, function(a, b)
		return a.Name < b.Name
	end)

	return seats
end

function RoomService.ensureRoomSpawned()
	local existing = Workspace:FindFirstChild(ACTIVE_ROOM_NAME)
	if existing and existing:IsA("Model") then
		cachedRoomModel = existing
	else
		local ok, result = pcall(function()
			local roomAssets = ServerStorage:WaitForChild("RoomAssets")
			local roomTemplate = roomAssets:WaitForChild("MeetingRoom")
			local clonedRoom = roomTemplate:Clone()
			clonedRoom.Name = ACTIVE_ROOM_NAME
			clonedRoom.Parent = Workspace
			return clonedRoom
		end)

		if not ok then
			warn("[RoomService] Failed to spawn meeting room:", result)
			return nil, {}
		end

		cachedRoomModel = result
	end

	cachedSeats = collectSeats(cachedRoomModel)
	return cachedRoomModel, cachedSeats
end

function RoomService.assignSeat(player: Player): number?
	if assignedSeatByUserId[player.UserId] then
		return assignedSeatByUserId[player.UserId]
	end

	local roomModel, seats = RoomService.ensureRoomSpawned()
	if roomModel == nil or #seats == 0 then
		return nil
	end

	local seatIndex = nil
	for index, _seat in ipairs(seats) do
		if assignedUserBySeatIndex[index] == nil then
			seatIndex = index
			break
		end
	end

	if seatIndex == nil then
		return nil
	end

	local seat = seats[seatIndex]
	local ok, seatErr = pcall(function()
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid == nil then
			error("Humanoid missing for seating")
		end

		character:PivotTo(seat.CFrame + Vector3.new(0, 3, 0))
		task.wait()
		seat:Sit(humanoid)
		humanoid.Sit = true
	end)

	if not ok then
		warn("[RoomService] Failed to seat player:", player.UserId, seatErr)
		return nil
	end

	assignedSeatByUserId[player.UserId] = seatIndex
	assignedUserBySeatIndex[seatIndex] = player.UserId
	return seatIndex
end

return RoomService
