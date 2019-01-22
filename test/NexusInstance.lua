--[[
TheNexusAvenger

Unit tests for the NexusInstance class.
--]]
local NexusUnitTesting = require("NexusUnitTesting")

local Sources = game:GetService("ReplicatedStorage"):WaitForChild("Sources")
local NexusObjectFolder = Sources:WaitForChild("NexusObject")
local NexusInstanceModule = NexusObjectFolder:WaitForChild("NexusInstance")

--[[
Test the constructor.
--]]
NexusUnitTesting:RegisterUnitTest("Constructor",function(UnitTest)
	local NexusInstance = require(NexusInstanceModule)
	
	--Create the object.
	local CuT = NexusInstance.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.ClassName,"NexusInstance","ClassName isn't properly set.")
	UnitTest:AssertTrue(CuT:IsA("NexusInstance"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(CuT:IsA("NexusObject"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(CuT.super:IsA("NexusObject"),"IsA isn't properly registering for the super.")
end)

--[[
Test the LockProperty function.
--]]
NexusUnitTesting:RegisterUnitTest("LockProperty",function(UnitTest)
	local NexusInstance = require(NexusInstanceModule)
	
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
	local NexusInstance = require(NexusInstanceModule)
	
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
	local NexusInstance = require(NexusInstanceModule)
	
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
	local NexusInstance = require(NexusInstanceModule)
	
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
	local NexusInstance = require(NexusInstanceModule)
	
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
	local NexusInstance = require(NexusInstanceModule)
	
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
	local NexusInstance = require(NexusInstanceModule)
	
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
	local NexusInstance = require(NexusInstanceModule)
	
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
	local NexusInstance = require(NexusInstanceModule)
	
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



--Return true to prevent a ModuleScript error.
return true