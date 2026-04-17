local SessionStore = {}

local sessionMetaByCode = {}

function SessionStore.get(code: string)
	return sessionMetaByCode[code]
end

function SessionStore.set(code: string, data)
	sessionMetaByCode[code] = data
end

function SessionStore.remove(code: string)
	sessionMetaByCode[code] = nil
end

function SessionStore.getAll()
	return sessionMetaByCode
end

function SessionStore.update(code: string, updater)
	local current = sessionMetaByCode[code]
	if current then
		updater(current)
	end
end

return SessionStore
