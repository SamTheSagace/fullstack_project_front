local SessionService = {}

local CODE_LENGTH = 6
local CODE_CHARSET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

local activeSession = nil

local function trim(value: string): string
	return string.gsub(value, "^%s*(.-)%s*$", "%1")
end

local function generateCode(): string
	local chars = table.create(CODE_LENGTH)
	for i = 1, CODE_LENGTH do
		local index = math.random(1, #CODE_CHARSET)
		chars[i] = string.sub(CODE_CHARSET, index, index)
	end
	return table.concat(chars)
end

local function buildSnapshot(session)
	local members = table.create(#session.memberOrder)
	for _, userId in ipairs(session.memberOrder) do
		local member = session.membersByUserId[userId]
		if member then
			table.insert(members, {
				userId = member.userId,
				name = member.name,
				participate = member.participate == true,
				isReady = member.isReady == true,
				isSeated = member.isSeated == true,
			})
		end
	end

	local seatMapCopy = {}
	for key, seatIndex in pairs(session.seatMap) do
		seatMapCopy[key] = seatIndex
	end

	return {
		code = session.code,
		name = session.name,
		phase = session.phase,
		hostUserId = session.hostUserId,
		members = members,
		seatMap = seatMapCopy,
	}
end

function SessionService.createSession(hostPlayer: Player, name: string)
	local cleanName = trim(name or "")
	if cleanName == "" then
		return false, "Session name is required"
	end

	-- Simplest one-room rule: reject creating a second session in this Roblox server.
	if activeSession ~= nil then
		return false, "A session is already active on this server"
	end

	activeSession = {
		code = generateCode(),
		name = cleanName,
		phase = "waiting",
		hostUserId = hostPlayer.UserId,
		membersByUserId = {},
		memberOrder = {},
		seatMap = {}, -- [tostring(userId)] = seatIndex
	}

	local hostMember = {
		userId = hostPlayer.UserId,
		name = hostPlayer.Name,
		participate = true,
		isReady = false,
		isSeated = false,
	}

	activeSession.membersByUserId[hostPlayer.UserId] = hostMember
	table.insert(activeSession.memberOrder, hostPlayer.UserId)

	return true, buildSnapshot(activeSession)
end

function SessionService.joinSession(player: Player, code: string, participate: boolean)
	if activeSession == nil then
		return false, "No active session in this server"
	end

	if activeSession.code ~= code then
		return false, "Session code not found in this server"
	end

	local userId = player.UserId
	local member = activeSession.membersByUserId[userId]

	if member == nil then
		member = {
			userId = userId,
			name = player.Name,
			participate = participate == true,
			isReady = false,
			isSeated = false,
		}
		activeSession.membersByUserId[userId] = member
		table.insert(activeSession.memberOrder, userId)
	else
		member.name = player.Name
		member.participate = participate == true
	end

	if member.participate == false then
		member.isSeated = false
		activeSession.seatMap[tostring(userId)] = nil
	end

	return true, buildSnapshot(activeSession)
end

function SessionService.getSnapshot(code: string)
	if activeSession == nil then
		return nil
	end
	if code ~= nil and activeSession.code ~= code then
		return nil
	end
	return buildSnapshot(activeSession)
end

function SessionService.setSeated(userId: number, seatIndex: number?)
	if activeSession == nil then
		return false, "No active session"
	end

	local member = activeSession.membersByUserId[userId]
	if member == nil then
		return false, "Player is not in active session"
	end

	local key = tostring(userId)
	if seatIndex == nil then
		activeSession.seatMap[key] = nil
		member.isSeated = false
		return true
	end

	if type(seatIndex) ~= "number" then
		return false, "Invalid seat index"
	end

	activeSession.seatMap[key] = seatIndex
	member.isSeated = true
	return true
end

return SessionService
