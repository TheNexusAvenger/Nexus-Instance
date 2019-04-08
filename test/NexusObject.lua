--[[
TheNexusAvenger

Unit tests for the NexusObject class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local Sources = game:GetService("ReplicatedStorage"):WaitForChild("Sources")
local NexusObjectFolder = Sources:WaitForChild("NexusObject")
local NexusObjectModule = NexusObjectFolder:WaitForChild("NexusObject")



--[[
Test the constructor.
--]]
NexusUnitTesting:RegisterUnitTest("Constructor",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Create the object.
	local CuT = NexusObject.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.ClassName,"NexusObject","ClassName isn't properly set.")
	UnitTest:AssertTrue(CuT:IsA("NexusObject"),"IsA isn't properly registering.")
	UnitTest:AssertFalse(CuT:IsA("BasePart"),"IsA returned true for an invalid class name.")
end)

--[[
Test overriding the constructor.
--]]
NexusUnitTesting:RegisterUnitTest("ConstructorOverride",function(UnitTest)
	--Require a clone of NexusObject (requires the plugin or command line).
	local NexusObject = require(NexusObjectModule)
	
	--Override the constructor.
	function NexusObject:__new()
		--Pass the unit test.
		UnitTest:Pass()
	end
	
	--Create the object.
	local CuT = NexusObject.new()
	
	--Fail the test if the constructor wasn't called.
	UnitTest:Fail("Constructor not overriden")
end)

--[[
Test that subclasses get a clear constructor.
--]]
NexusUnitTesting:RegisterUnitTest("ConstructorCleared",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject = NexusObject:Extend()
	local NewCalled = 0
	
	--Override the constructor.
	function ExtendedObject:__new()
		self:InitializeSuper()
		NewCalled = NewCalled + 1
	end
	
	--Extend the object 3 times.
	local TestClass1 = ExtendedObject:Extend()
	local TestClass2 = TestClass1:Extend()
	local TestClass3 = TestClass2:Extend()
	
	--Create the object.
	local CuT = TestClass3.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(NewCalled,1,"__new called an incorrect amount of times.")
end)

--[[
Test the Extend function.
--]]
NexusUnitTesting:RegisterUnitTest("Extend",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject = NexusObject:Extend()
	ExtendedObject:SetClassName("ExtendedClass")
	
	--Override the constructor.
	function ExtendedObject:__new()
	end
	
	--Create the object.
	local CuT = ExtendedObject.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.ClassName,"ExtendedClass","ClassName isn't properly set.")
	UnitTest:AssertEquals(CuT.super,NexusObject,"Super isn't set correctly.")
	UnitTest:AssertTrue(CuT:IsA("ExtendedClass"),"IsA isn't properly registering.")
end)

--[[
Test the Extend function with super class functions.
--]]
NexusUnitTesting:RegisterUnitTest("ExtendWithFunctions",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject1 = NexusObject:Extend()
	
	--Override the constructor.
	function ExtendedObject1:__new()
		self:InitializeSuper()
	end
	
	--Create a test function.
	function ExtendedObject1:Test()
		return "Test1"
	end
	
	--Extend the ExtendedObject1 class.
	local ExtendedObject2 = ExtendedObject1:Extend()
	
	--Override the constructor.
	function ExtendedObject2:__new()
		self:InitializeSuper()
	end
	
	--Create a test function.
	function ExtendedObject2:Test()
		return "Test2"
	end
	
	--Create the object.
	local CuT = ExtendedObject2.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT:Test(),"Test2","Test() isn't properly set.")
	UnitTest:AssertEquals(CuT.super:Test(),"Test1","super.Test() isn't properly set.")
end)
	
--[[
Test the Extend function with super class functions without initializing the super.
--]]
NexusUnitTesting:RegisterUnitTest("ExtendWithFunctionsNoSuper",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject1 = NexusObject:Extend()
	
	--Override the constructor.
	function ExtendedObject1:__new()
	end
	
	--Create a test function.
	function ExtendedObject1:Test()
		return "Test1"
	end
	
	--Extend the ExtendedObject1 class.
	local ExtendedObject2 = ExtendedObject1:Extend()
	
	--Override the constructor.
	function ExtendedObject2:__new()
		
	end
	
	--Create the object.
	local CuT = ExtendedObject2.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT:Test(),"Test1","Test() isn't properly set.")
	UnitTest:AssertEquals(CuT.super,ExtendedObject1,"super isn't properly set.")
end)

--[[
Test the InitializeSuper function.
--]]
NexusUnitTesting:RegisterUnitTest("SetClassName",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject = NexusObject:Extend()
	ExtendedObject:SetClassName("ExtendedClass")
	
	--Create the object.
	local CuT = ExtendedObject.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.ClassName,"ExtendedClass","ClassName isn't properly set.")
	UnitTest:AssertTrue(CuT:IsA("ExtendedClass"),"IsA isn't properly registering.")
end)

--[[
Test the InitializeSuper function.
--]]
NexusUnitTesting:RegisterUnitTest("InitializeSuper",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject = NexusObject:Extend()
	ExtendedObject:SetClassName("ExtendedClass")
	
	--Override the constructor.
	function ExtendedObject:__new()
		self:InitializeSuper()
	end
	
	--Create the object.
	local CuT = ExtendedObject.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.ClassName,"ExtendedClass","ClassName isn't properly set.")
	UnitTest:AssertNotNil(CuT.super,"Super isn't initialized.")
	UnitTest:AssertTrue(CuT:IsA("ExtendedClass"),"IsA isn't properly registering.")
	UnitTest:AssertTrue(CuT:IsA("NexusObject"),"IsA returns incorrectly with the super class initialized.")
end)

--[[
Test extending twice.
--]]
NexusUnitTesting:RegisterUnitTest("DoubleExtends",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject1 = NexusObject:Extend()
	ExtendedObject1:SetClassName("ExtendedClass1")
	
	--Override the constructor.
	function ExtendedObject1:__new()
		self:InitializeSuper()
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
end)

--[[
Test extending twice with a parameters.
--]]
NexusUnitTesting:RegisterUnitTest("DoubleExtendsWithParameter",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject1 = NexusObject:Extend()
	ExtendedObject1:SetClassName("ExtendedClass1")
	
	--Override the constructor.
	function ExtendedObject1:__new(Name)
		self:InitializeSuper()
		self.Name = Name
		
		--Fail if the name isn't given.
		if not Name then
			UnitTest:Fail("Name not given")
		end
	end
	
	--Extend the ExtendedObject1 class.
	local ExtendedObject2 = ExtendedObject1:Extend()
	ExtendedObject2:SetClassName("ExtendedClass2")
	
	--Override the constructor.
	function ExtendedObject2:__new(Name)
		self:InitializeSuper(Name)
	end
	
	--Create the object.
	local CuT = ExtendedObject2.new("TestName")
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.Name,"TestName","Name isn't properly set.")
end)

--[[
Test extending twice with a custom method implemented.
--]]
NexusUnitTesting:RegisterUnitTest("ExtendsWithImplementation",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject1 = NexusObject:Extend()
	
	--Extend the ExtendedObject1 class.
	local ExtendedObject2 = ExtendedObject1:Extend()
	
	--Implement a test function.
	function ExtendedObject2:Test()
		return "Test"
	end
	
	--Extend the ExtendedObject2 class.
	local ExtendedObject3 = ExtendedObject2:Extend()
	
	--Extend the ExtendedObject3 class.
	local ExtendedObject4 = ExtendedObject3:Extend()
	
	--Implement a test function.
	function ExtendedObject4:Test()
		return "Test2"
	end
	
	--Create the object.
	local CuT1 = ExtendedObject1.new()
	local CuT2 = ExtendedObject2.new()
	local CuT3 = ExtendedObject3.new()
	local CuT4 = ExtendedObject4.new()
	
	--Run the assertions.
	UnitTest:AssertNil(CuT1.Test,"Function implemented in super class.")
	UnitTest:AssertEquals(CuT2:Test(),"Test","Function isn't returning correctly.")
	UnitTest:AssertEquals(CuT3:Test(),"Test","Function isn't returning correctly.")
	UnitTest:AssertEquals(CuT4:Test(),"Test2","Function is overriden.")
end)

--[[
Test extending twice with setting a property.
--]]
NexusUnitTesting:RegisterUnitTest("ExtendsWithPropertyChanged",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject1 = NexusObject:Extend()
	ExtendedObject1:SetClassName("ExtendedClass1")
	
	--Override the constructor.
	function ExtendedObject1:__new()
		self:InitializeSuper()
	end
	
	--Returns the test value.
	function ExtendedObject1:GetValue()
		return self.Value
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
	CuT.Value = "Test"
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.Value,"Test","Value isn't set.")
	UnitTest:AssertEquals(CuT.super.Value,"Test","Value isn't set.")
	UnitTest:AssertEquals(CuT:GetValue(),"Test","Function isn't returning correctly.")
	UnitTest:AssertEquals(CuT.super:GetValue(),"Test","Function isn't returning correctly.")
end)

--[[
Test extending with a property stored in the subclass.
--]]
NexusUnitTesting:RegisterUnitTest("SuperClassAccessOfSub",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject1 = NexusObject:Extend()
	ExtendedObject1:SetClassName("ExtendedClass1")
	
	--Override the constructor.
	function ExtendedObject1:__new()
		self:InitializeSuper()
	end
	
	--Returns the test value.
	function ExtendedObject1:GetValue()
		return self.Value
	end
	
	--Extend the ExtendedObject1 class.
	local ExtendedObject2 = ExtendedObject1:Extend()
	ExtendedObject2:SetClassName("ExtendedClass2")
	
	--Override the constructor.
	function ExtendedObject2:__new()
		self:InitializeSuper()
		self.Value = "Test"
	end
	
	--Create the object.
	local CuT = ExtendedObject2.new()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT.Value,"Test","Value isn't set.")
	UnitTest:AssertEquals(CuT.super.Value,"Test","Value isn't set.")
	UnitTest:AssertEquals(CuT:GetValue(),"Test","Function isn't returning correctly.")
	UnitTest:AssertEquals(CuT.super:GetValue(),"Test","Function isn't returning correctly.")
end)

--[[
Test extending with a property stored in the superclass.
--]]
NexusUnitTesting:RegisterUnitTest("SuperClassAccessOfSuper",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local ExtendedObject1 = NexusObject:Extend()
	ExtendedObject1:SetClassName("ExtendedClass1")
	
	--Override the constructor.
	function ExtendedObject1:__new()
		self:InitializeSuper()
		self.Value = "Test"
	end
	
	--Returns the test value.
	function ExtendedObject1:GetValue()
		return self.Value
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
	UnitTest:AssertEquals(CuT.Value,"Test","Value isn't set.")
	UnitTest:AssertEquals(CuT.super.Value,"Test","Value isn't set.")
	UnitTest:AssertEquals(CuT:GetValue(),"Test","Value isn't set.")
end)

--[[
Test adding metamethods that aren't __index or __newindex.
--]]
NexusUnitTesting:RegisterUnitTest("Metamethods",function(UnitTest)
	local NexusObject = require(NexusObjectModule)
	
	--Extend the NexusObject class.
	local BasicExtendedObject = NexusObject:Extend()
	BasicExtendedObject:SetClassName("BasicExtendedObject")
	local ExtendedObject = NexusObject:Extend()
	ExtendedObject:SetClassName("ExtendedObject")
	
	--Create a constructor.
	function ExtendedObject:__new(Value)
		self.Value = Value
	end
	
	--Add an equals method.
	function ExtendedObject:__eq(OtherObject)
		return self.Value == OtherObject.Value
	end
	
	--Add a tostring method.
	function ExtendedObject:__tostring()
		return self.ClassName.." "..self.Value
	end
	
	--Create the object.
	local CuT1 = NexusObject.new()
	local CuT2 = BasicExtendedObject.new()
	local CuT3 = ExtendedObject.new(1)
	local CuT4 = ExtendedObject.new(1)
	local CuT5 = ExtendedObject.new(2)
	
	--Run the assertions.
	UnitTest:AssertEquals(string.sub(tostring(CuT1),1,13),"NexusObject: ","tostring() is incorrect.")
	UnitTest:AssertEquals(string.sub(tostring(CuT2),1,21),"BasicExtendedObject: ","tostring() isn't inherited.")
	UnitTest:AssertEquals(tostring(CuT3),"ExtendedObject 1","tostring() is incorrect.")
	UnitTest:AssertEquals(tostring(CuT4),"ExtendedObject 1","tostring() is incorrect.")
	UnitTest:AssertEquals(tostring(CuT5),"ExtendedObject 2","tostring() is incorrect.")
	UnitTest:AssertEquals(CuT3,CuT4,"Objects aren't equals")
	UnitTest:AssertNotEquals(CuT3,CuT5,"Objects are equals")
	UnitTest:AssertNotEquals(CuT4,CuT5,"Objects are equals")
end)



--Return true to prevent a ModuleScript error.
return true