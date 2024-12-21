--Typed event with support for table-based payloads.
--!strict

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local TypedEventConnection = require(script.Parent:WaitForChild("TypedEventConnection"))

local TypedEvent = {}
TypedEvent.LastArguments = {} :: {[string]: any}
TypedEvent.QueuedClearArguments = {} :: {[string]: boolean}
TypedEvent.__index = TypedEvent

export type TypedEvent<T...> = {
    BindableEvent: BindableEvent,
    Connections: {[TypedEventConnection.TypedEventConnection<T...>]: RBXScriptConnection},
    CurrentWaits: number,
} & typeof(setmetatable({}, TypedEvent))



--[[
Creates a typed event.
--]]
function TypedEvent.new<T...>(): TypedEvent<T...>
    --Create the object.
    local self = setmetatable({
        BindableEvent = Instance.new("BindableEvent"),
        Connections = {},
        CurrentWaits = 0
    }, TypedEvent) :: TypedEvent<T...>

    --Return the object.
    return self
end

--[[
Establishes a function to be called when the event fires.
Returns a connection object that can be disconnected.
--]]
function TypedEvent.Connect<T...>(self: TypedEvent<T...>, Callback: (T...) -> ()): TypedEventConnection.TypedEventConnection<T...>
    --Create the connection.
    local Connection = TypedEventConnection.new(self :: any, Callback)

    --Set up the bindable event.
    local BindableEventConnection = self.BindableEvent.Event:Connect(function(UUID)
        Connection:Fire(table.unpack(self.LastArguments[UUID]))
    end)

    --Store the connections.
    self.Connections[Connection] = BindableEventConnection

    --Return the connection.
    return Connection
end

--[[
Establishes a function to be called when the event fires.
Returns a connection object that can be disconnected.
However, instead of allowing multiple events to be received by the specified function,
only the first event will be delivered. Using Once also ensures that the connection to
the function will be automatically disconnected prior the function being called.
--]]
function TypedEvent.Once<T...>(self: TypedEvent<T...>, Callback: (T...) -> ()): ()
    local Connection = nil
    Connection = self:Connect(function(...)
        if Connection then
            Connection:Disconnect()
        end
        Callback(...)
    end)
end

--[[
Yields the current thread until the signal fires and returns the arguments provided by the signal.
--]]
function TypedEvent.Wait<T...>(self: TypedEvent<T...>): T...
    --Wait for the event.
    self.CurrentWaits = self.CurrentWaits + 1
    local UUID = self.BindableEvent.Event:Wait()
    self.CurrentWaits = self.CurrentWaits - 1

    --Return the arguments.
    return table.unpack(self.LastArguments[UUID])
end

--[[
Fires the event.
--]]
function TypedEvent.Fire<T...>(self: TypedEvent<T...>, ...: T...): ()
    --Ignore if there are no connections.
    if next(self.Connections) == nil and self.CurrentWaits <= 0 then return end

    --Store the arguments.
    --For deferred events, the arguments need to be stored.
    local UUID = HttpService:GenerateGUID()
    local Arguments = table.pack(...)
    self.LastArguments[UUID] = Arguments

    --Queue clearing the arguments.
    task.defer(function()
        TypedEvent.QueuedClearArguments[UUID] = true
    end)

    --Invoke the event.
    self.BindableEvent:Fire(UUID)
end

--[[
Handles an event being disconnected.
--]]
function TypedEvent.Disconnected<T...>(self: TypedEvent<T...>, Connection: TypedEventConnection.TypedEventConnection<T...>): ()
    if not self.Connections[Connection] then return end
    self.Connections[Connection]:Disconnect()
    self.Connections[Connection] = nil
end

--[[
Destroys the event.
--]]
function TypedEvent.Destroy<T...>(self: TypedEvent<T...>): ()
    local OriginalConnections = self.Connections
    self.Connections = {}
    self.CurrentWaits = 0
    for Connection, _ in OriginalConnections do
        (Connection :: TypedEventConnection.TypedEventConnection<T...>):Disconnect()
    end
    self.BindableEvent:Destroy()
end



--Clear arguments in the background.
RunService.Heartbeat:Connect(function()
    local QueuedClearArguments = TypedEvent.QueuedClearArguments
    TypedEvent.QueuedClearArguments = {}

    for Key, _ in QueuedClearArguments do
        TypedEvent.LastArguments[Key] = nil
    end
end)



return TypedEvent