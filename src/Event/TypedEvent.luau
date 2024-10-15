--Typed event with support for table-based payloads.
--!strict

local HttpService = game:GetService("HttpService")

local TypedEventConnection = require(script.Parent:WaitForChild("TypedEventConnection"))

local TypedEvent = {}
TypedEvent.__index = TypedEvent

export type TypedEvent<T...> = {
    BindableEvent: BindableEvent,
    LastArgumentsStrong: {[string]: any},
    LastArguments: {[string]: any},
    Connections: {[TypedEventConnection.TypedEventConnection<T...>]: RBXScriptConnection},
    CurrentWaits: number,
} & typeof(setmetatable({}, TypedEvent))



--[[
Creates a typed event.
--]]
function TypedEvent.new<T...>(): TypedEvent<T...>
    --Create the object.
    --For deferred events, the arguments need to be stored. LastArgumentsStrong will
    --keep the reference around and prevent it from being garbage collected until only
    --LastArguments references it. Ideally, they will be used at the same time if both
    --:Connect(), :Once(), and :Wait() are used.
    local self = setmetatable({
        BindableEvent = Instance.new("BindableEvent"),
        LastArgumentsStrong = {},
        LastArguments = {},
        Connections = {},
        CurrentWaits = 0
    }, TypedEvent) :: TypedEvent<T...>
    setmetatable(self.LastArguments, {__mode="v"})

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
    local Arguments = self.LastArguments[UUID]
    self.LastArgumentsStrong[UUID] = nil
    return table.unpack(Arguments)
end

--[[
Fires the event.
--]]
function TypedEvent.Fire<T...>(self: TypedEvent<T...>, ...: T...): ()
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



return TypedEvent