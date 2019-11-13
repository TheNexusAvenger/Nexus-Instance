--[[
TheNexusAvenger

Interface for an event.
--]]

local CLASS_NAME = "NexusEvent"



local NexusObjectFolder = script.Parent.Parent
local NexusInterface = require(NexusObjectFolder:WaitForChild("NexusInterface"))
local NexusEvent = NexusInterface:Extend()
NexusEvent:SetClassName(CLASS_NAME)



--[[
Invoked when a connection is disconnected.
--]]
NexusEvent:MustImplement("Disconnected")

--[[
Establishes a function to be called whenever
the event is raised.
--]]
NexusEvent:MustImplement("Connect")

--[[
Disconnects all connected events.
--]]
NexusEvent:MustImplement("Disconnect")

--[[
Fires the event.
--]]
NexusEvent:MustImplement("Fire")

--[[
Yields the current thread until this signal
is fired. Returns what was fired to the signal.
--]]
NexusEvent:MustImplement("Wait")



return NexusEvent