local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RoomService = {}

local ROOM_SPACING_STUDS = 600
local ROOM_BASE_CFRAME = CFrame.new(10000, 10000, 10000)
local MODELS_FOLDER = ReplicatedStorage:WaitForChild("Models")

local sessionRoomsByCode = {}
local spawnedRoomCount = 0

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

function RoomService.ensureRoomForSession(sessionCode: string): (Model?, string?)
	local current = sessionRoomsByCode[sessionCode]
	if current and current.Parent then
		return current, nil
	end

	local roomsFolder = getSessionRoomsFolder()
	local existing = roomsFolder:FindFirstChild(`SessionRoom_{sessionCode}`)
	if existing and existing:IsA("Model") then
		sessionRoomsByCode[sessionCode] = existing
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
	return roomOrError, nil
end

function RoomService.teleportPlayerToSessionRoom(player: Player, sessionCode: string): boolean
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

function RoomService.teleportPlayerToSpawn(player: Player): boolean
	local ok, err = pcall(function()
		local character = player.Character
		if not character then
			return
		end
		local root: BasePart = character:FindFirstChild("HumanoidRootPart")
		local humanoid: Humanoid = character:FindFirstChildOfClass("Humanoid")
		if not root then
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
