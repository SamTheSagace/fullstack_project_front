local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Users = require(ReplicatedStorage.Shared.Api.Users)

Users()

print("Hello world, from server!")