--[[
TheNexusAvenger

Unit tests for the NexusInterface class.
--]]
local NexusUnitTesting = require("NexusUnitTesting")

local NexusInstanceFolder = game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance")
local NexusObject = require(NexusInstanceFolder:WaitForChild("NexusObject"))
local NexusInterface = require(NexusInstanceFolder:WaitForChild("NexusInterface"))
local NexusInterfaceTest = NexusUnitTesting.UnitTest:Extend()



--[[
Test creating an interface.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInterfaceTest.new("Creation"):SetRun(function(UnitTest)
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
end))

--[[
Tests that interfaces don't go down.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInterfaceTest.new("InterfaceNotPropegatingDownward"):SetRun(function(UnitTest)
    --Create a class and interface.
    local CuT = NexusInterface:Extend()
    CuT:SetClassName("TestInterface")
    local TestClass = NexusObject:Extend()
    TestClass:SetClassName("TestObject")
    TestClass:Implements(CuT)
    
    --Assert NexusObject was unaffected.
    local Object1,Object2 = TestClass.new(),NexusObject.new()
    UnitTest:AssertEquals(#Object1:GetInterfaces(),1,"Interface not added.")
    UnitTest:AssertTrue(Object1:IsA("TestInterface"),"Interface not implemented.")
    UnitTest:AssertEquals(#Object2:GetInterfaces(),0,"Interface added to NexusObject.")
    UnitTest:AssertFalse(Object2:IsA("TestInterface"),"Interface added to NexusObject.")
end))

--[[
Tests having classes implement a non-interface fails.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInterfaceTest.new("NonInterfaceFails"):SetRun(function(self)
    --Create a class and interface.
    local TestClass = NexusObject:Extend()
    TestClass:SetClassName("TestObject")
    
    --Assert implementing a non-interface fails.
    self:AssertErrors(function()
        TestClass:Implements(NexusObject)
    end,"Interface implemented.")
    
    --Create the class.
    TestClass.new()
end))

--[[
Tests having classes implement an interface.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInterfaceTest.new("ImplementingInterface"):SetRun(function(self)
    --Create a class and interface.
    local CuT = NexusInterface:Extend()
    CuT:SetClassName("TestInterface")
    CuT:MustImplement("TestFunction")
    local TestClass = NexusObject:Extend()
    TestClass:SetClassName("TestObject")
    TestClass:Implements(CuT)
    
    --Assert an error occurs for not implementing the interface.
    self:AssertErrors(function()
        TestClass.new()
    end,"Error not thrown for unimplemented behavior.")

    --Implement the function.
    function TestClass:TestFunction()
        return true
    end
    
    --Test the interface being implemented.
    local TestObject1 = TestClass.new()
    local TestObject2 = NexusObject.new()
    self:AssertTrue(TestObject1:IsA("TestObject"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject1:IsA("NexusObject"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject1:IsA("TestInterface"),"IsA isn't properly registering.")
    self:AssertFalse(TestObject2:IsA("TestInterface"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject1:TestFunction(),"Implemented function is incorrect.")
end))

--[[
Tests having classes implement multiple interfaces.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInterfaceTest.new("MultipleInterfaces"):SetRun(function(self)
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
    self:AssertErrors(function()
        TestClass.new()
    end,"Error not thrown for unimplemented behavior.")

    --Implement the first function.
    function TestClass:TestFunction1()
        return true
    end
    
    --Assert an error occurs for not implementing the second interface.
    self:AssertErrors(function()
        TestClass.new()
    end,"Error not thrown for unimplemented behavior.")
    
    --Implement the second function.
    function TestClass:TestFunction2()
        return true
    end
    
    --Test the interface being implemented.
    local TestObject = TestClass.new()
    self:AssertTrue(TestObject:IsA("TestObject"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject:IsA("TestInterface1"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject:IsA("TestInterface2"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject:TestFunction1(),"Implemented function is incorrect.")
    self:AssertTrue(TestObject:TestFunction2(),"Implemented function is incorrect.")
end))

--[[
Tests interfaces propegating to subclasses.
--]]
NexusUnitTesting:RegisterUnitTest(NexusInterfaceTest.new("InterfacePropegation"):SetRun(function(self)
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
    self:AssertErrors(function()
        TestClass1.new()
    end,"Error not thrown for unimplemented behavior.")
    self:AssertErrors(function()
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
    self:AssertEquals(TestObject:GetInterfaces(),{CuT1},"Interfaces isn't correct.")
    TestClass2:Implements(CuT2)
    self:AssertEquals(TestClass1:GetInterfaces(),{CuT1},"Interfaces isn't correct.")
    self:AssertEquals(TestObject:GetInterfaces(),{CuT1,CuT2},"Interfaces isn't correct.")
    self:AssertTrue(TestObject:IsA("TestObject1"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject:IsA("TestObject2"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject:IsA("NexusObject"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject:IsA("TestInterface1"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject:IsA("TestInterface2"),"IsA isn't properly registering.")
    self:AssertTrue(TestObject:TestFunction1(),"Implemented function is incorrect.")
    self:AssertTrue(TestObject:TestFunction2(),"Implemented function is incorrect.")
end))

--[[
Tests having interfaces implement behavior (although not recommended).
--]]
NexusUnitTesting:RegisterUnitTest(NexusInterfaceTest.new("InterfaceWithImplementation"):SetRun(function(self)
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
    
    --Implement a test function that will be overriden.
    function CuT:TestFunction3()
        return false
    end
    
    --Assert an error occurs for not implementing the interface.
    self:AssertErrors(function()
        TestClass.new()
    end,"Error not thrown for unimplemented behavior.")

    --Implement the functions.
    function TestClass:TestFunction2()
        return true
    end
    
    function TestClass:TestFunction2()
        return true
    end
    
    --Test the interface being implemented.
    local TestObject = TestClass.new()
    self:AssertTrue(TestObject:TestFunction1(),"Implemented function is incorrect.")
    self:AssertTrue(TestObject:TestFunction2(),"Implemented function is incorrect.")
        self:AssertTrue(TestObject:TestFunction2(),"Implemented function is incorrect.")
end))



--Return true to prevent a ModuleScript error.
return true