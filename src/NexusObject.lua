--[[
TheNexusAvenger

Helper class for creating objects in Lua.
--]]

--Class name of the object.
local CLASS_NAME = "NexusObject"

--Metamethods to pass through.
local METATABLE_PASSTHROUGH = {
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



local NexusObject = {
	ClassName = CLASS_NAME,
	Interfaces = {},
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
Returns the first object from the interfaces.
--]]
local function GetFromInterfaces(Object,Class,Index)
	for _,Interface in pairs(Class:GetInterfaces(Class)) do
		local InterfaceReturn = Interface[Index]
		if InterfaceReturn then
			return InterfaceReturn
		end
	end
end



--[[
Creates an instance of a NexusObject. This is used
as a base.
--]]
function NexusObject.new(...)
	--Create the object.
	local self = {}
	self.class = NexusObject
	self.object = self
	
	--Set up the metatable.
	local Metatable = {}
	Metatable.__index = function(_,Index)
		local RawGet = rawget(self,Index)
		if RawGet then
			return RawGet
		end
		
		return NexusObject[Index]
	end
	setmetatable(self,Metatable)
	
	--Add the metamethod passthrough.
	for _,Name in pairs(METATABLE_PASSTHROUGH) do
		Metatable[Name] = function(_,...)
			return self[Name](self,...)
		end
	end
	
	--Run the constructor.
	self:__new(...)
	
	--Return the object.
	return self
end

--[[
Constructor run for the class.
--]]
function NexusObject:__new()
	
end

--[[
Called after extending when another class extends
the class. The purpose of this is to add attributes
to the class.
--]]
function NexusObject:__classextended(OtherClass)
	OtherClass.Interfaces = {}
end

--[[
Creates an __index metamethod for an object. Used to
setup custom indexing.
--]]
function NexusObject:__createindexmethod(Object,Class,RootClass)
	--Set the root class.
	if not RootClass then
		RootClass = Class
	end
	
	--Get the method.
	if Class.super then
		--[[
		Returns the value for an index of an object.
		--]]
		return function(_,Index)
			if Index == "super" then
				--Create a temporary object.
				local TempObject = {}
				TempObject.object = Object
				
				--Set the metatable to redirect the next "super".
				local Metatable = {}
				Metatable.__index = RootClass:__createindexmethod(Object,Class.super,RootClass)
				Metatable.__newindex = function(_,Index,Value)
					Object[Index] = Value
				end
				setmetatable(TempObject,Metatable)
				
				--Return the temporary object.
				return TempObject
			else
				--Get the normal property from the object or class.
				local RawReturn = rawget(Object,Index)
				if RawReturn ~= nil then
					return RawReturn
				end
				
				return Class[Index]
			end
		end
	else
		--[[
		Returns the value for an index of an object.
		--]]
		return function(_,Index)
			local RawReturn = rawget(Object,Index)
			if RawReturn ~= nil then
				return RawReturn
			end
			
			return Class[Index]
		end
	end
end

--[[
Returns the object as a string.
--]]
function NexusObject:__tostring()
	local MemoryAddress = string.sub(RawToString(self),8)
	return tostring(self.ClassName)..": "..tostring(MemoryAddress)
end

--[[
Initializes the super class. The paramters given
by "..." are passed into the constructor of the
super class (__new(...)). It should be called
in the constructor of the class.
--]]
function NexusObject:InitializeSuper(...)
	if self.super then
		self.super:__new(...)
	end
end

--[[
Sets the class name of the class. Should be
called staticly (right after NexusObject::Extend).
--]]
function NexusObject:SetClassName(ClassName)
	self.ClassName = ClassName
end

--[[
Sets the class as implementing a given interface. Should be
called staticly (right after NexusObject::Extend).
--]]
function NexusObject:Implements(Interface)
	--Throw an error if the interface isn't an interface.
	if not Interface:IsA("NexusInterface") then
		error(tostring(Interface).." is not an interface.")
	end
	
	--Add the interface.
	table.insert(self.Interfaces,Interface)
end

--[[
Returns a list of the interfaces that the
class implements. This includes ones implemented
by super classes.
--]]
function NexusObject:GetInterfaces()
	--Get the super class's interfaces.
	local Interfaces = {}
	if self.super then
		Interfaces = self.super:GetInterfaces()
	end
	
	--Add the classes interfaces.
	local ClassInterfaces = self.Interfaces
	if ClassInterfaces then
		for _,Interface in pairs(ClassInterfaces) do
			 table.insert(Interfaces,Interface)
		end
	end
	
	--Return the interfaces.
	return Interfaces
end

--[[
Returns if the instance is or inherits from a class of that name.
--]]
function NexusObject:IsA(ClassName)
	--If the class name matches the class name, return true.
	if self.ClassName == ClassName then
		return true
	end
	
	--If an interface matches the name, return true.
	if self.Interfaces then
		for _,Interface in pairs(self.Interfaces) do
			if Interface:IsA(ClassName) then
				return true
			end
		end
	end
	
	--If a super class exists, return the result of the super.
	if self.super then
		return self.super:IsA(ClassName)
	end
	
	--Return false (no match).
	return false
end

--[[
Extends a class to allow for implementing properties and
functions while inheriting the super class's behavior.
--]]
function NexusObject:Extend()
	local super = self
	local ExtendedClass = {
		super = super,
	}
	
	--[[
	Creates an instance of the class.
	--]]
	function ExtendedClass.new(...)
		--Create the object.
		local self = {}
		self.class = ExtendedClass
		self.object = self
		
		--Set up the metatable.
		local Metatable = {}
		Metatable.__index = ExtendedClass:__createindexmethod(self,ExtendedClass)
		setmetatable(self,Metatable)
		
		--Add the metamethod passthrough.
		for _,Name in pairs(METATABLE_PASSTHROUGH) do
			Metatable[Name] = function(_,...)
				return self[Name](self,...)
			end
		end
		
		--Run the constructor.
		self:__new(...)
		
		--Determine the missing attributes.
		local MissingAttributes = {}
		for _,Interface in pairs(self:GetInterfaces()) do
			for _,Attribute in pairs(Interface:GetMissingAttributes(self)) do
				table.insert(MissingAttributes,{Interface.ClassName,Attribute})
			end
		end
		
		--Throw an error if missing attributes exist.
		if #MissingAttributes > 0 then
			--Create the message.
			local ErrorMessage = tostring(self.ClassName).." does not implement the following:"
			for _,Attribute in pairs(MissingAttributes) do
				ErrorMessage = ErrorMessage.."\n\t"..tostring(Attribute[1]).."."..tostring(Attribute[2])
			end
			
			--Throw the error.
			error(ErrorMessage)
		end
		
		--Return the object.
		return self
	end
	
	--[[
	Constructor run for the class.
	--]]
	function ExtendedClass:__new(...)
		self:InitializeSuper(...)
	end
	
	--[[
	Called after extending when another class extends
	the class. The purpose of this is to add attributes
	to the class.
	--]]
	function ExtendedClass:__classextended(OtherClass)
		self.super:__classextended(OtherClass)
	end
	
	--Set up the metatable for indexing.
	local Metatable = {}
	Metatable.__index = function(_,Index)
		--Return the value for the class.
		local ClassReturn = rawget(ExtendedClass,Index)
		if ClassReturn ~= nil then
			return ClassReturn
		end
		
		--Return the value for the super classes.
		local SuperClassReturn = super[Index]
		if SuperClassReturn ~= nil then
			return SuperClassReturn
		end
		
		--Return the value for the interfaces.
		return GetFromInterfaces(ExtendedClass,ExtendedClass,Index)
	end
	setmetatable(ExtendedClass,Metatable)
	
	--Extend the class.
	super:__classextended(ExtendedClass)
	
	--Return the extended class.
	return ExtendedClass
end



return NexusObject