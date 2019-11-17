--[[
TheNexusAvenger

Creates events depending on the preferred event
type and if the platform is Roblox. Extra work
is required to actually make Nexus Instance
work in a non-Roblox environment.
--]]

local USE_NON_ROBLOX_EVENTS = true

local CLASS_NAME = "NexusEventCreator"



local NexusObjectFolder = script.Parent.Parent
local NexusObject = require(NexusObjectFolder:WaitForChild("NexusObject"))
local LuaEvent = require(script.Parent:WaitForChild("LuaEvent"))
local RobloxEvent = require(script.Parent:WaitForChild("RobloxEvent"))

local NexusEventCreator = NexusObject:Extend()
NexusEventCreator:SetClassName(CLASS_NAME)



--[[
Returns if Roblox events should be used.
--]]
function NexusEventCreator:UseRobloxEvents()
	if USE_NON_ROBLOX_EVENTS then
		return false
	else
		return Instance ~= nil
	end
end

--[[
Creates an event.
--]]
function NexusEventCreator:CreateEvent()
	if NexusEventCreator:UseRobloxEvents() then
		return RobloxEvent.new()
	else
		return LuaEvent.new()
	end
end



return NexusEventCreator