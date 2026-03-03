local Utils = {}

function Utils.trim(value: string): string
	return string.gsub(value, "^%s*(.-)%s*$", "%1")
end


return Utils