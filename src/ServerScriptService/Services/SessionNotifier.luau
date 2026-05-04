local SessionPlayerService = require(script.Parent.SessionPlayerService)
local RoomService = require(script.Parent.RoomService)
local DataService = require(game.ReplicatedStorage.Packages.DataService).server
local SessionStore = require(script.Parent.Parent.Store.SessionStore)

local SessionNotifier = {}

local isInitialized = false
local remotes = nil

local function getSessionPhase(code: string): string
	local meta = SessionStore.get(code)
	local phase = meta and meta.phase
	if type(phase) == "string" and phase ~= "" then
		return phase
	end

	return "waiting"
end

function SessionNotifier.init(remoteMap)
	remotes = remoteMap

	if isInitialized then
		return
	end

	DataService:init({
		template = {
			session_code = nil,
			is_seated = false,
			is_ready = false,
			current_vote = nil,
		},
	})

	isInitialized = true
end

function SessionNotifier.broadcastSessionState(code: string)
	if not remotes then
		return
	end

	local meta = SessionStore.get(code)

	local members = {}
	local readyCount = 0
	local seatedCount = 0

	for _, player in ipairs(SessionPlayerService.getPlayersInSession(code)) do
		local isReady = DataService:get(player, "is_ready") == true
		local isSeated = DataService:get(player, "is_seated") == true

		if isReady then
			readyCount += 1
		end
		if isSeated then
			seatedCount += 1
		end

		table.insert(members, {
			userId = player.UserId,
			name = player.Name,
			participate = isSeated,
			isReady = isReady,
			isSeated = isSeated,
		})
	end

	local snapshot = {
		session_id = meta and meta.sessionId or nil,
		code = code,
		name = (meta and meta.name) or "Session",
		phase = getSessionPhase(code),
		hostUserId = (meta and meta.hostUserId) or (members[1] and members[1].userId) or 0,
		items = meta and meta.items or {},
		currentItem = meta and meta.currentItem or nil,
		members = members,
		seatMap = RoomService.getSeatMap(code),
		playerCount = #members,
		seatedCount = seatedCount,
		readyCount = readyCount,
	}

	for _, player in ipairs(SessionPlayerService.getPlayersInSession(code)) do
		remotes.sessionState:FireClient(player, snapshot)
	end
end

return SessionNotifier
