--[[
TheNexusAvenger

Represents an event connection.
--]]
--!strict

local NexusObjectFolder = script.Parent.Parent
local NexusObject = require(NexusObjectFolder:WaitForChild("NexusObject"))
local NexusConnection = NexusObject:Extend()
NexusConnection:SetClassName("NexusConnection")

export type NexusConnectionEvent<T...> = {
    Disconnected: (NexusConnectionEvent<T...>) -> (),
    [string]: any,
}
export type NexusConnection<T...> = {
    new: (Event: NexusConnectionEvent<T...>, ConnectionFunction: (T...) -> ()) -> (NexusConnection<T...>),
    Extend: (self: NexusConnection<T...>) -> (NexusConnection<T...>),

    Connected: boolean,
    Fire: (NexusConnectionEvent<T...>, T...) -> (),
    Disconnect: () -> (),
} & NexusObject.NexusObject



--[[
Creates an instance of the connection.
--]]
function NexusConnection:__new<T...>(Event: NexusConnectionEvent<T...>, ConnectionFunction): ()
    NexusObject.__new(self)
    self.Event = Event
    self.ConnectionFunction = ConnectionFunction
    self.Connected = true
end

--[[
Fires the connection.
--]]
function NexusConnection:Fire<T>(...: T): ()
    if self.Connected then
        self.ConnectionFunction(...)
    end
end

--[[
Disconnects the connection from the event.
--]]
function NexusConnection:Disconnect(): ()
    if self.Connected then
        self.Connected = false
        if self.Event then
            self.Event:Disconnected(self)
        end
    end
end



return NexusConnection :: NexusConnection<>