--[[
TheNexusAvenger

Unit tests for the NexusConnection class.
--]]
local NexusUnitTesting = require("NexusUnitTesting")

local NexusInstanceFolder = game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance")
local EventFolder = NexusInstanceFolder:WaitForChild("Event")
local NexusConnectionModule = EventFolder:WaitForChild("NexusConnection")

local NexusConnection = require(NexusConnectionModule)
local NexusConnectionTest = NexusUnitTesting.UnitTest:Extend()

--[[
Creates a mock event.
--]]
local function CreateMockEvent()
    return {
        Disconnected = function() end
    }
end



--[[
Test the constructor.
--]]
NexusUnitTesting:RegisterUnitTest(NexusConnectionTest.new("Constructor"):SetRun(function(self)
    --Create the object.
    local CuT = NexusConnection.new(CreateMockEvent(),function() end)
    
    --Run the assertions.
    self:AssertEquals(CuT.ClassName,"NexusConnection","ClassName isn't properly set.")
    self:AssertTrue(CuT:IsA("NexusConnection"),"IsA isn't properly registering.")
    self:AssertTrue(CuT:IsA("NexusObject"),"IsA isn't properly registering.")
    self:AssertTrue(CuT.Connected,"Event is not initially connected.")
end))

--[[
Test the Fire function.
--]]
NexusUnitTesting:RegisterUnitTest(NexusConnectionTest.new("Fire"):SetRun(function(self)
    --Create the test function.
    local InvokeResult1,InvokeResult2,InvokeResult3
    local function Invoke(Result1,Result2,Result3)
        InvokeResult1 = Result1
        InvokeResult2 = Result2
        InvokeResult3 = Result3
    end
    
    --Create the object.
    local CuT = NexusConnection.new(CreateMockEvent(),Invoke)
    
    --Run the assertions.
    CuT:Fire(1,2,3)
    self:AssertEquals(InvokeResult1,1,"Result is incorrect.")
    self:AssertEquals(InvokeResult2,2,"Result is incorrect.")
    self:AssertEquals(InvokeResult3,3,"Result is incorrect.")
end))

--[[
Test the Disconnect function.
--]]
NexusUnitTesting:RegisterUnitTest(NexusConnectionTest.new("Disconnect"):SetRun(function(self)
    --Create the test function.
    local InvokeResult1,InvokeResult2,InvokeResult3
    local function Invoke(Result1,Result2,Result3)
        InvokeResult1 = Result1
        InvokeResult2 = Result2
        InvokeResult3 = Result3
    end
    
    --Create the object.
    local CuT = NexusConnection.new(CreateMockEvent(),Invoke)
    
    --Run the assertions.
    CuT:Fire(1,2,3)
    self:AssertEquals(InvokeResult1,1,"Result is incorrect.")
    self:AssertEquals(InvokeResult2,2,"Result is incorrect.")
    self:AssertEquals(InvokeResult3,3,"Result is incorrect.")
    
    --Disconnect the event.
    CuT:Disconnect()
    self:AssertFalse(CuT.Connected,"Connection still connected.")
    
    --Run the assertions.
    CuT:Fire(4,5,6)
    self:AssertEquals(InvokeResult1,1,"Result is incorrect.")
    self:AssertEquals(InvokeResult2,2,"Result is incorrect.")
    self:AssertEquals(InvokeResult3,3,"Result is incorrect.")
end))



--Return true to prevent a ModuleScript error.
return true