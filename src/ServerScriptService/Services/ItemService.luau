local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SessionPlayerService = require(script.Parent.SessionPlayerService)
local ItemApi = require(ReplicatedStorage.Api.ItemApi)
local Utils = require(ReplicatedStorage.Shared.Utils)

local SessionStore = require(script.Parent.Parent:WaitForChild("Store"):WaitForChild("SessionStore"))
local SessionNotifier = require(script.Parent.SessionNotifier)

local ItemService = {}

local remotes = nil
local isInitialized = false

function ItemService.init(remoteMap: { [string]: RemoteEvent })
	remotes = remoteMap

	if isInitialized then
		return
	end

	isInitialized = true
end

function ItemService.handleListItemsBySessionId(player: Player)
	local sessionId = SessionPlayerService.getPlayerSessionState(player).sessionId
	if not sessionId then
		Utils.fireError(player, "Player is not in a session", remotes)
		return
	end

	local result = ItemApi:GetItemsBySessionId(sessionId)

	if remotes then
		remotes.listItemsSessionId:FireClient(player, result)
	end

	return result
end

function ItemService.handleCreateItem(player: Player, payload: { title: string, description: string })
	local playerState = SessionPlayerService.getPlayerSessionState(player)
	local code = playerState and playerState.sessionCode
	if type(payload.title) ~= "string" or type(payload.description) ~= "string" then
		Utils.fireError(player, "Invalid payload for creating item: " .. tostring(payload), remotes)
		return
	end

	local sessionId = SessionPlayerService.getPlayerSessionState(player).sessionId
	if not sessionId then
		Utils.fireError(player, "Player is not in a session", remotes)
		return
	end

	local createPayload = {
		created_by_roblox_user_id = player.UserId,
		description = payload.description,
		title = payload.title,
		session_id = sessionId,
		status = "pending",
	}
	local result = ItemApi:CreateItem(createPayload)
	SessionStore.update(code, function(meta)
		meta.items = meta.items or {}

		table.insert(meta.items, {
			created_by_roblox_user_id = player.UserId,
			title = payload.title,
			description = payload.description,
			position = #meta.items + 1,
			status = "pending",
			cost = nil,
		})
	end)
	SessionNotifier.broadcastSessionState(code)

	if remotes then
		remotes.createItem:FireClient(player, result)
	end
end

function ItemService.handleDeleteItem(player: Player, payload: { id: string })
	if type(payload.id) ~= "string" then
		Utils.fireError(player, "Invalid payload for deleting item: " .. tostring(payload), remotes)
		return
	end

	local sessionId = SessionPlayerService.getPlayerSessionState(player).sessionId
	if not sessionId then
		Utils.fireError(player, "Player is not in a session", remotes)
		return
	end

	local result = ItemApi:DeleteItem({
		id = payload.id,
		created_by_roblox_user_id = player.UserId,
	})

	if remotes then
		remotes.deleteItem:FireClient(player, result)
	end
end

return ItemService
