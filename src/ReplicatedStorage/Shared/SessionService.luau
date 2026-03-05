local SessionService = {}
local sessions = {} -- code -> session state

function SessionService:getOrCreate(code)
	sessions[code] = sessions[code]
		or {
			code = code,
			phase = "waiting",
			members = {}, -- userId -> {name, participate, ready, vote}
			items = {},
			currentItemIndex = 0,
		}
	return sessions[code]
end

function SessionService:join(code, userId, name, participate)
	local s = self:getOrCreate(code)
	s.members[userId] = s.members[userId] or { userId = userId, name = name }
	s.members[userId].participate = participate and true or false
	s.members[userId].name = name
	return true
end

function SessionService:isHost(code, userId)
	local s = sessions[code]
	return s and s.hostUserId == userId
end

function SessionService:getSnapshot(code)
	local s = sessions[code]
	if not s then
		return nil
	end
	-- build an array of members for client
	local members = {}
	for _, m in pairs(s.members) do
		table.insert(members, m)
	end
	return {
		code = s.code,
		phase = s.phase,
		currentItemIndex = s.currentItemIndex,
		members = members,
		items = s.items,
	}
end

return SessionService
