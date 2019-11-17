--[[
TheNexusAvenger

Implements the NexusPropertyValidator by
checking if the type or class is the same.
--]]

local CLASS_NAME = "TypePropertyValidator"



local NexusObjectFolder = script.Parent.Parent
local NexusObject = require(NexusObjectFolder:WaitForChild("NexusObject"))
local NexusPropertyValidator = require(script.Parent:WaitForChild("NexusPropertyValidator"))

local TypePropertyValidator = NexusObject:Extend()
TypePropertyValidator:SetClassName(CLASS_NAME)
TypePropertyValidator:Implements(NexusPropertyValidator)



--[[
Creates an event.
--]]
function TypePropertyValidator:__new(Type)
	self:InitializeSuper()
	self.Type = Type
end

--[[
Validates a change to the property of a NexusObject.
The new value must be returned. If the input is invalid,
an error should be thrown.
--]]
function TypePropertyValidator:ValidateChange(Object,ValueName,Value)
	--Determine the type.
	local TypeMatches,ClassMatches = false,false
	local ValueType = typeof(Value)
	
	--Determine if the type matchs.
	if ValueType == self.Type then
		TypeMatches = true
	end
	
	--Determine if the class name matches.
	if not TypeMatches and (ValueType == "Instance" or (ValueType == "table" and typeof(Value.IsA) == "function")) then
		ValueType = Value.ClassName
		if Value:IsA(self.Type) then
			ClassMatches = true
		end
	end
	
	--Throw an error if the type is invalid.
	if not TypeMatches and not ClassMatches then
		error("Bad value for \""..tostring(ValueName).."\" ("..tostring(self.Type).." expected, got "..ValueType..")")
	end
	
	--Return the original value.
	return Value
end



return TypePropertyValidator