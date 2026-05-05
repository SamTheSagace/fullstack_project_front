local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SessionPlayerService = require(script.Parent.SessionPlayerService)
local SessionApi = require(ReplicatedStorage.Api.SessionApi)
local Utils = require(ReplicatedStorage.Shared.Utils)

local VoteService = {}

local remotes = nil
local isInitialized = false

function VoteService.init(remoteMap)
	remotes = remoteMap

	if isInitialized then
		return
	end

	isInitialized = true
end

function VoteService.confirmVote(
	player: Player,
	payload: {
		itemId: number,
		robloxUserId: number,
		value: number,
	}
)
	if type(payload.itemId) ~= "number" then
		Utils.fireError(player, "item_id is required", remotes)
		return
	end
	if type(payload.robloxUserId) ~= "number" then
		Utils.fireError(player, "roblox_user_id is required", remotes)
		return
	end
	if type(payload.value) ~= "number" then
		Utils.fireError(player, "value is required", remotes)
		return
	end

	local playerState = SessionPlayerService.getPlayerSessionState(player)

	SessionApi:CreateUpdateVote({
		item_id = payload.itemId,
		roblox_user_id = payload.robloxUserId,
		value = payload.value,
	})
	SessionPlayerService.setPlayerSessionState(
		player,
		playerState.sessionCode,
		playerState.sessionId,
		playerState.isSeated,
		payload.value
	)
end

return VoteService
