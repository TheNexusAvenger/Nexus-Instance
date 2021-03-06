--[[
TheNexusAvenger

Implements the NexusEvent interface using
Roblox's BindableEvents.
--]]

local CLASS_NAME = "RobloxEvent"



local HttpService = game:GetService("HttpService")

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

    --For deferred events, the arguments need to be stored.
    --LastArgumentsStrong will keep the reference around and prevent
    --it from being garbage collected until only LastArguments references it.
    --Ideally, they will be used at the same time if both :Connect() and
    --:Wait() are used.
    self.LastArgumentsStrong = {}
    self.LastArguments = {}
    setmetatable(self.LastArguments,{__mode="v"})
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
    local BindableEventConnection = self.BindableEvent.Event:Connect(function(UUID)
        --Get the arguments.
        local Arguments = self.LastArguments[UUID]
        self.LastArgumentsStrong[Arguments] = nil

        --Fire the event.
        Connection:Fire(unpack(Arguments.Arguments,1,Arguments.Total))
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
    --Store the arguments.
    local UUID = HttpService:GenerateGUID()
    local Arguments = {
        Arguments = {...},
        Total = select("#",...),
    }
    self.LastArgumentsStrong[UUID] = Arguments
    self.LastArguments[UUID] = Arguments

    --Invoke the event.
    self.BindableEvent:Fire(UUID)
end

--[[
Yields the current thread until this signal
is fired. Returns what was fired to the signal.
--]]
function RobloxEvent:Wait()
    --Wait for the event.
    local UUID = self.BindableEvent.Event:Wait()

    --Return the arguments.
    local Arguments = self.LastArguments[UUID]
    self.LastArgumentsStrong[Arguments] = nil
    return unpack(Arguments.Arguments,1,Arguments.Total)
end



return RobloxEvent