--[[
TheNexusAvenger

Provides a function "interface" for dependant classes
to implement.
--]]

--Class name of the object.
local CLASS_NAME = "NexusInterface"



local NexusObject = require(script.Parent:WaitForChild("NexusObject"))
local NexusInterface = NexusObject:Extend()
NexusInterface:SetClassName(CLASS_NAME)
NexusInterface.RequiredAttributes = {}



--[[
Called after extending when another class extends
the class. The purpose of this is to add attributes
to the class.
For NexusObject, nothing is done.
--]]
function NexusObject:__classextended(OtherClass)
	OtherClass.RequiredAttributes = {}
end
	
--[[
Sets an attribute as required for an object.
Although it is intended to be a name of a function,
it can be any type, and can be implemented
after the constructor is run.
--]]
function NexusInterface:MustImplement(Attribute)
	table.insert(self.RequiredAttributes,Attribute)
end

--[[
Returns a list of the missing attributes from
an object based on the interface. If no attributes
are missing, an empty list is returned.
--]]
function NexusInterface:GetMissingAttributes(Object)
	--Get the missing attributes.
	local MissingAttributes = {}
	for _,Attribute in pairs(self.RequiredAttributes) do
		if not Object[Attribute] then
			table.insert(MissingAttributes,Attribute)
		end
	end
	
	--Return the missing attributes.
	return MissingAttributes
end



return NexusInterface