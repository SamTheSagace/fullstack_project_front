local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DTO = require(ReplicatedStorage.Types.DTO)
type CreateSessionInput = DTO.CreateSessionInput
type JoinSessionInput = DTO.JoinSessionInput
type LeaveSessionInput = DTO.LeaveSessionInput
type CreatUpdateVoteInput = DTO.CreateUpdateVoteInput

local config = require(ReplicatedStorage.Config.Config)
local URL_API = config.API_URL
local URL_SESSION = URL_API .. "sessions/"

local SessionApi = {}

function SessionApi:GetSessions()
	local serv_id = game.PlaceId
	local success, response = pcall(function()
		return HttpService:GetAsync(`{URL_SESSION}?&owner_server_id={serv_id}`)
	end)
	if not success then
		warn("Failed to get sessions:", response)
		return nil
	end
	return HttpService:JSONDecode(response)
end

function SessionApi:CreateSession(createSessionInput: CreateSessionInput)
	local jsonData = HttpService:JSONEncode(createSessionInput)
	local success, response = pcall(function()
		return HttpService:PostAsync(URL_SESSION, jsonData, Enum.HttpContentType.ApplicationJson)
	end)
	if not success then
		warn("Failed to create session:", response)
		return nil
	end
	return HttpService:JSONDecode(response)
end

function SessionApi:JoinSession(code: string, data: JoinSessionInput)
	local body = HttpService:JSONEncode(data)
	local success, response = pcall(function()
		return HttpService:PostAsync(URL_SESSION .. code .. "/join/", body, Enum.HttpContentType.ApplicationJson)
	end)
	if not success then
		warn("Failed to join session:", response)
		return nil
	end
	return HttpService:JSONDecode(response)
end

function SessionApi:LeaveSession(code: string, data: LeaveSessionInput)
	local body = HttpService:JSONEncode(data)
	local success, response = pcall(function()
		return HttpService:PostAsync(URL_SESSION .. code .. "/leave/", body, Enum.HttpContentType.ApplicationJson)
	end)
	if not success then
		warn("Failed to leave session:", response)
		return nil
	end
	return HttpService:JSONDecode(response)
end

--- Vote API
function SessionApi:CreateUpdateVote(createUpdateVoteInput: CreatUpdateVoteInput)
	local jsonData = HttpService:JSONEncode(createUpdateVoteInput)
	local success, response = pcall(function()
		return HttpService:PostAsync(URL_API .. "votes/create/", jsonData, Enum.HttpContentType.ApplicationJson)
	end)
	if not success then
		warn("Failed to create session:", response)
		return nil
	end
	return HttpService:JSONDecode(response)
end
---

function SessionApi:StartSession(session_id: number)
	local success, response = pcall(function()
		return HttpService:PostAsync(URL_SESSION .. session_id .. "/start/", {}, Enum.HttpContentType.ApplicationJson)
	end)
	if not success then
		warn("Failed to start session:", response)
		return nil
	end
	return HttpService:JSONDecode(response)
end

return SessionApi
