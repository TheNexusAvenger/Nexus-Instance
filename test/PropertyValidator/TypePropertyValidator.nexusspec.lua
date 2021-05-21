--[[
TheNexusAvenger

Unit tests for the TypePropertyValidator class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusInstanceFolder = game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance")
local NexusInstanceModule = NexusInstanceFolder:WaitForChild("NexusInstance")
local PropertyValidatorFolder = NexusInstanceFolder:WaitForChild("PropertyValidator")
local TypePropertyValidatorModule = PropertyValidatorFolder:WaitForChild("TypePropertyValidator")

local NexusInstance = require(NexusInstanceModule)
local TypePropertyValidator = require(TypePropertyValidatorModule)
local TypePropertyValidatorTest = NexusUnitTesting.UnitTest:Extend()



--[[
Tests the Connect method.
--]]
NexusUnitTesting:RegisterUnitTest(TypePropertyValidatorTest.new("Connect"):SetRun(function(self)
    --Create the object.
    local CuT1 = TypePropertyValidator.new("CFrame")
    local CuT2 = TypePropertyValidator.new("BasePart")
    local CuT3 = TypePropertyValidator.new("NexusObject")
    
    --Create the instance.
    local TestObject = NexusInstance.new()
    TestObject:AddPropertyValidator("Property1",CuT1)
    TestObject:AddPropertyValidator("Property2",CuT2)
    TestObject:AddPropertyValidator("Property3",CuT3)
    
    --Assert the Roblox type.
    local Property = CFrame.new()
    TestObject.Property1 = Property
    self:AssertEquals(TestObject.Property1,Property,"Property not set.")
    self:AssertErrors(function()
        TestObject.Property1 = "Fail"
    end)
    self:AssertEquals(TestObject.Property1,Property,"Property changed.")
    
    --Assert the Roblox Instance.
    Property = Instance.new("Part")
    TestObject.Property2 = Property
    self:AssertEquals(TestObject.Property2,Property,"Property not set.")
    self:AssertErrors(function()
        TestObject.Property2 = "Fail"
    end)
    self:AssertEquals(TestObject.Property2,Property,"Property changed.")
    
    --Assert the NexusObject Instance.
    Property = NexusInstance.new()
    TestObject.Property3 = Property
    self:AssertEquals(TestObject.Property3,Property,"Property not set.")
    self:AssertErrors(function()
        TestObject.Property3 = "Fail"
    end)
    self:AssertEquals(TestObject.Property3,Property,"Property changed.")
end))



--Return true to prevent a ModuleScript error.
return true