local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SessionApi = require(ReplicatedStorage.Api.SessionApi)

local remotes = nil

local function fireError(player: Player, message: string)
	if remotes then
		remotes.sessionError:FireClient(player, { message = message })
	end
end

local VoteService = {}

function VoteService.confirmVote(
	player: Player,
	payload: {
		itemId: number,
		robloxUserId: number,
		value: number,
	}
)
	if type(payload.itemId) ~= "number" then
		fireError(player, "item_id is required")
		return
	end
	if type(payload.robloxUserId) ~= "number" then
		fireError(player, "roblox_user_id is required")
		return
	end
	if type(payload.value) ~= "number" then
		fireError(player, "value is required")
		return
	end

	SessionApi:CreateUpdateVote({
		item_id = payload.itemId,
		roblox_user_id = payload.robloxUserId,
		value = payload.value,
	})
end

return VoteService
