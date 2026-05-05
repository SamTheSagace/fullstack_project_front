local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommonTypes = require(ReplicatedStorage.Types.Common)
type SessionMember = CommonTypes.SessionMember
type Session = CommonTypes.Session
type ListSessionsResponse = CommonTypes.ListSessionsResponse

local SessionHelpers = {}

function SessionHelpers.getSessionPlayerIds(sessionData: any): { number }
	if type(sessionData) ~= "table" then
		return {}
	end

	local members = sessionData.session_members
	if type(members) ~= "table" then
		return {}
	end

	local ids = table.create(#members)
	local dedupe = {}
	for _, member in ipairs(members) do
		local userId = if type(member) == "table" then member.roblox_user_id else nil
		if type(userId) == "number" and not dedupe[userId] then
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

	if type(sessionData.name) == "string" and sessionData.name ~= "" then
		return `{sessionData.name} - {sessionData.code}`
	end

	return `Session {index}`
end

function SessionHelpers.normalizeSessions(payload: any): { Session }
	if type(payload) ~= "table" then
		return {}
	end

	local sessions = payload.sessions
	if type(sessions) ~= "table" then
		return {}
	end

	return sessions
end

function SessionHelpers.extractSessionsFromArgs(...: any): { Session }
	local payload = select(1, ...)
	return SessionHelpers.normalizeSessions(payload)
end

function SessionHelpers.closestFibonacci(n: number): number
	if n <= 0 then
		return 0
	end

	local a, b = 0, 1
	while b < n do
		a, b = b, a + b
	end

	if (n - a) <= (b - n) then
		return a
	else
		return b
	end
end

return SessionHelpers
