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



--[[
Test the constructor.
--]]
NexusUnitTesting:RegisterUnitTest("Constructor",function(UnitTest)
	TypePropertyValidator.new("CFrame")
end)

--[[
Tests the Connect method.
--]]
NexusUnitTesting:RegisterUnitTest("Connect",function(UnitTest)
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
	UnitTest:AssertEquals(TestObject.Property1,Property,"Property not set.")
	UnitTest:AssertErrors(function()
		TestObject.Property1 = "Fail"
	end)
	UnitTest:AssertEquals(TestObject.Property1,Property,"Property changed.")
	
	--Assert the Roblox Instance.
	local Property = Instance.new("Part")
	TestObject.Property2 = Property
	UnitTest:AssertEquals(TestObject.Property2,Property,"Property not set.")
	UnitTest:AssertErrors(function()
		TestObject.Property2 = "Fail"
	end)
	UnitTest:AssertEquals(TestObject.Property2,Property,"Property changed.")
	
	--Assert the NexusObject Instance.
	local Property = NexusInstance.new()
	TestObject.Property3 = Property
	UnitTest:AssertEquals(TestObject.Property3,Property,"Property not set.")
	UnitTest:AssertErrors(function()
		TestObject.Property3 = "Fail"
	end)
	UnitTest:AssertEquals(TestObject.Property3,Property,"Property changed.")
end)




--Return true to prevent a ModuleScript error.
return true