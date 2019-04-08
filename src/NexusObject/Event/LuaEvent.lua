--[[
TheNexusAvenger

Implements the NexusEvent interface using
Lua coroutines.
--]]

local CLASS_NAME = "LuaEvent"



local NexusObjectFolder = script.Parent.Parent
local NexusObject = require(NexusObjectFolder:WaitForChild("NexusObject"))
local NexusEvent = require(script.Parent:WaitForChild("NexusEvent"))
local NexusConnection = require(script.Parent:WaitForChild("NexusConnection"))

local LuaEvent = NexusObject:Extend()
LuaEvent:SetClassName(CLASS_NAME)
LuaEvent:Implements(NexusEvent)



--[[
Creates an event.
--]]
function LuaEvent:__new()
	self:InitializeSuper()
	self.Connections = {}
end

--[[
Invoked when a connection is disconnected.
--]]
function LuaEvent:Disconnected(Connection)
	self.Connections[Connection] = nil
end

--[[
Disconnects all connected events.
--]]
function LuaEvent:Disconnect()
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
function LuaEvent:Connect(Function)
	--Create and store the connection.
	local Connection = NexusConnection.new(self,Function)
	self.Connections[Connection] = true
	
	--Return the connection.
	return Connection
end


--[[
Fires the event.
--]]
function LuaEvent:Fire(...)
	local Parameters = {...}
	for Connection,_ in pairs(self.Connections) do
		 coroutine.resume(coroutine.create(function()
			Connection:Fire(unpack(Parameters))
         end))
	end
end

--[[
Yields the current thread until this signal
is fired. Returns what was fired to the signal.
--]]
function LuaEvent:Wait()
	local Return
	
	--Create the connection.
	local Connection = self:Connect(function(...)
		Return = {...}
	end)
	
	--Wait for the connection to be fired.
	while not Return do wait() end
	
	--Disconnect the connection and return the fired parameters.
	Connection:Disconnect()
	return unpack(Return)
end



return LuaEvent