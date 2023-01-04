--[[
TheNexusAvenger

Implements the NexusPropertyValidator by
checking if the type or class is the same.
--]]

local NexusObjectFolder = script.Parent.Parent
local NexusObject = require(NexusObjectFolder:WaitForChild("NexusObject"))

local TypePropertyValidator = NexusObject:Extend()
TypePropertyValidator:SetClassName("TypePropertyValidator")

export type TypePropertyValidator = {
    CreateTypeValidator: (Type: string) -> ((string, any) -> (any)),
    new: (Type: string) -> (TypePropertyValidator),
    Extend: (self: TypePropertyValidator) -> (TypePropertyValidator),

    ValidateChange: (self: TypePropertyValidator, Object: any, ValueName: string, Value: any) -> (any),
} & NexusObject.NexusObject



--[[
Creates a type validator for a type.
--]]
function TypePropertyValidator.CreateTypeValidator(Type: string): (string, any) -> (any)
    return function(ValueName: string, Value: any): any
        --Determine the type.
        local TypeMatches, ClassMatches = false, false
        local ValueType = typeof(Value)

        --Determine if the type matchs.
        if ValueType == Type then
            TypeMatches = true
        end

        --Determine if the class name matches.
        if not TypeMatches and (ValueType == "Instance" or (ValueType == "table" and typeof(Value.IsA) == "function")) then
            ValueType = Value.ClassName
            if Value:IsA(Type) then
                ClassMatches = true
            end
        end

        --Throw an error if the type is invalid.
        if not TypeMatches and not ClassMatches then
            error("Bad value for \""..tostring(ValueName).."\" ("..tostring(Type).." expected, got "..ValueType..")")
        end

        --Return the original value.
        return Value
    end
end

--[[
Creates a type validator.
--]]
function TypePropertyValidator:__new(Type: string): ()
    warn("TypePropertyValidator.new() is deprecated with object-based validators. Use CreateTypeValidator(Type) instead.")
    NexusObject.__new(self)
    self.Validator = TypePropertyValidator.CreateTypeValidator(Type)
end

--[[
Validates a change to the property of a NexusObject.
The new value must be returned. If the input is invalid,
an error should be thrown.
--]]
function TypePropertyValidator:ValidateChange(Object: any, ValueName: string, Value: any)
    return self.Validator(ValueName, Value)
end



return TypePropertyValidator :: TypePropertyValidator