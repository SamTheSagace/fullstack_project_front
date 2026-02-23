local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Modules = {}

local function resolvePath(root: Instance, path: string): Instance
	local current = root
	
	for segment in string.gmatch(path, "[^%.]+") do
		current = current:WaitForChild(segment)
	end
	
	return current
end

function Modules.require(path: string)
	local moduleScript = resolvePath(Shared, path)
	return require(moduleScript)
end

return Modules
