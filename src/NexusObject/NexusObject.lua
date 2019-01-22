--[[
TheNexusAvenger

Helper class for creating objects in Lua.
--]]

--Class name of the object.
local CLASS_NAME = "NexusObject"



local NexusObject = {
	ClassName = CLASS_NAME
}



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
	
	--Run the constructor.
	self:__new(...)
	
	--Return the object.
	return self
end

--[[
Constructor run for the class.
For NexusObject, only the class name is set.
--]]
function NexusObject:__new()
	
end

--[[
Called after the constructor when another object
extends the object. The primary purpose is to be
able to manipulate the metatables of a class for
something like NexusInstance.
For NexusObject, nothing is done.
--]]
function NexusObject:__extended(OtherObject)
	
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
		
		--Set up the metatable.
		local Metatable = {}
		Metatable.__index = function(_,Index)
			--Return the instance's return.
			local BaseInstanceReturn = rawget(self,Index) or rawget(ExtendedClass,Index)
			if BaseInstanceReturn then
				return BaseInstanceReturn
			end
			
			--Return the static super class's return.
			return super[Index]
		end
		setmetatable(self,Metatable)
		
		--Run the constructor.
		self:__new(...)
		
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
	Called after the constructor when another object
	extends the object. The primary purpose is to be
	able to manipulate the metatables of a class for
	something like NexusInstance.
	--]]
	function ExtendedClass:__extended(OtherObject)
		self.super:__extended(OtherObject)
	end
	
	--Set up the class.
	local Metatable = {}
	setmetatable(ExtendedClass,Metatable)
	Metatable.__index = function(_,Index)
		return rawget(ExtendedClass,Index) or super[Index]
	end
	
	--Return the inherited class.
	return ExtendedClass
end



return NexusObject