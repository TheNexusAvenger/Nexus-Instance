--[[
TheNexusAvenger

Implements the NexusEvent interface using
Roblox's BindableEvents.
--]]

local CLASS_NAME = "RobloxEvent"



local NexusObjectFolder = script.Parent.Parent
local NexusObject = require(NexusObjectFolder:WaitForChild("NexusObject"))
local NexusEvent = require(script.Parent:WaitForChild("NexusEvent"))
local NexusConnection = require(script.Parent:WaitForChild("NexusConnection"))

local RobloxEvent = NexusObject:Extend()
RobloxEvent:SetClassName(CLASS_NAME)
RobloxEvent:Implements(NexusEvent)



--[[
Creates an event.
--]]
function RobloxEvent:__new()
	self:InitializeSuper()
	self.Connections = {}
	self.BindableEvent = Instance.new("BindableEvent")
end

--[[
Invoked when a connection is disconnected.
--]]
function RobloxEvent:Disconnected(Connection)
	--Remove the bindable event connection.
	local BindableEventConnection = self.Connections[Connection]
	if BindableEventConnection then
		BindableEventConnection:Disconnect()
	end
	
	--Remove the connection.
	self.Connections[Connection] = nil
end

--[[
Disconnects all connected events.
--]]
function RobloxEvent:Disconnect()
	--Get the connections to disconnect.
	local ConnectionsToDisconnect = {}
	for Connection,_ in pairs(self.Connections) do
		table.insert(ConnectionsToDisconnect,Connection)
	end
	
	--Disconnect the events.
	for _,Connection in pairs(ConnectionsToDisconnect) do
		Connection:Disconnect()
	end
end

--[[
Establishes a function to be called whenever
the event is raised.
--]]
function RobloxEvent:Connect(Function)
	--Create the connection.
	local Connection = NexusConnection.new(self,Function)
	
	--Set up the bindable event.
	local BindableEventConnection = self.BindableEvent.Event:Connect(function(...)
		Connection:Fire(...)
	end)
	
	--Store the connections.
	self.Connections[Connection] = BindableEventConnection
	
	--Return the connection.
	return Connection
end


--[[
Fires the event.
--]]
function RobloxEvent:Fire(...)
	self.BindableEvent:Fire(...)
end

--[[
Yields the current thread until this signal
is fired. Returns what was fired to the signal.
--]]
function RobloxEvent:Wait()
	return self.BindableEvent.Event:Wait()
end



return RobloxEvent