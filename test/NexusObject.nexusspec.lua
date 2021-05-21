--[[
TheNexusAvenger

Unit tests for the NexusObject class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusInstanceFolder = game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance")
local NexusObject = require(NexusInstanceFolder:WaitForChild("NexusObject"))
local NexusObjectTest = NexusUnitTesting.UnitTest:Extend()



--[[
Test the constructor.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("Constructor"):SetRun(function(self)
    --Create the object.
    local CuT = NexusObject.new()
    
    --Run the assertions.
    self:AssertEquals(CuT.ClassName,"NexusObject","ClassName isn't properly set.")
    self:AssertTrue(CuT:IsA("NexusObject"),"IsA isn't properly registering.")
    self:AssertFalse(CuT:IsA("BasePart"),"IsA returned true for an invalid class name.")
    self:AssertSame(CuT.object,CuT,"object is incorrect.")
end))

--[[
Test that subclasses get a clear constructor.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("ConstructorCleared"):SetRun(function(self)
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
    self:AssertEquals(NewCalled,1,"__new called an incorrect amount of times.")
end))

--[[
Test the Extend function.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("Extend"):SetRun(function(self)
    --Extend the NexusObject class.
    local ExtendedObject = NexusObject:Extend()
    ExtendedObject:SetClassName("ExtendedClass")
    
    --Override the constructor.
    function ExtendedObject:__new()
    end
    
    --Create the object.
    local CuT = ExtendedObject.new()
    
    --Run the assertions.
    self:AssertEquals(CuT.ClassName,"ExtendedClass","ClassName isn't properly set.")
    self:AssertNotNil(CuT.super,"Super isn't set.")
    self:AssertTrue(CuT:IsA("ExtendedClass"),"IsA isn't properly registering.")
end))

--[[
Test the Extend function with super class functions.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("ExtendWithFunctions"):SetRun(function(self)
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
    self:AssertEquals(CuT:Test(),"Test2","Test() isn't properly set.")
    self:AssertEquals(CuT.super:Test(),"Test1","super.Test() isn't properly set.")
end))
    
--[[
Test the Extend function with super class functions without initializing the super.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("ExtendWithFunctionsNoSuper"):SetRun(function(self)
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
    self:AssertEquals(CuT:Test(),"Test1","Test() isn't properly set.")
    self:AssertNotNil(CuT.super,"super isn't properly set.")
end))

--[[
Test the InitializeSuper function.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("SetClassName"):SetRun(function(self)
    --Extend the NexusObject class.
    local ExtendedObject = NexusObject:Extend()
    ExtendedObject:SetClassName("ExtendedClass")
    
    --Create the object.
    local CuT = ExtendedObject.new()
    
    --Run the assertions.
    self:AssertEquals(CuT.ClassName,"ExtendedClass","ClassName isn't properly set.")
    self:AssertTrue(CuT:IsA("ExtendedClass"),"IsA isn't properly registering.")
end))

--[[
Test the InitializeSuper function.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("InitializeSuper"):SetRun(function(self)
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
    self:AssertEquals(CuT.ClassName,"ExtendedClass","ClassName isn't properly set.")
    self:AssertNotNil(CuT.super,"Super isn't initialized.")
    self:AssertTrue(CuT:IsA("ExtendedClass"),"IsA isn't properly registering.")
    self:AssertTrue(CuT:IsA("NexusObject"),"IsA returns incorrectly with the super class initialized.")
end))

--[[
Test extending twice.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("DoubleExtends"):SetRun(function(self)
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
    self:AssertEquals(CuT.ClassName,"ExtendedClass2","ClassName isn't properly set.")
    self:AssertNotNil(CuT.super,"Super isn't initialized.")
    self:AssertTrue(CuT:IsA("ExtendedClass2"),"IsA isn't properly registering.")
    self:AssertTrue(CuT:IsA("ExtendedClass1"),"IsA returns incorrectly with the super class initialized.")
    self:AssertTrue(CuT:IsA("NexusObject"),"IsA returns incorrectly with the super class initialized.")
end))

--[[
Test extending twice with a parameters.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("DoubleExtendsWithParameter"):SetRun(function(self)
    --Extend the NexusObject class.
    local ExtendedObject1 = NexusObject:Extend()
    ExtendedObject1:SetClassName("ExtendedClass1")
    
    --Override the constructor.
    function ExtendedObject1:__new(Name)
        self:InitializeSuper()
        self.Name = Name
        
        --Fail if the name isn't given.
        if not Name then
            self:Fail("Name not given")
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
    self:AssertEquals(CuT.Name,"TestName","Name isn't properly set.")
end))

--[[
Test extending twice with a custom method implemented.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("ExtendsWithImplementation"):SetRun(function(self)
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
    self:AssertNil(CuT1.Test,"Function implemented in super class.")
    self:AssertEquals(CuT2:Test(),"Test","Function isn't returning correctly.")
    self:AssertEquals(CuT3:Test(),"Test","Function isn't returning correctly.")
    self:AssertEquals(CuT4:Test(),"Test2","Function is overriden.")
end))

--[[
Test extending twice with setting a property.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("ExtendsWithPropertyChanged"):SetRun(function(self)
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
    self:AssertEquals(CuT.Value,"Test","Value isn't set.")
    self:AssertEquals(CuT.super.Value,"Test","Value isn't set.")
    self:AssertEquals(CuT:GetValue(),"Test","Function isn't returning correctly.")
    self:AssertEquals(CuT.super:GetValue(),"Test","Function isn't returning correctly.")
end))

--[[
Test extending with a property stored in the subclass.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("SuperClassAccessOfSub"):SetRun(function(self)
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
    self:AssertEquals(CuT.Value,"Test","Value isn't set.")
    self:AssertEquals(CuT.super.Value,"Test","Value isn't set.")
    self:AssertEquals(CuT:GetValue(),"Test","Function isn't returning correctly.")
    self:AssertEquals(CuT.super:GetValue(),"Test","Function isn't returning correctly.")
end))

--[[
Test extending with a property stored in the superclass.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("SuperClassAccessOfSuper"):SetRun(function(self)
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
    self:AssertEquals(CuT.Value,"Test","Value isn't set.")
    self:AssertEquals(CuT.super.Value,"Test","Value isn't set.")
    self:AssertEquals(CuT:GetValue(),"Test","Value isn't set.")
end))

--[[
Test adding metamethods that aren't __index or __newindex.
--]]
NexusUnitTesting:RegisterUnitTest(NexusObjectTest.new("Metamethods"):SetRun(function(self)
    --Extend the NexusObject class.
    local BasicExtendedObject = NexusObject:Extend()
    BasicExtendedObject:SetClassName("BasicExtendedObject")
    local ExtendedObject = NexusObject:Extend()
    ExtendedObject:SetClassName("ExtendedObject")
    
    --Create a constructor.
    function ExtendedObject:__new(Value)
        self.Value = Value
    end
    
    --Add an add method.
    function ExtendedObject:__add(OtherObject)
        return self.Value + OtherObject.Value
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
    self:AssertEquals(string.sub(tostring(CuT1),1,13),"NexusObject: ","tostring() is incorrect.")
    self:AssertEquals(string.sub(tostring(CuT2),1,21),"BasicExtendedObject: ","tostring() isn't inherited.")
    self:AssertEquals(tostring(CuT3),"ExtendedObject 1","tostring() is incorrect.")
    self:AssertEquals(tostring(CuT4),"ExtendedObject 1","tostring() is incorrect.")
    self:AssertEquals(tostring(CuT5),"ExtendedObject 2","tostring() is incorrect.")
    self:AssertEquals(CuT3 + CuT4,2,"Objects don't add correctly.")
    self:AssertEquals(CuT3 + CuT5,3,"Objects don't add correctly.")
    self:AssertEquals(CuT4 + CuT5,3,"Objects don't add correctly.")
end))



--Return true to prevent a ModuleScript error.
return true