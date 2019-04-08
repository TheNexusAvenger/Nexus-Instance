--[[
TheNexusAvenger

Unit tests for the NexusInterface class.
--]]
local NexusUnitTesting = require("NexusUnitTesting")

local Sources = game:GetService("ReplicatedStorage"):WaitForChild("Sources")
local NexusObjectFolder = Sources:WaitForChild("NexusObject")
local NexusObjectModule = NexusObjectFolder:WaitForChild("NexusObject")
local NexusInterfaceModule = NexusObjectFolder:WaitForChild("NexusInterface")

--[[
Test creating an interface.
--]]
NexusUnitTesting:RegisterUnitTest("Creation",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	local NexusInterface = require(NexusInterfaceModule)
	
	--Extend the interface.
	local CuT = NexusInterface:Extend()
	CuT:SetClassName("TestInterface")
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.ClassName,"TestInterface","ClassName isn't properly set.")
	UnitTest:AssertTrue(CuT:IsA("TestInterface"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(CuT:IsA("NexusObject"),"IsA isn't properly registering.")
	
	--Set up required implementations.
	CuT:MustImplement("Function1")
	CuT:MustImplement("Function2")
	CuT:MustImplement("IsA")
	
	--Run the assertions.
	local TestClass = NexusObject.new()
	UnitTest:AssertEquals(NexusInterface:GetMissingAttributes(TestClass),{},"Missing attributes is incorrect.")
	UnitTest:AssertEquals(CuT:GetMissingAttributes(TestClass),{"Function1","Function2"},"Missing attributes is incorrect.")
end)

--[[
Tests having classes implement a non-interface fails.
--]]
NexusUnitTesting:RegisterUnitTest("NonInterfaceFails",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Create a class and interface.
	local TestClass = NexusObject:Extend()
	TestClass:SetClassName("TestObject")
	
	--Assert implementing a non-interface fails.
	UnitTest:AssertErrors(function()
		TestClass:Implements(NexusObject)
	end,"Interface implemented.")
	
	--Create the class.
	TestClass.new()
end)
	
--[[
Tests having classes implement an interface.
--]]
NexusUnitTesting:RegisterUnitTest("ImplementingInterface",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	local NexusInterface = require(NexusInterfaceModule)
	
	--Create a class and interface.
	local CuT = NexusInterface:Extend()
	CuT:SetClassName("TestInterface")
	CuT:MustImplement("TestFunction")
	local TestClass = NexusObject:Extend()
	TestClass:SetClassName("TestObject")
	TestClass:Implements(CuT)
	
	--Assert an error occurs for not implementing the interface.
	UnitTest:AssertErrors(function()
		TestClass.new()
	end,"Error not thrown for unimplemented behavior.")

	--Implement the function.
	function TestClass:TestFunction()
		return true
	end
	
	--Test the interface being implemented.
	local TestObject1 = TestClass.new()
	local TestObject2 = NexusObject.new()
	UnitTest:AssertTrue(TestObject1:IsA("TestObject"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject1:IsA("NexusObject"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject1:IsA("TestInterface"),"IsA isn't properly registering.")
	UnitTest:AssertFalse(TestObject2:IsA("TestInterface"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject1:TestFunction(),"Implemented function is incorrect.")
end)

--[[
Tests having classes implement multiple interfaces.
--]]
NexusUnitTesting:RegisterUnitTest("MultipleInterfaces",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	local NexusInterface = require(NexusInterfaceModule)
	
	--Create a class and interface.
	local CuT1 = NexusInterface:Extend()
	CuT1:SetClassName("TestInterface1")
	CuT1:MustImplement("TestFunction1")
	local CuT2 = NexusInterface:Extend()
	CuT2:SetClassName("TestInterface2")
	CuT2:MustImplement("TestFunction2")
	local TestClass = NexusObject:Extend()
	TestClass:SetClassName("TestObject")
	TestClass:Implements(CuT1)
	TestClass:Implements(CuT2)
	
	--Assert an error occurs for not implementing the interfaces.
	UnitTest:AssertErrors(function()
		TestClass.new()
	end,"Error not thrown for unimplemented behavior.")

	--Implement the first function.
	function TestClass:TestFunction1()
		return true
	end
	
	--Assert an error occurs for not implementing the second interface.
	UnitTest:AssertErrors(function()
		TestClass.new()
	end,"Error not thrown for unimplemented behavior.")
	
	--Implement the second function.
	function TestClass:TestFunction2()
		return true
	end
	
	--Test the interface being implemented.
	local TestObject = TestClass.new()
	UnitTest:AssertTrue(TestObject:IsA("TestObject"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject:IsA("TestInterface1"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject:IsA("TestInterface2"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject:TestFunction1(),"Implemented function is incorrect.")
	UnitTest:AssertTrue(TestObject:TestFunction2(),"Implemented function is incorrect.")
end)

--[[
Tests interfaces propegating to subclasses.
--]]
NexusUnitTesting:RegisterUnitTest("InterfacePropegation",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	local NexusInterface = require(NexusInterfaceModule)
	
	local NexusObject = require(NexusObjectModule)
	local NexusInterface = require(NexusInterfaceModule)
	
	--Create a class and interface.
	local CuT1 = NexusInterface:Extend()
	CuT1:SetClassName("TestInterface1")
	CuT1:MustImplement("TestFunction1")
	local CuT2 = NexusInterface:Extend()
	CuT2:SetClassName("TestInterface2")
	CuT2:MustImplement("TestFunction2")
	local TestClass1 = NexusObject:Extend()
	TestClass1:SetClassName("TestObject1")
	TestClass1:Implements(CuT1)

	local TestClass2 = TestClass1:Extend()
	TestClass2:SetClassName("TestObject2")
	
	--Assert an error occurs for not implementing the interface.
	UnitTest:AssertErrors(function()
		TestClass1.new()
	end,"Error not thrown for unimplemented behavior.")
	UnitTest:AssertErrors(function()
		TestClass2.new()
	end,"Error not thrown for unimplemented behavior.")

	--Implement the function.
	function TestClass2:TestFunction1()
		return true
	end
	
	function TestClass2:TestFunction2()
		return true
	end
	
	--Test the interface being implemented.
	local TestObject = TestClass2.new()
	UnitTest:AssertEquals(TestObject:GetInterfaces(),{CuT1},"Interfaces isn't correct.")
	TestClass2:Implements(CuT2)
	UnitTest:AssertEquals(TestClass1:GetInterfaces(),{CuT1},"Interfaces isn't correct.")
	UnitTest:AssertEquals(TestObject:GetInterfaces(),{CuT1,CuT2},"Interfaces isn't correct.")
	UnitTest:AssertTrue(TestObject:IsA("TestObject1"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject:IsA("TestObject2"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject:IsA("NexusObject"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject:IsA("TestInterface1"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject:IsA("TestInterface2"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(TestObject:TestFunction1(),"Implemented function is incorrect.")
	UnitTest:AssertTrue(TestObject:TestFunction2(),"Implemented function is incorrect.")
end)

--[[
Tests having interfaces implement behavior (although not recommended).
--]]
NexusUnitTesting:RegisterUnitTest("InterfaceWithImplementation",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	local NexusInterface = require(NexusInterfaceModule)
	
	local NexusObject = require(NexusObjectModule)
	local NexusInterface = require(NexusInterfaceModule)
	
	--Create a class and interface.
	local CuT = NexusInterface:Extend()
	CuT:SetClassName("TestInterface")
	CuT:MustImplement("TestFunction2")
	local TestClass = NexusObject:Extend()
	TestClass:SetClassName("TestObject")
	TestClass:Implements(CuT)
	
	--Implement a test function.
	function CuT:TestFunction1()
		return true
	end
	
	--Assert an error occurs for not implementing the interface.
	UnitTest:AssertErrors(function()
		TestClass.new()
	end,"Error not thrown for unimplemented behavior.")

	--Implement the function.
	function TestClass:TestFunction2()
		return true
	end
	
	--Test the interface being implemented.
	local TestObject = TestClass.new()
	UnitTest:AssertTrue(TestObject:TestFunction1(),"Implemented function is incorrect.")
	UnitTest:AssertTrue(TestObject:TestFunction2(),"Implemented function is incorrect.")
end)



--Return true to prevent a ModuleScript error.
return true