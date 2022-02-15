--[[
TheNexusAvenger

Legacy creator for events.
--]]

warn("NexusEventCreator is deprecated as of V.2.0.0. Use NexusEvent directly instead.")

local NexusObjectFolder = script.Parent.Parent
local NexusObject = require(NexusObjectFolder:WaitForChild("NexusObject"))
local NexusEvent = require(script.Parent:WaitForChild("NexusEvent"))

local NexusEventCreator = NexusObject:Extend()
NexusEventCreator:SetClassName("NexusEventCreator")



--[[
Returns if Roblox events should be used.
--]]
function NexusEventCreator:UseRobloxEvents()
    return true
end

--[[
Creates an event.
--]]
function NexusEventCreator:CreateEvent()
    return NexusEvent.new()
end



return NexusEventCreator