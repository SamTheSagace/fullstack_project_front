local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DTO = require(ReplicatedStorage.Types.DTO)
type CreateItemInput = DTO.CreateItemInput
type DeleteItemInput = DTO.DeleteItemInput

local config = require(ReplicatedStorage.Config.Config)
local URL_API = config.API_URL
local URL_ITEMS = URL_API .. "items/"

local ItemApi = {}

function ItemApi:GetItemsBySessionId(session_id: number)
	local success, response = pcall(function()
		return HttpService:GetAsync(`{URL_ITEMS}session/{session_id}`)
	end)
	if not success then
		warn("Failed to get sessions:", response)
		return nil
	end
	return HttpService:JSONDecode(response)
end

function ItemApi:CreateItem(createItemInput: CreateItemInput)
	local jsonData = HttpService:JSONEncode(createItemInput)
	local success, response = pcall(function()
		return HttpService:PostAsync(URL_ITEMS .. "create/", jsonData, Enum.HttpContentType.ApplicationJson)
	end)
	if not success then
		warn("Failed to create item:", response)
		return nil
	end
	return HttpService:JSONDecode(response)
end

function ItemApi:DeleteItem(deleteItemInput: DeleteItemInput)
	local body = HttpService:JSONEncode(deleteItemInput)
	local success, response = pcall(function()
		return HttpService:PostAsync(
			URL_ITEMS .. "delete/" .. deleteItemInput.id,
			body,
			Enum.HttpContentType.ApplicationJson
		)
	end)
	if not success then
		warn("Failed to delete item:", response)
		return nil
	end
	return HttpService:JSONDecode(response)
end

return ItemApi
