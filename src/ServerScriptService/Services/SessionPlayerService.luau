local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoomService = require(script.Parent.RoomService)

local DataService = require(ReplicatedStorage.Packages.DataService).server
local SessionPlayerService = {}

function SessionPlayerService.setPlayerSeatedState(player: Player, isSeated: boolean)
	DataService:update(player, "is_seated", function()
		return isSeated
	end)
end

function SessionPlayerService.setPlayerReadyState(player: Player, isReady: boolean)
	DataService:update(player, "is_ready", function()
		return isReady
	end)
end

function SessionPlayerService.setPlayerSessionState(
	player: Player,
	code: string,
	id: number,
	isSeated: boolean,
	currentVote: number | nil
)
	DataService:update(player, "session_code", function()
		return code
	end)
	DataService:update(player, "session_id", function()
		return id
	end)
	SessionPlayerService.setPlayerSeatedState(player, isSeated)
	SessionPlayerService.setPlayerReadyState(player, false)
	DataService:update(player, "current_vote", function()
		return currentVote
	end)
end

function SessionPlayerService.clearPlayerSessionState(player: Player)
	DataService:update(player, "session_code", function()
		return nil
	end)
	DataService:update(player, "session_id", function()
		return nil
	end)
	SessionPlayerService.setPlayerSeatedState(player, false)
	SessionPlayerService.setPlayerReadyState(player, false)
	DataService:update(player, "current_vote", function()
		return nil
	end)
end

function SessionPlayerService.getPlayersInSession(code: string): { Player }
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if DataService:get(player, "session_code") == code then
			table.insert(list, player)
		end
	end
	return list
end

function SessionPlayerService.getPlayersDatasInSession(code: string)
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if DataService:get(player, "session_code") == code then
			local playerData = SessionPlayerService.getPlayerSessionState(player)
			playerData.UserId = player.UserId
			table.insert(list, playerData)
		end
	end
	return list
end

function SessionPlayerService.getPlayerSessionState(player: Player): {
	sessionCode: string?,
	sessionId: number?,
	isSeated: boolean,
	isReady: boolean,
	currentVote: number,
}
	return {
		sessionCode = DataService:get(player, "session_code"),
		sessionId = DataService:get(player, "session_id"),
		isSeated = DataService:get(player, "is_seated") or false,
		isReady = DataService:get(player, "is_ready") or false,
		currentVote = DataService:get(player, "current_vote") or nil,
	}
end

function SessionPlayerService.syncSessionSeatingState(code: string)
	local seatMap = RoomService.getSeatMap(code)
	for _, player in ipairs(SessionPlayerService.getPlayersInSession(code)) do
		local isSeated = seatMap[player.UserId] ~= nil
		SessionPlayerService.setPlayerSeatedState(player, isSeated)
		if not isSeated then
			SessionPlayerService.setPlayerReadyState(player, false)
		end
	end
end

return SessionPlayerService
