--[[
TheNexusAvenger

Unit tests for the NexusInstance class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local Sources = game:GetService("ReplicatedStorage"):WaitForChild("Sources")
local NexusInstanceFolder = Sources:WaitForChild("NexusInstance")
local NexusInstanceModule = NexusInstanceFolder:WaitForChild("NexusInstance")

local NexusInstance = require(NexusInstanceModule)



--[[
Test the constructor.
--]]
NexusUnitTesting:RegisterUnitTest("Constructor",function(UnitTest)
	--Create the object.
	local CuT = NexusInstance.new()
	CuT.FalseValue = false
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.ClassName,"NexusInstance","ClassName isn't properly set.")
	UnitTest:AssertTrue(CuT:IsA("NexusInstance"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(CuT:IsA("NexusObject"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(CuT.super:IsA("NexusObject"),"IsA isn't properly registering for the super.")
	UnitTest:AssertEquals(CuT.FalseValue,false,"Property is incorrect.")
	UnitTest:AssertSame(CuT.object,CuT,"object is incorrect.")
	UnitTest:AssertSame(CuT.super.object,CuT,"object is incorrect.")
end)

--[[
Test the LockProperty function.
--]]
NexusUnitTesting:RegisterUnitTest("LockProperty",function(UnitTest)
	--Create the object.
	local CuT = NexusInstance.new()
	
	--Create and lock a property.
	CuT.TestLock = "Test"
	CuT:LockProperty("TestLock")
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.TestLock,"Test","TestLock isn't properly set.")
	UnitTest:AssertErrors(function()
		CuT.TestLock = "Fail"
	end,"Property isn't locked.")
end)

--[[
Test the LockProperty function with a class and subclass.
--]]
NexusUnitTesting:RegisterUnitTest("LockPropertySubClass",function(UnitTest)
	--Extend NexusInstance.
	local TestClass = NexusInstance:Extend()
	
	--Override the constructor.
	function TestClass:__new()
		self:InitializeSuper()
	end
	
	--Create the object.
	local CuT = TestClass.new()
	
	--Create and lock a property.
	CuT.TestLock = "Test"
	CuT:LockProperty("TestLock")
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.TestLock,"Test","TestLock isn't properly set.")
	UnitTest:AssertErrors(function()
		CuT.TestLock = "Fail"
	end,"Property isn't locked.")
end)

--[[
Test the HidePropertyChanges function.
--]]
NexusUnitTesting:RegisterUnitTest("HidePropertyChanges",function(UnitTest)
	--Create the object.
	local CuT = NexusInstance.new()
	
	--Create and lock a property.
	CuT.TestHide = "Test"
	CuT:HidePropertyChanges("TestHide")
	
	--Set up checking for changes.
	CuT.Changed:Connect(function()
		UnitTest:Fail("Change registered with hidden property")
	end)
	
	--Change the property.
	CuT.TestHide = "Fail"
end)

--[[
Test the HideNextPropertyChange function.
--]]
NexusUnitTesting:RegisterUnitTest("HideNextPropertyChange",function(UnitTest)
	--Create the object.
	local CuT = NexusInstance.new()
	
	--Set up checking for changes.
	CuT.Changed:Connect(function()
		if CuT.TestHide == "Fail" then
			UnitTest:Fail("Change registered with hidden property")
		elseif CuT.TestHide == "Pass" then
			UnitTest:Pass()
		end
	end)
	
	--Change the property.
	CuT:HideNextPropertyChange("TestHide")
	CuT.TestHide = "Fail"
	CuT.TestHide = "Pass"
	
	--Fail the unit test if changed wasn't fired.
	wait(1)
	UnitTest:Fail("Change not registered.")
end)

--[[
Test the GetPropertyChangedSignal function.
--]]
NexusUnitTesting:RegisterUnitTest("GetPropertyChangedSignal",function(UnitTest)
	--Create the object.
	local CuT = NexusInstance.new()
	
	--Create and lock a property.
	CuT.TestChange = "Test"
	
	--Set up checking for changes.
	CuT:GetPropertyChangedSignal("TestChange"):Connect(function()
		UnitTest:AssertSame(CuT.TestChange,"Pass","Property wasn't changed")
		UnitTest:Pass()
	end)
	
	--Change the property.
	CuT.TestChange = "Pass"
	
	--Fail the unit test if changed wasn't fired.
	wait(1)
	UnitTest:Fail("Change not registered.")
end)

--[[
Test the GetPropertyChangedSignal function after calling HidePropertyChanges.
--]]
NexusUnitTesting:RegisterUnitTest("GetPropertyChangedSignalHiddenProperty",function(UnitTest)
	--Create the object.
	local CuT = NexusInstance.new()
	
	--Create and lock a property.
	CuT.TestChange = "Test"
	
	--Set up checking for changes.
	CuT:GetPropertyChangedSignal("TestChange"):Connect(function()
		UnitTest:AssertSame(CuT.TestChange,"Pass","Property wasn't changed")
		UnitTest:Pass()
	end)
	
	--Change the property.
	CuT:HidePropertyChanges("TestChange")
	CuT.TestChange = "Pass"
	
	--Fail the unit test if changed wasn't fired.
	wait(1)
	UnitTest:Fail("Change not registered.")
end)

--[[
Test the Changed event.
--]]
NexusUnitTesting:RegisterUnitTest("Changed",function(UnitTest)
	--Create the object.
	local CuT = NexusInstance.new()
	
	--Set up checking for changes.
	CuT.Changed:Connect(function(Property)
		UnitTest:AssertSame(Property,"TestChange","Property name wasn't passed or is incorrect.")
		UnitTest:AssertSame(CuT.TestChange,"Pass","Property wasn't changed")
		UnitTest:Pass()
	end)
	
	--Change the property.
	CuT.TestChange = "Pass"
	
	--Fail the unit test if changed wasn't fired.
	wait(1)
	UnitTest:Fail("Change not registered.")
end)

--[[
Test the Changed event with a subclass.
--]]
NexusUnitTesting:RegisterUnitTest("ChangedSubClass",function(UnitTest)
	--Extend NexusInstance.
	local TestClass = NexusInstance:Extend()
	
	--Override the constructor.
	function TestClass:__new()
		self:InitializeSuper()
	end
	
	--Create the object.
	local CuT = TestClass.new()
	
	--Set up checking for changes.
	CuT.Changed:Connect(function(Property)
		UnitTest:AssertSame(Property,"TestChange","Property name wasn't passed or is incorrect.")
		UnitTest:AssertSame(CuT.TestChange,"Pass","Property wasn't changed")
		UnitTest:Pass()
	end)
	
	--Change the property.
	CuT.TestChange = "Pass"
	
	--Fail the unit test if changed wasn't fired.
	wait(1)
	UnitTest:Fail("Change not registered.")
end)

--[[
Test the Changed event with a super class.
--]]
NexusUnitTesting:RegisterUnitTest("ChangedSuperClass",function(UnitTest)
	--Extend NexusInstance.
	local TestClass = NexusInstance:Extend()
	
	--Override the constructor.
	function TestClass:__new()
		self:InitializeSuper()
	end
	
	--Create the object.
	local CuT = TestClass.new()
	
	--Set up checking for changes.
	CuT.super.Changed:Connect(function(Property)
		UnitTest:AssertSame(Property,"TestChange","Property name wasn't passed or is incorrect.")
		UnitTest:AssertSame(CuT.super.TestChange,"Pass","Property wasn't changed")
		UnitTest:Pass()
	end)
	
	--Change the property.
	CuT.TestChange = "Pass"
	
	--Fail the unit test if changed wasn't fired.
	wait(1)
	UnitTest:Fail("Change not registered.")
end)

--[[
Test extending twice.
--]]
NexusUnitTesting:RegisterUnitTest("DoubleExtends",function(UnitTest)
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
	local CuT = ExtendedObject2.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.ClassName,"ExtendedClass2","ClassName isn't properly set.")
	UnitTest:AssertNotNil(CuT.super,"Super isn't initialized.")
	UnitTest:AssertTrue(CuT:IsA("ExtendedClass2"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(CuT:IsA("ExtendedClass1"),"IsA returns incorrectly with the super class initialized.")
	UnitTest:AssertTrue(CuT:IsA("NexusObject"),"IsA returns incorrectly with the super class initialized.")
	UnitTest:AssertEquals(CuT.TestProperty,"Test","Super class property isn't properly set.")
end)



--Return true to prevent a ModuleScript error.
return true