--[[
TheNexusAvenger

Unit tests for the LuaEvent class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusInstanceFolder = game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance")
local EventFolder = NexusInstanceFolder:WaitForChild("Event")
local LuaEventModule = EventFolder:WaitForChild("LuaEvent")

local LuaEvent = require(LuaEventModule)
local LuaEventTest = NexusUnitTesting.UnitTest:Extend()



--[[
Sets up the test.
--]]
function LuaEventTest:Setup()
    self.CuT = LuaEvent.new()
end

--[[
Cleans up the test.
--]]
function LuaEventTest:Teardown()
    self.CuT:Disconnect()
end

--[[
Test the constructor.
--]]
NexusUnitTesting:RegisterUnitTest(LuaEventTest.new("Constructor"):SetRun(function(self)
    --Run the assertions.
    self:AssertEquals(self.CuT.ClassName,"LuaEvent","ClassName isn't properly set.")
    self:AssertTrue(self.CuT:IsA("NexusEvent"),"IsA isn't properly registering.")
    self:AssertTrue(self.CuT:IsA("NexusObject"),"IsA isn't properly registering.")
end))

--[[
Tests the Connect method.
--]]
NexusUnitTesting:RegisterUnitTest(LuaEventTest.new("Connect"):SetRun(function(self)
    --Create the incrementer function.
    local TimesInvoked = 0
    local function Invoked()
        TimesInvoked = TimesInvoked + 1
    end
    
    --Create 3 connections.
    local Connection1 = self.CuT:Connect(Invoked)
    local Connection2 = self.CuT:Connect(Invoked)
    local Connection3 = self.CuT:Connect(Invoked)
    
    --Run the assertions.
    self:AssertTrue(Connection1:IsA("NexusConnection"),"Connection class is incorrect.")
    self.CuT:Fire()
    self:AssertEquals(TimesInvoked,3,"Event not fired the correct amount of times.")
    self.CuT:Fire()
    self:AssertEquals(TimesInvoked,6,"Event not fired the correct amount of times.")
end))

--[[
Tests the Disconnected method.
--]]
NexusUnitTesting:RegisterUnitTest(LuaEventTest.new("Disconnected"):SetRun(function(self)
    --Create the incrementer function.
    local TimesInvoked = 0
    local function Invoked()
        TimesInvoked = TimesInvoked + 1
    end
    
    --Create 3 connections.
    local Connection1 = self.CuT:Connect(Invoked)
    local Connection2 = self.CuT:Connect(Invoked)
    local Connection3 = self.CuT:Connect(Invoked)
    
    --Run the assertions.
    self.CuT:Fire()
    self:AssertEquals(TimesInvoked,3,"Event not fired the correct amount of times.")
    Connection1:Disconnect()
    self.CuT:Fire()
    self:AssertEquals(TimesInvoked,5,"Event not fired the correct amount of times.")
    Connection2:Disconnect()
    self.CuT:Fire()
    self:AssertEquals(TimesInvoked,6,"Event not fired the correct amount of times.")
    Connection3:Disconnect()
    self.CuT:Fire()
    self:AssertEquals(TimesInvoked,6,"Event not fired the correct amount of times.")
end))

--[[
Tests the Fire method.
--]]
NexusUnitTesting:RegisterUnitTest(LuaEventTest.new("Fire"):SetRun(function(self)
    --Create the incrementer function.
    local InvokeA,InvokeB,InvokeC
    local function Invoked(A,B,C)
        InvokeA,InvokeB,InvokeC = A,B,C
    end
    
    --Create a connection.
    local Connection = self.CuT:Connect(Invoked)
    
    --Run the assertions.
    self.CuT:Fire(1,2,3)
    self:AssertEquals(InvokeA,1,"Parameter not fired.")
    self:AssertEquals(InvokeB,2,"Parameter not fired.")
    self:AssertEquals(InvokeC,3,"Parameter not fired.")
end))

--[[
Tests the Fire method with missing arguments.
--]]
NexusUnitTesting:RegisterUnitTest(LuaEventTest.new("Fire"):SetRun(function(self)
    --Create the incrementer function.
    local InvokeA,InvokeB,InvokeC
    local function Invoked(A,B,C)
        InvokeA,InvokeB,InvokeC = A,B,C
    end
    
    --Create a connection.
    local Connection = self.CuT:Connect(Invoked)
    
    --Run the assertions.
    self.CuT:Fire(1,nil,3)
    self:AssertEquals(InvokeA,1,"Parameter not fired.")
    self:AssertEquals(InvokeB,nil,"Parameter not fired.")
    self:AssertEquals(InvokeC,3,"Parameter not fired.")
end))

--[[
Tests the Fire method in a loop.
--]]
NexusUnitTesting:RegisterUnitTest(LuaEventTest.new("FireLoop"):SetRun(function(self)
    --Create the incrementer function.
    local Sum = 0
    local function Invoked(Value)
        Sum = Sum + Value
    end
    
    --Create a connection.
    local Connection = self.CuT:Connect(Invoked)

    --Fire using coroutines.
    for i = 1,10 do
        coroutine.wrap(function()
            self.CuT:Fire(i)
        end)()
    end
    
    --Run the assertions.
    self:AssertEquals(Sum,1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10,"Not all parameters passed")
end))

--[[
Tests the Fire method with a table to ensure no re-encoding is done.
--]]
NexusUnitTesting:RegisterUnitTest(LuaEventTest.new("FireTable"):SetRun(function(self)
    --Create the incrementer function.
    local InvokeA,InvokeB
    local TableA,TableB = {1,2,3},{1,2,3}
    local function Invoked(A,B)
        InvokeA,InvokeB = A,B
    end
    
    --Create a connection.
    local Connection = self.CuT:Connect(Invoked)
    
    --Run the assertions.
    self.CuT:Fire(TableA,TableB)
    self:AssertSame(InvokeA,TableA,"Parameter not the same.")
    self:AssertSame(InvokeB,TableB,"Parameter not the same.")
    self:AssertNotSame(InvokeA,InvokeB,"Invoked properties are the same.")
end))

--[[
Tests the Disconnect method.
--]]
NexusUnitTesting:RegisterUnitTest(LuaEventTest.new("Disconnect"):SetRun(function(self)
    --Create the incrementer function.
    local TimesInvoked = 0
    local function Invoked()
        TimesInvoked = TimesInvoked + 1
    end
    
    --Create 3 connections.
    local Connection1 = self.CuT:Connect(Invoked)
    local Connection2 = self.CuT:Connect(Invoked)
    local Connection3 = self.CuT:Connect(Invoked)
    
    --Run the assertions.
    self.CuT:Fire()
    self:AssertEquals(TimesInvoked,3,"Event not fired the correct amount of times.")
    self.CuT:Disconnect()
    self.CuT:Fire()
    self:AssertEquals(TimesInvoked,3,"Event not fired the correct amount of times.")
end))

--[[
Tests the Wait method.
--]]
NexusUnitTesting:RegisterUnitTest(LuaEventTest.new("Wait"):SetRun(function(self)
    --Create the incrementer function.
    coroutine.wrap(function()
        wait(0.1)
        self.CuT:Fire(1,2,3)
    end)()
    
    --Wait for the event to be fired.
    local InvokeA,InvokeB,InvokeC = self.CuT:Wait()
    
    --Run the assertions.
    self:AssertEquals(InvokeA,1,"Parameter not fired.")
    self:AssertEquals(InvokeB,2,"Parameter not fired.")
    self:AssertEquals(InvokeC,3,"Parameter not fired.")
end))



--Return true to prevent a ModuleScript error.
return true