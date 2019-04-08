--[[
TheNexusAvenger

Represents an event connection.
--]]

local CLASS_NAME = "NexusConnection"



local NexusObjectFolder = script.Parent.Parent
local NexusObject = require(NexusObjectFolder:WaitForChild("NexusObject"))
local NexusConnection = NexusObject:Extend()
NexusConnection:SetClassName(CLASS_NAME)



--[[
Creates an instance of the connection.
--]]
function NexusConnection:__new(Event,ConnectionFunction)
	self:InitializeSuper()
	self.Event = Event
	self.ConnectionFunction = ConnectionFunction
	self.Connected = true
end

--[[
Fires the connection.
--]]
function NexusConnection:Fire(...)
	if self.Connected then
		self.ConnectionFunction(...)
	end
end

--[[
Disconnects the connection from the event.
--]]
function NexusConnection:Disconnect()
	if self.Connected then
		self.Connected = false
		self.Event:Disconnected(self)
	end
end



return NexusConnection