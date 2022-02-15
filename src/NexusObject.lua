--[[
TheNexusAvenger

Helper class for creating objects in Lua.
--]]

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
local function RawToString(Table)
    local Metatable = getmetatable(Table)
    local BaseFunction = Metatable.__tostring
    Metatable.__tostring = nil

    local String = tostring(Table)
    Metatable.__tostring = BaseFunction
    return String
end

--[[
Creates the referebce to a super class.
--]]
local function CreateSuperReference(Object, SuperClass)
    --Return nil if there is no super class.
    if SuperClass == nil then
        return nil
    end

    --Create the super reference.
    local Super = {}
    local NextSuperReference = CreateSuperReference(Object, SuperClass.__superclass)
    local SuperMetatable = {}
    SuperMetatable.__index = function(_, Index)
        --Return super.
        --Special case to prevent recursive errors.
        if Index == "super" then
            return NextSuperReference
        end

        --Get the super reference until it doesn't match.
        local ObjectValue = Object[Index]
        local CurrentSuperClass = SuperClass
        local SuperValue = CurrentSuperClass[Index]
        while ObjectValue == SuperValue do
            CurrentSuperClass = CurrentSuperClass.__superclass
            if CurrentSuperClass == nil then break end
            SuperValue = CurrentSuperClass[Index]
        end

        --Return the super value that is different or the object value.
        return SuperValue or Object[Index]
    end
    SuperMetatable.__newindex = Object
    setmetatable(Super, SuperMetatable)

    --Return the super reference.
    return Super
end

--[[
Extends a class.
--]]
local function ExtendClass(SuperClass)
    --Create the class.
    local Class = {}
    Class.super = SuperClass
    Class.__superclass = SuperClass
    Class.__index = Class
    setmetatable(Class, SuperClass)

    --[[
    Creates an object.
    --]]
    function Class.new(...)
        --Create the base object.
        local self = {}
        self.__index = self
        self.object = self
        self.class = SuperClass
        self.super = CreateSuperReference(self, SuperClass)
        setmetatable(self, Class)

        --Run the constructor.
        self:__new(...)

        --Return the object.
        return self
    end

    --[[
    Constructor run for the class.
    --]]    
    function Class:__new(...)
        self:InitializeSuper(...)
    end

    --Add the metamethod passthrough.
    if SuperClass then
        for _, MetatableName in pairs(METATABLE_METHODS) do
            Class[MetatableName] = SuperClass[MetatableName]
        end
    end

    --Call the callback for the class being extended.
    if SuperClass then
        SuperClass:__classextended(Class)
    end

    --Return the created class.
    return Class
end



--Set up the base Nexus Object class.
local NexusObject = ExtendClass()
NexusObject.ClassName = "NexusObject"



--[[
Called after extending when another class extends
the class. The purpose of this is to add attributes
to the class.
--]]
function NexusObject:__classextended(OtherClass)
    if not self.super then return end
    self.super:__classextended(OtherClass)
end

--[[
Returns the object as a string.
--]]
function NexusObject:__tostring()
    local MemoryAddress = string.sub(RawToString(self), 8)
    return tostring(self.ClassName)..": "..tostring(MemoryAddress)
end

--[[
Returns if the object is equal to another object.
--]]
function NexusObject:__eq(OtherObject)
    return rawequal(self,OtherObject)
end

--[[
Initializes the super class. The paramters given
by "..." are passed into the constructor of the
super class (__new(...)). It should be called
in the constructor of the class.
--]]
function NexusObject:InitializeSuper(...)
    if not self.super then return end
    self.super:__new(...)
end

--[[
Sets the class name of the class. Should be
called staticly (right after NexusObject::Extend).
--]]
function NexusObject:SetClassName(ClassName)
    self.ClassName = ClassName
end

--[[
Extends a class to allow for implementing properties and
functions while inheriting the super class's behavior.
--]]
function NexusObject:Extend()
    return ExtendClass(self)
end

--[[
Returns if the instance is or inherits from a class of that name.
--]]
function NexusObject:IsA(ClassName)
    --If the class name matches the class name, return true.
    if self.ClassName == ClassName then
        return true
    end

    --If a super class exists, return the result of the super.
    if self.super then
        return self.super:IsA(ClassName)
    end

    --Return false (no match).
    return false
end



return NexusObject