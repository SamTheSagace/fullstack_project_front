local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"))

local Hello = Modules.require("Hello")
local Users = Modules.require("Api.Users")

Hello()

Users()

print("Hello world, from server!")


