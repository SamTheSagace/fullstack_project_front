local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DTO = require(ReplicatedStorage.Types.DTO)
type CreateSessionInput = DTO.CreateSessionInput

local URL_API = "https://nontestable-emory-punningly.ngrok-free.dev/api/"
local URL_SESSION = URL_API .. "sessions/"

local Api = {}

function Api.GetSessions()
	local success, response = pcall(function()
		return HttpService:GetAsync(URL_SESSION)
	end)
	if not success then
		warn("Failed to get sessions:", response)
		return nil
	end
	return HttpService:JSONDecode(response)
end

function Api.CreateSession(createSessionInput: CreateSessionInput)
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

return Api
