local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RoomService = {}

local ROOM_SPACING_STUDS = 600
local ROOM_BASE_CFRAME = CFrame.new(10000, 10000, 10000)
local MODELS_FOLDER = ReplicatedStorage:WaitForChild("Models")
local GENERATED_SEAT_NAME = "_GeneratedChairSeat"
local GENERATED_SEAT_SIZE = Vector3.new(2, 1, 2)
local GENERATED_SEAT_OFFSET_FACTOR = -0.12
local GENERATED_SEAT_MIN_HEIGHT_OFFSET = 1.2

local sessionRoomsByCode = {}
local sessionSeatStateByCode = {}
local lockedSeatByUserId = {}
local spawnedRoomCount = 0
local seatStateChangedHandler = nil

type SeatInfo = {
	chair: Instance,
	chairName: string,
	isOwnerSeat: boolean,
	seat: Seat,
}

type SessionSeatState = {
	roomModel: Model,
	seatInfosBySeat: { [Seat]: SeatInfo },
	seatConnections: { RBXScriptConnection },
	ownerSeat: Seat?,
	ownerUserId: number?,
}

local function getSessionRoomsFolder(): Folder
	local folder = Workspace:FindFirstChild("SessionRooms")
	if folder and folder:IsA("Folder") then
		return folder
	end

	local created = Instance.new("Folder")
	created.Name = "SessionRooms"
	created.Parent = Workspace
	return created
end

--**
--* Retrieves the meeting room template model from ReplicatedStorage. Returns nil if not found or if the found object is not a Model.
--* @return Model? The meeting room template model, or nil if not found/invalid
local function getMeetingRoomTemplate(): Model?
	local template = MODELS_FOLDER:FindFirstChild("Meeting_Room")
	if template and template:IsA("Model") then
		return template
	end
	return nil
end

local function getRoomTeleportCFrame(roomModel: Model): CFrame
	local anchor = roomModel:FindFirstChild("Door")
	if anchor == nil then
		anchor = roomModel:FindFirstChild("Floor", true)
	end
	if anchor == nil then
		anchor = roomModel:FindFirstChildWhichIsA("BasePart", true)
	end

	if anchor and anchor.Name == "Door" then
		anchor = anchor:FindFirstChildWhichIsA("BasePart")
		return CFrame.new(anchor.CFrame.Position + Vector3.new(0, 2, -5))
	end

	return roomModel:GetPivot() * CFrame.new(0, 6, 0)
end

local function getSpawnCFrame(): CFrame
	local spawnLocation = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawnLocation then
		return spawnLocation.CFrame + Vector3.new(0, 5, 0)
	end

	return CFrame.new(0, 10, 0)
end

local function normalizeName(value: string?): string
	if type(value) ~= "string" then
		return ""
	end

	return string.lower((value:gsub("%s+", "")))
end

local function findChairsContainer(roomModel: Model): Instance?
	local exactMatch = roomModel:FindFirstChild("Chairs", true)
	if exactMatch then
		return exactMatch
	end

	for _, descendant in ipairs(roomModel:GetDescendants()) do
		if normalizeName(descendant.Name) == "chairs" then
			return descendant
		end
	end

	return nil
end

local function isChairLikeName(name: string): boolean
	return string.find(normalizeName(name), "chair", 1, true) ~= nil
end

local function isOwnerChairName(name: string): boolean
	return string.find(normalizeName(name), "owner", 1, true) ~= nil
end

local function disconnectAll(connections: { RBXScriptConnection })
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	table.clear(connections)
end

local function notifySeatStateChanged(sessionCode: string)
	if seatStateChangedHandler ~= nil then
		seatStateChangedHandler(sessionCode)
	end
end

local function getChairBoundingBox(chair: Instance): (CFrame, Vector3)
	if chair:IsA("Model") then
		return chair:GetBoundingBox()
	end

	local part = chair :: BasePart
	return part.CFrame, part.Size
end

local function findSeatOnChair(chair: Instance): Seat?
	if chair:IsA("Seat") then
		return chair
	end

	local nestedSeat = chair:FindFirstChildWhichIsA("Seat", true)
	if nestedSeat then
		return nestedSeat
	end

	return nil
end

local function findChairCandidates(roomModel: Model): { Instance }
	local chairsContainer = findChairsContainer(roomModel)
	local searchRoot = chairsContainer or roomModel
	local dedupe = {}
	local chairs = {}

	for _, descendant in ipairs(searchRoot:GetDescendants()) do
		local current = descendant
		local candidate = nil

		while current and current ~= searchRoot do
			if (current:IsA("Model") or current:IsA("BasePart")) and isChairLikeName(current.Name) then
				candidate = current
			end
			current = current.Parent
		end

		if candidate and not dedupe[candidate] then
			dedupe[candidate] = true
			table.insert(chairs, candidate)
		end
	end

	table.sort(chairs, function(left, right)
		local leftIsOwner = isOwnerChairName(left.Name)
		local rightIsOwner = isOwnerChairName(right.Name)
		if leftIsOwner ~= rightIsOwner then
			return leftIsOwner
		end

		return left:GetFullName() < right:GetFullName()
	end)

	return chairs
end

local function createGeneratedSeat(chair: Instance, roomModel: Model): Seat
	local seat = Instance.new("Seat")
	local chairCFrame, chairSize = getChairBoundingBox(chair)
	local localYOffset = math.max(chairSize.Y * GENERATED_SEAT_OFFSET_FACTOR, -GENERATED_SEAT_MIN_HEIGHT_OFFSET)

	seat.Name = GENERATED_SEAT_NAME
	seat.Transparency = 1
	seat.CanCollide = true
	seat.CanQuery = false
	seat.Size = GENERATED_SEAT_SIZE
	seat.Anchored = true
	seat.TopSurface = Enum.SurfaceType.Smooth
	seat.BottomSurface = Enum.SurfaceType.Smooth
	seat.CFrame = chairCFrame * CFrame.new(0, localYOffset, 0)
	seat.Parent = roomModel

	return seat
end

local function getOrCreateSessionSeatState(sessionCode: string, roomModel: Model): SessionSeatState
	local existing = sessionSeatStateByCode[sessionCode]
	if existing and existing.roomModel == roomModel and roomModel.Parent then
		return existing
	end

	if existing then
		disconnectAll(existing.seatConnections)
	end

	local state: SessionSeatState = {
		roomModel = roomModel,
		seatInfosBySeat = {},
		seatConnections = {},
		ownerSeat = nil,
		ownerUserId = existing and existing.ownerUserId or nil,
	}

	for _, chair in ipairs(findChairCandidates(roomModel)) do
		local seat = findSeatOnChair(chair) or createGeneratedSeat(chair, roomModel)
		local seatInfo: SeatInfo = {
			chair = chair,
			chairName = chair.Name,
			isOwnerSeat = isOwnerChairName(chair.Name),
			seat = seat,
		}

		state.seatInfosBySeat[seat] = seatInfo
		if seatInfo.isOwnerSeat and state.ownerSeat == nil then
			state.ownerSeat = seat
		end

		table.insert(state.seatConnections, seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			local occupant = seat.Occupant
			local occupantCharacter = occupant and occupant.Parent
			local occupantPlayer = occupantCharacter and Players:GetPlayerFromCharacter(occupantCharacter)

			if seatInfo.isOwnerSeat and state.ownerUserId ~= nil and occupantPlayer and occupantPlayer.UserId ~= state.ownerUserId then
				task.defer(function()
					if occupant and occupant.Parent then
						occupant.Sit = false
					end
				end)
				return
			end

			notifySeatStateChanged(sessionCode)
		end))
	end

	if state.ownerSeat == nil then
		for seat in pairs(state.seatInfosBySeat) do
			state.ownerSeat = seat
			break
		end
	end

	sessionSeatStateByCode[sessionCode] = state
	return state
end

local function ensurePlayerCharacter(player: Player): (Model?, Humanoid?, BasePart?)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
	local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)

	if humanoid == nil or root == nil then
		return nil, nil, nil
	end

	return character, humanoid, root
end

local function seatHumanoid(player: Player, seat: Seat): boolean
	local _, humanoid, root = ensurePlayerCharacter(player)
	if humanoid == nil or root == nil then
		return false
	end

	root.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
	for _ = 1, 5 do
		seat:Sit(humanoid)
		task.wait(0.1)
		if humanoid.SeatPart == seat then
			return true
		end
	end

	return false
end

local function getLockedSeatState(player: Player)
	return lockedSeatByUserId[player.UserId]
end

local function ensureLockedPlayerSeated(player: Player)
	local lockedSeatState = getLockedSeatState(player)
	if lockedSeatState == nil or lockedSeatState.isReseating then
		return
	end

	local seat = lockedSeatState.seat
	if seat == nil or seat.Parent == nil then
		return
	end

	lockedSeatState.isReseating = true
	task.defer(function()
		lockedSeatState.isReseating = false

		local _, humanoid = ensurePlayerCharacter(player)
		if humanoid == nil then
			return
		end

		if humanoid.SeatPart == seat then
			return
		end

		seatHumanoid(player, seat)
	end)
end

local function setJumpingEnabled(player: Player, isEnabled: boolean)
	local character = player.Character
	if character == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, isEnabled)
	end
end

local function attachSeatLockToCurrentCharacter(player: Player, ownerSeat: Seat, lockState)
	local character = player.Character
	local humanoid = character and (character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5))
	if humanoid == nil then
		return
	end

	setJumpingEnabled(player, false)
	table.insert(lockState.connections, humanoid.Seated:Connect(function(isSeated, currentSeat)
		if not isSeated or currentSeat ~= ownerSeat then
			ensureLockedPlayerSeated(player)
		end
	end))
end

function RoomService.ensureRoomForSession(sessionCode: string): (Model?, string?)
	local current = sessionRoomsByCode[sessionCode]
	if current and current.Parent then
		getOrCreateSessionSeatState(sessionCode, current)
		return current, nil
	end

	local roomsFolder = getSessionRoomsFolder()
	local existing = roomsFolder:FindFirstChild(`SessionRoom_{sessionCode}`)
	if existing and existing:IsA("Model") then
		sessionRoomsByCode[sessionCode] = existing
		getOrCreateSessionSeatState(sessionCode, existing)
		return existing, nil
	end

	local template = getMeetingRoomTemplate()
	if template == nil then
		return nil, "Meeting_Room model is missing in ReplicatedStorage.Models"
	end

	local ok, roomOrError = pcall(function()
		local roomModel = template:Clone()
		roomModel.Name = `SessionRoom_{sessionCode}`
		roomModel.Parent = roomsFolder
		return roomModel
	end)

	if not ok then
		return nil, `Failed to clone room model: {roomOrError}`
	end

	spawnedRoomCount = math.max(spawnedRoomCount, #roomsFolder:GetChildren())
	local targetCFrame = ROOM_BASE_CFRAME + Vector3.new((spawnedRoomCount - 1) * ROOM_SPACING_STUDS, 0, 0)
	local positionedOk, positionedErr = pcall(function()
		roomOrError:PivotTo(targetCFrame)
	end)
	if not positionedOk then
		warn("[RoomService] Failed to position session room:", positionedErr)
	end

	sessionRoomsByCode[sessionCode] = roomOrError
	getOrCreateSessionSeatState(sessionCode, roomOrError)
	return roomOrError, nil
end

function RoomService.teleportPlayerToSessionRoom(player: Player, sessionCode: string, isOwner: boolean): boolean
	local roomModel, roomError = RoomService.ensureRoomForSession(sessionCode)
	if roomModel == nil then
		warn("[RoomService] Could not load session room:", roomError)
		return false
	end

	local ok, err = pcall(function()
		local character = player.Character or player.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart", 5)
		if not root then
			error("HumanoidRootPart not found")
		end
		root.CFrame = getRoomTeleportCFrame(roomModel)
	end)
	if not ok then
		warn("[RoomService] Teleport to session room failed:", err)
		return false
	end

	return true
end

function RoomService.setSeatStateChangedHandler(handler)
	seatStateChangedHandler = handler
end

function RoomService.getSeatMap(sessionCode: string)
	local state = sessionSeatStateByCode[sessionCode]
	if state == nil then
		return {}
	end

	local seatMap = {}
	for seat, seatInfo in pairs(state.seatInfosBySeat) do
		local occupant = seat.Occupant
		local occupantCharacter = occupant and occupant.Parent
		local occupantPlayer = occupantCharacter and Players:GetPlayerFromCharacter(occupantCharacter)

		if occupantPlayer then
			seatMap[occupantPlayer.UserId] = seatInfo.chairName
		end
	end

	return seatMap
end

function RoomService.isPlayerSeatedInSessionRoom(player: Player, sessionCode: string): boolean
	local state = sessionSeatStateByCode[sessionCode]
	if state == nil then
		return false
	end

	local character = player.Character
	if character == nil then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local seatPart = humanoid and humanoid.SeatPart

	return seatPart ~= nil and state.seatInfosBySeat[seatPart] ~= nil
end

function RoomService.seatPlayerInOwnerChair(player: Player, sessionCode: string): (boolean, string?)
	local roomModel, roomError = RoomService.ensureRoomForSession(sessionCode)
	if roomModel == nil then
		return false, roomError
	end

	local state = getOrCreateSessionSeatState(sessionCode, roomModel)
	local ownerSeat = state.ownerSeat
	if ownerSeat == nil then
		return false, "No chair seat was found in the meeting room"
	end

	state.ownerUserId = player.UserId
	local lockState = lockedSeatByUserId[player.UserId]
	if lockState then
		disconnectAll(lockState.connections)
	end

	lockState = {
		seat = ownerSeat,
		connections = {},
		isReseating = false,
	}
	lockedSeatByUserId[player.UserId] = lockState

	table.insert(lockState.connections, player.CharacterAdded:Connect(function()
		task.defer(function()
			attachSeatLockToCurrentCharacter(player, ownerSeat, lockState)
			setJumpingEnabled(player, false)
			ensureLockedPlayerSeated(player)
		end)
	end))

	attachSeatLockToCurrentCharacter(player, ownerSeat, lockState)
	setJumpingEnabled(player, false)
	local seated = seatHumanoid(player, ownerSeat)
	notifySeatStateChanged(sessionCode)

	if not seated then
		return false, "Could not seat the owner in the meeting room"
	end

	return true, nil
end

function RoomService.releasePlayerSeatLock(player: Player)
	local lockState = lockedSeatByUserId[player.UserId]
	if lockState == nil then
		setJumpingEnabled(player, true)
		return
	end

	disconnectAll(lockState.connections)
	lockedSeatByUserId[player.UserId] = nil
	setJumpingEnabled(player, true)
end

function RoomService.teleportPlayerToSpawn(player: Player): boolean
	local ok, err = pcall(function()
		RoomService.releasePlayerSeatLock(player)
		local character = player.Character
		if not character then
			return
		end
		local root: BasePart = character:FindFirstChild("HumanoidRootPart")
		local humanoid: Humanoid = character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then
			return
		end
		humanoid.Sit = false
		task.wait(0.1)
		root.CFrame = getSpawnCFrame()
	end)
	if not ok then
		warn("[RoomService] Teleport to spawn failed:", err)
		return false
	end

	return true
end

function RoomService.destroyRoomForSession(sessionCode: string)
	local seatState = sessionSeatStateByCode[sessionCode]
	if seatState then
		disconnectAll(seatState.seatConnections)
		sessionSeatStateByCode[sessionCode] = nil
	end

	local room = sessionRoomsByCode[sessionCode]
	if room and room.Parent then
		local ok, err = pcall(function()
			room:Destroy()
		end)
		if not ok then
			warn("[RoomService] Failed to destroy session room:", err)
		end
	end

	sessionRoomsByCode[sessionCode] = nil
end

return RoomService
