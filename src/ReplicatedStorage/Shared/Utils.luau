local Utils = {}

function Utils.trim(value: string): string
	return string.gsub(value, "^%s*(.-)%s*$", "%1")
end

function Utils.fireError(player: Player, message: string, remotes: { [string]: RemoteEvent })
	if remotes then
		remotes.errorEvent:FireClient(player, { message = message, type = "errorEvent" })
	end
end

return Utils
