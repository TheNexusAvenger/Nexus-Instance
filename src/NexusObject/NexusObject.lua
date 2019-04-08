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
Creates an instance of a Nexus Instance. This is used
as a base.
--]]
function NexusObject.new(...)
	--Create the object.
	local self = {}
	
	--Set up the metatable.
	local Metatable = {}
	Metatable.__index = function(self,Index)
		return rawget(NexusObject,Index)
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
Called after the constructor when another object
extends the object. The primary purpose is to be
able to manipulate the metatables of a class for
something like NexusInstance.
--]]
function NexusObject:__extended(OtherObject)
	
end

--[[
Returns the object as a string.
--]]
function NexusObject:__tostring()
	local MemoryAddress = string.sub(RawToString(self),8)
	return tostring(self.ClassName)..": "..tostring(MemoryAddress)
end

--[[
Initializes the super class.
--]]
function NexusObject:InitializeSuper(...)
	--Return if there is no super.
	if not self.super then
		return
	end
	
	--Create the super object.
	local super = {}
	local BaseSuper = self.super
	
	local Metatable = {}
	Metatable.__newindex = self
	Metatable.__index = function(_,Index)
		--Return the super's return.
		local SuperReturn = rawget(super,Index) or BaseSuper[Index]
		if SuperReturn then
			return SuperReturn
		end
		
		--Return the instance's return.
		local SubReturn = self[Index]
		if SubReturn then
			return SubReturn
		end
		
		--Return the super's super return.
		local SuperInstance = rawget(BaseSuper,"super")
		if SuperInstance then
			local SuperInstanceReturn = SuperInstance[Index]
			if SuperInstanceReturn then
				return SuperInstanceReturn
			end
		end
	end
	setmetatable(super,Metatable)
	
	--Set the super class and run the constructor of the super class.
	rawset(self,"super",super)
	self.super:__new(...)
	self.super:__extended(self)
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
	if self.super and self.super ~= self then
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
	if self.super and self.super.ClassName ~= self.ClassName then
		return self.super:IsA(ClassName)
	end
	
	--Return false (no match).
	return false
end



--[[
Extends a Nexus Instance class and returns the inherited class.
--]]
function NexusObject:Extend()
	local super = self
	local ExtendedClass = {
		super = super
	}
	
	--[[
	Creates an instance of the class.
	--]]
	function ExtendedClass.new(...)
		local self = {}
		local Metatable = {}
		
		--[[
		Returns the first object from the interfaces.
		--]]
		local function GetFromInterfaces(Index)
			for _,Interface in pairs(ExtendedClass:GetInterfaces(self)) do
				local InterfaceReturn = Interface[Index]
				if InterfaceReturn then
					return InterfaceReturn
				end
			end
		end
		
		--Add the metamethod passthrough.
		for _,Name in pairs(METATABLE_PASSTHROUGH) do
			Metatable[Name] = function(_,...)
				return self[Name](self,...)
			end
		end
		
		--Set up the metatable.
		local GetInterfacesFunction
		Metatable.__index = function(_,Index)
			--Return the instance's return.
			local BaseInstanceReturn = rawget(self,Index) or rawget(ExtendedClass,Index)
			if BaseInstanceReturn then
				return BaseInstanceReturn
			end
			
			--Return the instance's interface reutrn.
			local InterfaceReturn = GetFromInterfaces(Index)
			if InterfaceReturn then
				return InterfaceReturn
			end
			
			--Return the static super class's return.
			return super[Index]
		end
		setmetatable(self,Metatable)
		
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
	For NexusObject, nothing is done.
	--]]
	function ExtendedClass:__classextended(OtherClass)
		self.super:__classextended(OtherClass)
	end
	
	--[[
	Called after the constructor when another object
	extends the object. The primary purpose is to be
	able to manipulate the metatables of a class for
	something like NexusInstance.
	--]]
	function ExtendedClass:__extended(OtherObject)
		super:__extended(OtherObject)
	end
	
	--Set up the class.
	local Metatable = {}
	setmetatable(ExtendedClass,Metatable)
	Metatable.__index = function(_,Index)
		return rawget(ExtendedClass,Index) or super[Index]
	end
	
	Metatable.__tostring = function()
		return "NexusObject."..tostring(ExtendedClass.ClassName)
	end
	
	--Extend the class.
	self:__classextended(ExtendedClass)
	
	--Return the inherited class.
	return ExtendedClass
end



return NexusObject