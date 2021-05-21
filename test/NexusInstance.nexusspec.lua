--[[
TheNexusAvenger

Unit tests for the NexusInstance class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusInstanceFolder = game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance")
local NexusInstanceModule = NexusInstanceFolder:WaitForChild("NexusInstance")

local NexusInstance = require(NexusInstanceModule)
local NexusInstanceTest = NexusUnitTesting.UnitTest:Extend()



--[[
Cleans up the test.
--]]
function NexusInstanceTest:Teardown()
    if self.CuT then
        self.CuT:Destroy()
    end
end

--[[
Test the constructor.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("Constructor"):SetRun(function(self)
    --Create the object.
    self.CuT = NexusInstance.new()
    self.CuT.FalseValue = false
    
    --Run the assertions.
    self:AssertEquals(self.CuT.ClassName,"NexusInstance","ClassName isn't properly set.")
    self:AssertTrue(self.CuT:IsA("NexusInstance"),"IsA isn't properly registering.")
    self:AssertTrue(self.CuT:IsA("NexusObject"),"IsA isn't properly registering.")
    self:AssertTrue(self.CuT.super:IsA("NexusObject"),"IsA isn't properly registering for the super.")
    self:AssertEquals(self.CuT.FalseValue,false,"Property is incorrect.")
    self:AssertSame(self.CuT.object,self.CuT,"object is incorrect.")
    self:AssertSame(self.CuT.super.object,self.CuT,"object is incorrect.")
end))

--[[
Tests the AddPropertyValidator and AddGenericPropertyValidator method.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("AddPropertyValidator"):SetRun(function(self)
    --Create the object.
    self.CuT = NexusInstance.new()

    --Add 3 validators.
    self.CuT:AddPropertyValidator("TestValue",{
        ValidateChange = function(_,Object,Name,Value)
            return Value.."_Value1"
        end,
    })
    self.CuT:AddGenericPropertyValidator({
        ValidateChange = function(_,Object,Name,Value)
            return Value.."_Value2_"..Name
        end,
    })
    self.CuT:AddPropertyValidator("TestValue",{
        ValidateChange = function(_,Object,Name,Value)
            return Value.."_Value3"
        end,
    })

    --Set the values and assert they are correct.
    self.CuT.TestValue = "Test"
    self.CuT.TestValue2 = "Test"
    self:AssertEquals(self.CuT.TestValue,"Test_Value2_TestValue_Value1_Value3")
    self:AssertEquals(self.CuT.TestValue2,"Test_Value2_TestValue2")
end))


--[[
Test the LockProperty function.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("LockProperty"):SetRun(function(self)
    --Create the object.
    self.CuT = NexusInstance.new()
    
    --Create and lock a property.
    self.CuT.TestLock = "Test"
    self.CuT:LockProperty("TestLock")
    
    --Run the assertions.
    self:AssertEquals(self.CuT.TestLock,"Test","TestLock isn't properly set.")
    self:AssertErrors(function()
        self.CuT.TestLock = "Fail"
    end,"Property isn't locked.")
end))

--[[
Test the LockProperty function with a class and subclass.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("LockPropertySubClass"):SetRun(function(self)
    --Extend NexusInstance.
    local TestClass = NexusInstance:Extend()
    
    --Override the constructor.
    function TestClass:__new()
        self:InitializeSuper()
    end
    
    --Create the object.
    self.CuT = TestClass.new()
    
    --Create and lock a property.
    self.CuT.TestLock = "Test"
    self.CuT:LockProperty("TestLock")
    
    --Run the assertions.
    self:AssertEquals(self.CuT.TestLock,"Test","TestLock isn't properly set.")
    self:AssertErrors(function()
        self.CuT.TestLock = "Fail"
    end,"Property isn't locked.")
end))

--[[
Test the HidePropertyChanges function.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("HidePropertyChanges"):SetRun(function(self)
    --Create the object.
    self.CuT = NexusInstance.new()
    
    --Create and lock a property.
    self.CuT.TestHide = "Test"
    self.CuT:HidePropertyChanges("TestHide")
    
    --Set up checking for changes.
    self.CuT.Changed:Connect(function()
        self:Fail("Change registered with hidden property")
    end)
    
    --Change the property.
    self.CuT.TestHide = "Fail"
end))

--[[
Test the HideNextPropertyChange function.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("HideNextPropertyChange"):SetRun(function(self)
    --Create the object.
    self.CuT = NexusInstance.new()
    
    --Set up checking for changes.
    self.CuT.Changed:Connect(function()
        if self.CuT.TestHide == "Fail" then
            self:Fail("Change registered with hidden property")
        elseif self.CuT.TestHide == "Pass" then
            self:Pass()
        end
    end)
    
    --Change the property.
    self.CuT:HideNextPropertyChange("TestHide")
    self.CuT.TestHide = "Fail"
    self.CuT.TestHide = "Pass"
    
    --Fail the unit test if changed wasn't fired.
    wait(1)
    self:Fail("Change not registered.")
end))

--[[
Test the GetPropertyChangedSignal function.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("GetPropertyChangedSignal"):SetRun(function(self)
    --Create the object.
    self.CuT = NexusInstance.new()
    
    --Create and lock a property.
    self.CuT.TestChange = "Test"
    
    --Set up checking for changes.
    self.CuT:GetPropertyChangedSignal("TestChange"):Connect(function()
        self:AssertSame(self.CuT.TestChange,"Pass","Property wasn't changed")
        self:Pass()
    end)
    
    --Change the property.
    self.CuT.TestChange = "Pass"
    
    --Fail the unit test if changed wasn't fired.
    wait(1)
    self:Fail("Change not registered.")
end))

--[[
Test the GetPropertyChangedSignal function after calling HidePropertyChanges.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("GetPropertyChangedSignalHiddenProperty"):SetRun(function(self)
    --Create the object.
    self.CuT = NexusInstance.new()
    
    --Create and lock a property.
    self.CuT.TestChange = "Test"
    
    --Set up checking for changes.
    self.CuT:GetPropertyChangedSignal("TestChange"):Connect(function()
        self:AssertSame(self.CuT.TestChange,"Pass","Property wasn't changed")
        self:Pass()
    end)
    
    --Change the property.
    self.CuT:HidePropertyChanges("TestChange")
    self.CuT.TestChange = "Pass"
    
    --Fail the unit test if changed wasn't fired.
    wait(1)
    self:Fail("Change not registered.")
end))

--[[
Test the Destroy function.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("GetPropertyChangedSignalHiddenProperty"):SetRun(function(self)
    --Create the object.
    self.CuT = NexusInstance.new()
        
    --Create and lock a property.
    self.CuT.TestChange = "Test"

    --Set up checking for changes.
    local TimesCalled1,TimesCalled2 = 0,0
    self.CuT.Changed:Connect(function()
        TimesCalled1 = TimesCalled1 + 1
    end)
    self.CuT:GetPropertyChangedSignal("TestChange"):Connect(function()
        TimesCalled2 = TimesCalled2 + 1
    end)

    --Change the property and assert it was called.
    self.CuT.TestChange = "Test2"
    self:AssertSame(TimesCalled1,1,"Event was not called a correct amount of times.")
    self:AssertSame(TimesCalled2,1,"Event was not called a correct amount of times.")

    --Fail the unit test if changed was fired after destroying.
    self.CuT:Destroy()
    self.CuT.TestChange = "Test3"
    self:AssertSame(TimesCalled1,1,"Event was called after destroying..")
    self:AssertSame(TimesCalled2,1,"Event was called after destroying..")
end))

--[[
Test the Changed event.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("Changed"):SetRun(function(self)
    --Create the object.
    self.CuT = NexusInstance.new()
    
    --Set up checking for changes.
    self.CuT.Changed:Connect(function(Property)
        self:AssertSame(Property,"TestChange","Property name wasn't passed or is incorrect.")
        self:AssertSame(self.CuT.TestChange,"Pass","Property wasn't changed")
        self:Pass()
    end)
    
    --Change the property.
    self.CuT.TestChange = "Pass"
    
    --Fail the unit test if changed wasn't fired.
    wait(1)
    self:Fail("Change not registered.")
end))

--[[
Test the Changed event with a subclass.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("ChangedSubClass"):SetRun(function(self)
    --Extend NexusInstance.
    local TestClass = NexusInstance:Extend()
    
    --Override the constructor.
    function TestClass:__new()
        self:InitializeSuper()
    end
    
    --Create the object.
    self.CuT = TestClass.new()
    
    --Set up checking for changes.
    self.CuT.Changed:Connect(function(Property)
        self:AssertSame(Property,"TestChange","Property name wasn't passed or is incorrect.")
        self:AssertSame(self.CuT.TestChange,"Pass","Property wasn't changed")
        self:Pass()
    end)
    
    --Change the property.
    self.CuT.TestChange = "Pass"
    
    --Fail the unit test if changed wasn't fired.
    wait(1)
    self:Fail("Change not registered.")
end))

--[[
Test the Changed event with a super class.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("ChangedSuperClass"):SetRun(function(self)
    --Extend NexusInstance.
    local TestClass = NexusInstance:Extend()
    
    --Override the constructor.
    function TestClass:__new()
        self:InitializeSuper()
    end
    
    --Create the object.
    self.CuT = TestClass.new()
    
    --Set up checking for changes.
    self.CuT.super.Changed:Connect(function(Property)
        self:AssertSame(Property,"TestChange","Property name wasn't passed or is incorrect.")
        self:AssertSame(self.CuT.super.TestChange,"Pass","Property wasn't changed")
        self:Pass()
    end)
    
    --Change the property.
    self.CuT.TestChange = "Pass"
    
    --Fail the unit test if changed wasn't fired.
    wait(1)
    self:Fail("Change not registered.")
end))

--[[
Test extending twice.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInstanceTest.new("DoubleExtends"):SetRun(function(self)
    --Extend the NexusInstance class.
    local ExtendedObject1 = NexusInstance:Extend()
    ExtendedObject1:SetClassName("ExtendedClass1")
    
    --Override the constructor.
    function ExtendedObject1:__new()
        self:InitializeSuper()
        self.TestProperty = "Test"
    end
    
    --Extend the ExtendedObject1 class.
    local ExtendedObject2 = ExtendedObject1:Extend()
    ExtendedObject2:SetClassName("ExtendedClass2")
    
    --Override the constructor.
    function ExtendedObject2:__new()
        self:InitializeSuper()
    end
    
    --Create the object.
    self.CuT = ExtendedObject2.new()
    
    --Run the assertions.
    self:AssertEquals(self.CuT.ClassName,"ExtendedClass2","ClassName isn't properly set.")
    self:AssertNotNil(self.CuT.super,"Super isn't initialized.")
    self:AssertTrue(self.CuT:IsA("ExtendedClass2"),"IsA isn't properly registering.")
    self:AssertTrue(self.CuT:IsA("ExtendedClass1"),"IsA returns incorrectly with the super class initialized.")
    self:AssertTrue(self.CuT:IsA("NexusObject"),"IsA returns incorrectly with the super class initialized.")
    self:AssertEquals(self.CuT.TestProperty,"Test","Super class property isn't properly set.")
end))



--Return true to prevent a ModuleScript error.
return true