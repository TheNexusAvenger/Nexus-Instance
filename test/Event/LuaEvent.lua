--[[
TheNexusAvenger

Unit tests for the LuaEvent class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusInstanceFolder = game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance")
local EventFolder = NexusInstanceFolder:WaitForChild("Event")
local LuaEventModule = EventFolder:WaitForChild("LuaEvent")

local LuaEvent = require(LuaEventModule)



--[[
Test the constructor.
--]]
NexusUnitTesting:RegisterUnitTest("Constructor",function(UnitTest)
	--Create the object.
	local CuT = LuaEvent.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.ClassName,"LuaEvent","ClassName isn't properly set.")
	UnitTest:AssertTrue(CuT:IsA("NexusEvent"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(CuT:IsA("NexusObject"),"IsA isn't properly registering.")
end)

--[[
Tests the Connect method.
--]]
NexusUnitTesting:RegisterUnitTest("Connect",function(UnitTest)
	--Create the object.
	local CuT = LuaEvent.new()
	
	--Create the incrementer function.
	local TimesInvoked = 0
	local function Invoked()
		TimesInvoked = TimesInvoked + 1
	end
	
	--Create 3 connections.
	local Connection1 = CuT:Connect(Invoked)
	local Connection2 = CuT:Connect(Invoked)
	local Connection3 = CuT:Connect(Invoked)
	
	--Run the assertions.
	UnitTest:AssertTrue(Connection1:IsA("NexusConnection"),"Connection class is incorrect.")
	CuT:Fire()
	UnitTest:AssertEquals(TimesInvoked,3,"Event not fired the correct amount of times.")
	CuT:Fire()
	UnitTest:AssertEquals(TimesInvoked,6,"Event not fired the correct amount of times.")
end)

--[[
Tests the Disconnected method.
--]]
NexusUnitTesting:RegisterUnitTest("Disconnected",function(UnitTest)
	--Create the object.
	local CuT = LuaEvent.new()
	
	--Create the incrementer function.
	local TimesInvoked = 0
	local function Invoked()
		TimesInvoked = TimesInvoked + 1
	end
	
	--Create 3 connections.
	local Connection1 = CuT:Connect(Invoked)
	local Connection2 = CuT:Connect(Invoked)
	local Connection3 = CuT:Connect(Invoked)
	
	--Run the assertions.
	CuT:Fire()
	UnitTest:AssertEquals(TimesInvoked,3,"Event not fired the correct amount of times.")
	Connection1:Disconnect()
	CuT:Fire()
	UnitTest:AssertEquals(TimesInvoked,5,"Event not fired the correct amount of times.")
	Connection2:Disconnect()
	CuT:Fire()
	UnitTest:AssertEquals(TimesInvoked,6,"Event not fired the correct amount of times.")
	Connection3:Disconnect()
	CuT:Fire()
	UnitTest:AssertEquals(TimesInvoked,6,"Event not fired the correct amount of times.")
end)

--[[
Tests the Fire method.
--]]
NexusUnitTesting:RegisterUnitTest("Fire",function(UnitTest)
	--Create the object.
	local CuT = LuaEvent.new()
	
	--Create the incrementer function.
	local InvokeA,InvokeB,InvokeC
	local function Invoked(A,B,C)
		InvokeA,InvokeB,InvokeC = A,B,C
	end
	
	--Create a connection.
	local Connection = CuT:Connect(Invoked)
	
	--Run the assertions.
	CuT:Fire(1,2,3)
	UnitTest:AssertEquals(InvokeA,1,"Parameter not fired.")
	UnitTest:AssertEquals(InvokeB,2,"Parameter not fired.")
	UnitTest:AssertEquals(InvokeC,3,"Parameter not fired.")
end)

--[[
Tests the Disconnect method.
--]]
NexusUnitTesting:RegisterUnitTest("Disconnect",function(UnitTest)
	--Create the object.
	local CuT = LuaEvent.new()
	
	--Create the incrementer function.
	local TimesInvoked = 0
	local function Invoked()
		TimesInvoked = TimesInvoked + 1
	end
	
	--Create 3 connections.
	local Connection1 = CuT:Connect(Invoked)
	local Connection2 = CuT:Connect(Invoked)
	local Connection3 = CuT:Connect(Invoked)
	
	--Run the assertions.
	CuT:Fire()
	UnitTest:AssertEquals(TimesInvoked,3,"Event not fired the correct amount of times.")
	CuT:Disconnect()
	CuT:Fire()
	UnitTest:AssertEquals(TimesInvoked,3,"Event not fired the correct amount of times.")
end)

--[[
Tests the Wait method.
--]]
NexusUnitTesting:RegisterUnitTest("Wait",function(UnitTest)
	--Create the object.
	local CuT = LuaEvent.new()
	
	--Create the incrementer function.
	coroutine.wrap(function()
		wait(0.1)
		CuT:Fire(1,2,3)
	end)()
	
	--Wait for the event to be fired.
	local InvokeA,InvokeB,InvokeC = CuT:Wait()
	
	--Run the assertions.
	UnitTest:AssertEquals(InvokeA,1,"Parameter not fired.")
	UnitTest:AssertEquals(InvokeB,2,"Parameter not fired.")
	UnitTest:AssertEquals(InvokeC,3,"Parameter not fired.")
end)



--Return true to prevent a ModuleScript error.
return true