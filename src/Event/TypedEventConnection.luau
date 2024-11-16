--Connection for a typed event.
--!strict

local TypedEventConnection = {}
TypedEventConnection.__index = TypedEventConnection

export type TypedEventStub<T...> = {
    Disconnected: (TypedEventStub<T...>, TypedEventConnection<T...>) -> (),
    [any]: any,
}

export type TypedEventConnection<T...> = {
    Connected: boolean,
    ParentEvent: TypedEventStub<T...>,
    ConnectionFunction: (T...) -> (),
} & typeof(setmetatable({}, TypedEventConnection))



--[[
Creates a connection.
--]]
function TypedEventConnection.new<T...>(ParentEvent: TypedEventStub<T...>, ConnectionFunction: (T...) -> ()): TypedEventConnection<T...>
    return setmetatable({
        Connected = true,
        ParentEvent = ParentEvent,
        ConnectionFunction = ConnectionFunction,
    }, TypedEventConnection) :: TypedEventConnection<T...>
end

--[[
Fires the connection.
--]]
function TypedEventConnection.Fire<T...>(self: TypedEventConnection<T...>, ...: T...): ()
    if not self.Connected then return end
    self.ConnectionFunction(...)
end

--[[
Disconnect the connection from the event.
--]]
function TypedEventConnection.Disconnect<T...>(self: TypedEventConnection<T...>): ()
    --Set the event as disconnected.
    if not self.Connected then return end
    self.Connected = false

    --Remove the connection.
    self.ParentEvent:Disconnected(self)
end

--[[
Destroys the connection.
--]]
function TypedEventConnection.Destroy<T...>(self: TypedEventConnection<T...>): ()
    self:Disconnect()
end



return TypedEventConnection