local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Session = require(ReplicatedStorage.Shared.Api.Session)

Session();
print("Hello world, from server!")