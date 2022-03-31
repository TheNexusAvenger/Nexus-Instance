--[[
TheNexusAvenger

Sends and listens to events.
--]]

local HttpService = game:GetService("HttpService")

local NexusObjectFolder = script.Parent.Parent
local NexusObject = require(NexusObjectFolder:WaitForChild("NexusObject"))
local NexusConnection = require(script.Parent:WaitForChild("NexusConnection"))

local NexusEvent = NexusObject:Extend()
NexusEvent:SetClassName("NexusEvent")



--[[
Creates an event.
--]]
function NexusEvent:__new()
    self:InitializeSuper()
    self.Connections = {}
    self.BindableEvent = Instance.new("BindableEvent")
    self.CurrentWaits = 0

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
function NexusEvent:Disconnected(Connection)
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
function NexusEvent:Disconnect()
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
function NexusEvent:Connect(Function)
    --Create the connection.
    local Connection = NexusConnection.new(self,Function)

    --Set up the bindable event.
    local BindableEventConnection = self.BindableEvent.Event:Connect(function(UUID)
        --Get the arguments.
        local Arguments = self.LastArguments[UUID]
        self.LastArgumentsStrong[UUID] = nil

        --Fire the event.
        Connection:Fire(table.unpack(Arguments))
    end)

    --Store the connections.
    self.Connections[Connection] = BindableEventConnection

    --Return the connection.
    return Connection
end


--[[
Fires the event.
--]]
function NexusEvent:Fire(...)
    --Ignore if there are no connections.
    --If continued, self.LastArgumentsStrong will be populated and never cleared, leading to a memory leak.
    if next(self.Connections) == nil and self.CurrentWaits <= 0 then return end

    --Store the arguments.
    local UUID = HttpService:GenerateGUID()
    local Arguments = table.pack(...)
    self.LastArgumentsStrong[UUID] = Arguments
    self.LastArguments[UUID] = Arguments

    --Invoke the event.
    self.BindableEvent:Fire(UUID)
end

--[[
Yields the current thread until this signal
is fired. Returns what was fired to the signal.
--]]
function NexusEvent:Wait()
    --Wait for the event.
    self.CurrentWaits = self.CurrentWaits + 1
    local UUID = self.BindableEvent.Event:Wait()
    self.CurrentWaits = self.CurrentWaits - 1

    --Return the arguments.
    local Arguments = self.LastArguments[UUID]
    self.LastArgumentsStrong[UUID] = nil
    return table.unpack(Arguments)
end



return NexusEvent
