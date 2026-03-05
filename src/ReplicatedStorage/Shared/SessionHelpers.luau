local SessionHelpers = {}

export type SessionMember = {
	id: number?,
	roblox_user_id: number?,
	display_name: string?,
	role: string?,
	status: string?,
	joined_at: string?,
	left_at: string?,
	last_seen_at: string?,
}

export type Session = {
	id: number?,
	code: string?,
	name: string?,
	status: string?,
	owner_roblox_user_id: number?,
	created_at: string?,
	updated_at: string?,
	session_members: { SessionMember }?,
}

export type ListSessionsResponse = {
	sessions: { Session }?,
}

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
		return sessionData.name
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

return SessionHelpers
