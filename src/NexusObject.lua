--[[
TheNexusAvenger

Helper class for creating objects in Lua.
--]]
--!strict

local METATABLE_METHODS = {
    "__call",
    "__concat",
    "__unm",
    "__add",
    "__sub",
    "__mul",
    "__div",
    "__mod",
    "__pow",
    "__tostring",
    "__eq",
    "__lt",
    "__le",
    "__gc",
    "__len",
}



--[[
Returns the raw tostring of a table.
See: https://stackoverflow.com/questions/43285679/is-it-possible-to-bypass-tostring-the-way-rawget-set-bypasses-index-newind
--]]
local function RawToString(Table: any): string
    local Metatable = getmetatable(Table)
    local BaseFunction = Metatable.__tostring
    Metatable.__tostring = nil

    local String = tostring(Table)
    Metatable.__tostring = BaseFunction
    return String
end

--[[
Extends a class.
--]]
local function ExtendClass(SuperClass: {[string]: any}?) : NexusObject
    --Create the class.
    local Class = {}
    Class.super = SuperClass
    Class.__index = Class
    setmetatable(Class :: any, SuperClass)

    --[[
    Creates an object.
    --]]
    function Class.new(...)
        --Create the base object.
        local self = {} :: NexusObject
        self.__index = self
        self.class = Class
        setmetatable(self :: any, Class)

        --Run the constructor.
        self:__new(...)

        --Return the object.
        return self
    end

    --[[
    Constructor run for the class.
    --]]    
    function Class:__new(...)
        if not SuperClass then return end
        (SuperClass :: NexusObject).__new(self, ...)
    end

    --Add the metamethod passthrough.
    if SuperClass then
        for _, MetatableName in METATABLE_METHODS do
            Class[MetatableName] = SuperClass[MetatableName]
        end
    end

    --Call the callback for the class being extended.
    if SuperClass then
        SuperClass:__classextended(Class)
    end

    --Return the created class.
    return (Class :: any) :: NexusObject
end



--Set up the base Nexus Object class.
local NexusObject = ExtendClass() :: NexusObject
NexusObject.ClassName = "NexusObject"

export type NexusObject = {
    --Properties.
    class: {[string]: any},
    super: NexusObject,
    ClassName: string,
    [string]: any,

    --Static methods.
    new: () -> (NexusObject),
    Extend: (self: NexusObject) -> (NexusObject),
    SetClassName: (self: NexusObject, ClassName: string) -> (NexusObject),

    --Methods.
    IsA: (self: NexusObject, ClassName: string) -> (boolean),
}



--[[
Called after extending when another class extends
the class. The purpose of this is to add attributes
to the class.
--]]
function NexusObject:__classextended(OtherClass: NexusObject): ()
    if not self.super then return end
    self.super:__classextended(OtherClass)
end

--[[
Returns the object as a string.
--]]
function NexusObject:__tostring(): string
    local MemoryAddress = string.sub(RawToString(self), 8)
    return tostring(self.ClassName)..": "..tostring(MemoryAddress)
end

--[[
Returns if the object is equal to another object.
--]]
function NexusObject:__eq(OtherObject: any): boolean
    return rawequal(self, OtherObject)
end

--[[
Sets the class name of the class. Should be
called staticly (right after NexusObject::Extend).
--]]
function NexusObject:SetClassName(ClassName: string): NexusObject
    self.ClassName = ClassName
    return self
end

--[[
Extends a class to allow for implementing properties and
functions while inheriting the super class's behavior.
--]]
function NexusObject:Extend(): NexusObject
    return (ExtendClass(self) :: any) :: NexusObject
end

--[[
Returns if the instance is or inherits from a class of that name.
--]]
function NexusObject:IsA(ClassName: string): boolean
    --If the class name matches the class name, return true.
    local CurrentClass = self
    while CurrentClass do
        if CurrentClass.ClassName == ClassName then
            return true
        end
        CurrentClass = CurrentClass.super
    end

    --Return false (no match).
    return false
end



return NexusObject