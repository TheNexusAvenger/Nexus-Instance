--[[
TheNexusAvenger

Tests for the NexusObject class.
--]]
--!strict

local NexusObject = require(game.ReplicatedStorage.NexusInstance.NexusObject)

return function()
    describe("An instance of NexusObject", function()
        it("should be constructed correctly.", function()
            local TestObject = NexusObject.new()
            expect(TestObject.ClassName).to.equal("NexusObject")
            expect(TestObject:IsA("NexusObject")).to.equal(true)
            expect(TestObject:IsA("BasePart")).to.equal(false)
            expect(TestObject.object).to.equal(TestObject)
        end)
    end)

    describe("A subclass of NexusObject", function()
        it("should be set the class name.", function()
            local TestClass = NexusObject:Extend():SetClassName("TestClassName")
            expect(TestClass.ClassName).to.equal("TestClassName")
            expect(TestClass:IsA("TestClassName")).to.equal(true)
            expect(TestClass:IsA("NexusObject")).to.equal(true)
        end)

        it("should clear the constructor.", function()
            local TestClass1 = NexusObject:Extend()
            local TimesCalled = 0
            function TestClass1:__new()
                self:InitializeSuper()
                TimesCalled += 1
            end

            local TestClass2 = TestClass1:Extend()
            local TestClass3 = TestClass2:Extend()
            TestClass3.new()
            expect(TimesCalled).to.equal(1)
        end)

        it("should use the desired class method.", function()
            local TestClass1 = NexusObject:Extend()
            function TestClass1:Test()
                return "Test1"
            end
            local TestClass2 = TestClass1:Extend()
            function TestClass2:Test()
                return "Test2"
            end

            local TestObject = TestClass2.new()
            expect(TestObject:Test()).to.equal("Test2")
            expect(TestObject.super:Test()).to.equal("Test1")
        end)

        it("should use super class methods.", function()
            local TestClass1 = NexusObject:Extend()
            function TestClass1:Test()
                return "Test1"
            end

            local TestClass2 = TestClass1:Extend()
            local TestObject = TestClass2.new()
            expect(TestObject:Test()).to.equal("Test1")
        end)

        it("should pass constructor paramters.", function()
            local TestClass1 = NexusObject:Extend()
            function TestClass1:__new(TestValue)
                self:InitializeSuper()
                self.TestValue1 = TestValue
            end
            local TestClass2 = TestClass1:Extend()
            function TestClass2:__new(TestValue)
                self:InitializeSuper(TestValue)
                self.TestValue2 = TestValue
            end

            local TestObject = (TestClass2 :: {new: (string) -> (NexusObject.NexusObject)}).new("Test")
            expect(TestObject.TestValue1).to.equal("Test")
            expect(TestObject.TestValue2).to.equal("Test")
        end)

        it("should access properties in super class.", function()
            local TestObject = NexusObject:Extend().new()
            TestObject.TestValue = "Test"
            expect(TestObject.super.TestValue).to.equal("Test")
        end)

        it("should copy metamethods.", function()
            local BasicExtendedObject = NexusObject:Extend():SetClassName("BasicExtendedObject")
            local ExtendedObject = NexusObject:Extend():SetClassName("ExtendedObject") :: {new: (number) -> (NexusObject.NexusObject)} & NexusObject.NexusObject
            function ExtendedObject:__new(Value)
                self.Value = Value
            end
            function ExtendedObject:__add(OtherObject)
                return self.Value + OtherObject.Value
            end
            function ExtendedObject:__tostring()
                return self.ClassName.." "..self.Value
            end
            
            --Create the object.
            local TestObject1 = NexusObject.new()
            local TestObject2 = BasicExtendedObject.new()
            local TestObject3 = ExtendedObject.new(1)
            local TestObject4 = ExtendedObject.new(1)
            local TestObject5 = ExtendedObject.new(2)
            
            --Run the assertions.
            expect(string.sub(tostring(TestObject1), 1, 13)).to.equal("NexusObject: ")
            expect(string.sub(tostring(TestObject2), 1, 21)).to.equal("BasicExtendedObject: ")
            expect(tostring(TestObject3)).to.equal("ExtendedObject 1")
            expect(tostring(TestObject4)).to.equal("ExtendedObject 1")
            expect(tostring(TestObject5)).to.equal("ExtendedObject 2")
            expect((TestObject3 :: any) + TestObject4).to.equal(2)
            expect((TestObject3 :: any) + TestObject5).to.equal(3)
            expect((TestObject4 :: any) + TestObject5).to.equal(3)
        end)
    end)
end