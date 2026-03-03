local SessionHelpers = {}

SessionHelpers.SESSION_NAME_KEYS = { "name", "session_name", "sessionName", "title" }
SessionHelpers.PLAYER_LIST_KEYS = { "players", "members", "participants", "users" }
SessionHelpers.PLAYER_ID_KEYS = { "roblox_user_id", "robloxUserId", "user_id", "userId", "id", "player_id" }

function SessionHelpers.getSessionPlayerIds(sessionData: any): { [number]: number }
	if type(sessionData) ~= "table" then
		return {}
	end

	local playersList = nil
	for _, key in ipairs(SessionHelpers.PLAYER_LIST_KEYS) do
		if type(sessionData[key]) == "table" then
			playersList = sessionData[key]
			break
		end
	end

	if type(playersList) ~= "table" then
		return {}
	end

	local ids = {}
	local dedupe = {}
	for _, playerData in pairs(playersList) do
		local userId = SessionHelpers.parseUserId(playerData)
		if userId and not dedupe[userId] then
			dedupe[userId] = true
			table.insert(ids, userId)
		end
	end

	return ids
end

function SessionHelpers.getSessionName(sessionData: any, index: number): string
	if type(sessionData) ~= "table" then
		return `Session {index}`
	end

	for _, key in ipairs(SessionHelpers.SESSION_NAME_KEYS) do
		if type(sessionData[key]) == "string" and sessionData[key] ~= "" then
			return sessionData[key]
		end
	end

	return `Session {index}`
end

function SessionHelpers.parseUserId(entry: any): number?
	if type(entry) == "number" then
		return entry
	end
	if type(entry) == "string" then
		return tonumber(entry)
	end
	if type(entry) ~= "table" then
		return nil
	end

	for _, key in ipairs(SessionHelpers.PLAYER_ID_KEYS) do
		local value = entry[key]
		if type(value) == "number" then
			return value
		end
		if type(value) == "string" then
			local parsed = tonumber(value)
			if parsed then
				return parsed
			end
		end
	end

	return nil
end

function SessionHelpers.normalizeSessions(payload: any): { [number]: any }
	if type(payload) ~= "table" then
		return {}
	end

	if type(payload.sessions) == "table" then
		return payload.sessions
	end

	if type(payload.data) == "table" then
		if type(payload.data.sessions) == "table" then
			return payload.data.sessions
		end
		return payload.data
	end

	return payload
end

function SessionHelpers.extractSessionsFromArgs(...: any): { [number]: any }
	for _, argument in ipairs({ ... }) do
		if type(argument) == "table" then
			return SessionHelpers.normalizeSessions(argument)
		end
	end
	return {}
end

return SessionHelpers
