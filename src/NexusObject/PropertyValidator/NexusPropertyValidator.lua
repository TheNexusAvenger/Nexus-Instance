--[[
TheNexusAvenger

Interface for a property validator.
--]]

local CLASS_NAME = "NexusPropertyValidator"



local NexusObjectFolder = script.Parent.Parent
local NexusInterface = require(NexusObjectFolder:WaitForChild("NexusInterface"))
local NexusPropertyValidator = NexusInterface:Extend()
NexusPropertyValidator:SetClassName(CLASS_NAME)



--[[
Validates a change to the property of a NexusObject.
The new value must be returned. If the input is invalid,
an error should be thrown.
--]]
NexusPropertyValidator:MustImplement("ValidateChange")



return NexusPropertyValidator