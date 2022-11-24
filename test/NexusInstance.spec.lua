--[[
TheNexusAvenger

Tests for the NexusInstance class.
--]]
--!strict

local NexusInstance = require(game.ReplicatedStorage.NexusInstance.NexusInstance)

return function()
    describe("An instance of NexusInstance", function()
        local TestNexusInstance = NexusInstance.new()
        beforeEach(function()
            TestNexusInstance = NexusInstance.new()
        end)
        afterEach(function()
            TestNexusInstance:Destroy()
        end)

        it("should be constructed correctly.", function()
            TestNexusInstance.FalseValue = false

            expect(TestNexusInstance.ClassName).to.equal("NexusInstance")
            expect(TestNexusInstance:IsA("NexusInstance")).to.equal(true)
            expect(TestNexusInstance:IsA("NexusObject")).to.equal(true)
            expect(TestNexusInstance.super:IsA("NexusObject")).to.equal(true)
            expect(TestNexusInstance.FalseValue).to.equal(false)
            expect(TestNexusInstance.object == TestNexusInstance).to.equal(true)
            expect(TestNexusInstance.super.object == TestNexusInstance).to.equal(true)
            expect(TestNexusInstance.class).to.equal(NexusInstance)
        end)

        it("should work with property validators.", function()
            TestNexusInstance:AddPropertyValidator("TestValue", function(Name, Value)
                return Value.."_Value1"
            end)
            TestNexusInstance:AddGenericPropertyValidator(function(Name, Value)
                return Value.."_Value2_"..Name
            end)
            TestNexusInstance:AddPropertyValidator("TestValue", function(Name, Value)
                return Value.."_Value3"
            end)

            TestNexusInstance.TestValue = "Test"
            TestNexusInstance.TestValue2 = "Test"
            expect(TestNexusInstance.TestValue).to.equal("Test_Value2_TestValue_Value1_Value3")
            expect(TestNexusInstance.TestValue2).to.equal("Test_Value2_TestValue2")
        end)

        it("should work with legacy property validators.", function()
            TestNexusInstance:AddPropertyValidator("TestValue", {
                ValidateChange = function(_, Object, Name, Value: string): string
                    return Value.."_Value1"
                end,
            })
            TestNexusInstance:AddGenericPropertyValidator({
                ValidateChange = function(_, Object, Name, Value: string): string
                    return Value.."_Value2_"..Name
                end,
            })
            TestNexusInstance:AddPropertyValidator("TestValue", {
                ValidateChange = function(_, Object, Name, Value: string): string
                    return Value.."_Value3"
                end,
            })

            TestNexusInstance.TestValue = "Test"
            TestNexusInstance.TestValue2 = "Test"
            expect(TestNexusInstance.TestValue).to.equal("Test_Value2_TestValue_Value1_Value3")
            expect(TestNexusInstance.TestValue2).to.equal("Test_Value2_TestValue2")
        end)

        it("should work with property finalizers.", function()
            local Value1s, Value2s = {},{}
            TestNexusInstance:AddPropertyFinalizer("TestValue", function(Name, Value)
                table.insert(Value1s, Name.."_"..Value.."_"..TestNexusInstance.TestValue.."_1")
            end)
            TestNexusInstance:AddGenericPropertyFinalizer(function(Name, Value)
                if Name == "TestValue" then
                    table.insert(Value1s, Name.."_"..Value.."_"..TestNexusInstance.TestValue.."_2")
                else
                    table.insert(Value2s, Name.."_"..Value.."_"..TestNexusInstance.TestValue2.."_2")
                end
            end)
            TestNexusInstance:AddPropertyFinalizer("TestValue",function(Name, Value)
                table.insert(Value1s, Name.."_"..Value.."_"..TestNexusInstance.TestValue.."_3")
            end)

            --Set the values and assert they are correct.
            TestNexusInstance.TestValue = "Test"
            TestNexusInstance.TestValue2 = "Test"
            expect(Value1s[1]).to.equal("TestValue_Test_Test_2")
            expect(Value1s[2]).to.equal("TestValue_Test_Test_1")
            expect(Value1s[3]).to.equal("TestValue_Test_Test_3")
            expect(Value2s[1]).to.equal("TestValue2_Test_Test_2")
        end)

        it("should lock properties.", function()
            TestNexusInstance.TestLock = "Test"
            TestNexusInstance:LockProperty("TestLock")

            expect(TestNexusInstance.TestLock).to.equal("Test")
            expect(function()
                TestNexusInstance.TestLock = "Fail"
            end).to.throw("TestLock is read-only.")
        end)

        it("should fire changed events without duplicates.", function()
            local ChangedProperties = {}
            TestNexusInstance.Changed:Connect(function(Name)
                table.insert(ChangedProperties, Name)
            end)

            TestNexusInstance.TestChange1 = "Test1"
            TestNexusInstance.TestChange1 = "Test2"
            TestNexusInstance.TestChange1 = "Test2"
            TestNexusInstance.TestChange2 = "Test3"

            expect(ChangedProperties[1]).to.equal("TestChange1")
            expect(ChangedProperties[2]).to.equal("TestChange1")
            expect(ChangedProperties[3]).to.equal("TestChange2")
        end)

        it("should hide property changes.", function()
            TestNexusInstance.TestHide = "Test"
            TestNexusInstance:HidePropertyChanges("TestHide")
            
            local ChangedCalls = 0
            TestNexusInstance.Changed:Connect(function()
                ChangedCalls += 1
            end)
            TestNexusInstance.TestHide = "Fail"
            task.wait()
            expect(ChangedCalls).to.equal(0)
        end)

        it("should hide individual property changes.", function()
            local ChangedEvents = {}
            TestNexusInstance.Changed:Connect(function()
                table.insert(ChangedEvents, TestNexusInstance.TestHide)
            end)

            TestNexusInstance:HideNextPropertyChange("TestHide")
            TestNexusInstance.TestHide = "Fail"
            TestNexusInstance.TestHide = "Pass"
            task.wait()
            expect(ChangedEvents[1]).to.equal("Pass")
        end)

        it("should fire changed events for individual properties.", function()
            local ChangedEvents = {}
            TestNexusInstance:GetPropertyChangedSignal("TestChange"):Connect(function()
                table.insert(ChangedEvents, TestNexusInstance.TestChange)
            end)

            TestNexusInstance.TestChange = "Pass"
            task.wait()
            expect(ChangedEvents[1]).to.equal("Pass")
        end)

        it("should fire changed events for individual hidden properties.", function()
            local ChangedEvents = {}
            TestNexusInstance:GetPropertyChangedSignal("TestChange"):Connect(function()
                table.insert(ChangedEvents, TestNexusInstance.TestChange)
            end)

            TestNexusInstance:HidePropertyChanges("TestChange")
            TestNexusInstance.TestChange = "Pass"
            task.wait()
            expect(ChangedEvents[1]).to.equal("Pass")
        end)

        it("should disconnect changed events when destroyed.", function()
            local TimesCalled1, TimesCalled2 = 0, 0
            TestNexusInstance.Changed:Connect(function()
                TimesCalled1 += 1
            end)
            TestNexusInstance:GetPropertyChangedSignal("TestChange"):Connect(function()
                TimesCalled2 += 1
            end)

            TestNexusInstance.TestChange = "Test1"
            wait()
            expect(TimesCalled1).to.equal(1)
            expect(TimesCalled2).to.equal(1)

            TestNexusInstance:Destroy()
            TestNexusInstance.TestChange = "Test2"
            wait()
            expect(TimesCalled1).to.equal(1)
            expect(TimesCalled2).to.equal(1)
        end)
    end)
    
    describe("A subclass of NexusInstance", function()
        it("should lock properties.", function()
            local TestClass = NexusInstance:Extend()
            function TestClass:__new()
                self:InitializeSuper()
                self.TestLock = "Test"
                self:LockProperty("TestLock")
            end

            local TestObject = TestClass.new()
            expect(TestObject.TestLock).to.equal("Test")
            expect(function()
                TestObject.TestLock = "Fail"
            end).to.throw("TestLock is read-only.")
            TestObject:Destroy()
        end)

        it("should fire changed events.", function()
            local TestClass = NexusInstance:Extend()
            function TestClass:__new()
                self:InitializeSuper()
                self.TestChange = "Test1"
            end
            
            local TestObject = TestClass.new()
            local ChangedEvents = {}
            TestObject.Changed:Connect(function()
                table.insert(ChangedEvents, TestObject.TestChange)
            end)
            
            TestObject.TestChange = "Test2"
            TestObject.TestChange = "Test2"
            TestObject.TestChange = "Test3"
            task.wait()
            expect(ChangedEvents[1]).to.equal("Test2")
            expect(ChangedEvents[2]).to.equal("Test3")
            TestObject:Destroy()
        end)

        it("should extend twice.", function()
            local TestClass1 = NexusInstance:Extend():SetClassName("TestClass1")
            function TestClass1:__new()
                self:InitializeSuper()
                self.TestProperty1 = "Test1"
            end

            local TestClass2 = TestClass1:Extend():SetClassName("TestClass2")
            function TestClass2:__new()
                self:InitializeSuper()
                self.TestProperty2 = "Test2"
            end

            local TestObject = TestClass2.new()
            expect(TestObject.ClassName).to.equal("TestClass2")
            expect(TestObject:IsA("TestClass2")).to.equal(true)
            expect(TestObject:IsA("TestClass1")).to.equal(true)
            expect(TestObject:IsA("NexusInstance")).to.equal(true)
            expect(TestObject.TestProperty1).to.equal("Test1")
            expect(TestObject.TestProperty2).to.equal("Test2")
            TestObject:Destroy()
        end)
    end)
end