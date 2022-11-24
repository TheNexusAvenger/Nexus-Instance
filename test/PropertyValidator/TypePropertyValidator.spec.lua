--[[
TheNexusAvenger

Tests for the TypePropertyValidator class.
--]]
--!strict

local NexusInstance = require(game.ReplicatedStorage.NexusInstance.NexusInstance)
local TypePropertyValidator = require(game.ReplicatedStorage.NexusInstance.PropertyValidator.TypePropertyValidator)

return function()
    describe("A type validator function", function()
        it("should block invalid property changes.", function()
            local TestObject = NexusInstance.new()
            TestObject:AddPropertyValidator("Property1", TypePropertyValidator.CreateTypeValidator("CFrame"))
            TestObject:AddPropertyValidator("Property2", TypePropertyValidator.CreateTypeValidator("BasePart"))
            TestObject:AddPropertyValidator("Property3", TypePropertyValidator.CreateTypeValidator("NexusObject"))

            local Property = CFrame.new() :: any
            TestObject.Property1 = Property
            expect(TestObject.Property1).to.equal(Property)
            expect(function()
                TestObject.Property1 = "Fail"
            end).to.throw("CFrame expected, got string")
            expect(TestObject.Property1).to.equal(Property)
            
            Property = Instance.new("Part")
            TestObject.Property2 = Property
            expect(TestObject.Property2).to.equal(Property)
            expect(function()
                TestObject.Property2 = "Fail"
            end).to.throw("BasePart expected, got string")
            expect(TestObject.Property2).to.equal(Property)
            
            Property = NexusInstance.new()
            TestObject.Property3 = Property
            expect(TestObject.Property3).to.equal(Property)
            expect(function()
                TestObject.Property3 = "Fail"
            end).to.throw("NexusObject expected, got string")
            expect(TestObject.Property3).to.equal(Property)
        end)
    end)

    describe("A type validator object", function()
        it("should block invalid property changes.", function()
            local TestObject = NexusInstance.new()
            TestObject:AddPropertyValidator("Property1", TypePropertyValidator.new("CFrame"))
            TestObject:AddPropertyValidator("Property2", TypePropertyValidator.new("BasePart"))
            TestObject:AddPropertyValidator("Property3", TypePropertyValidator.new("NexusObject"))

            local Property = CFrame.new() :: any
            TestObject.Property1 = Property
            expect(TestObject.Property1).to.equal(Property)
            expect(function()
                TestObject.Property1 = "Fail"
            end).to.throw("CFrame expected, got string")
            expect(TestObject.Property1).to.equal(Property)
            
            Property = Instance.new("Part")
            TestObject.Property2 = Property
            expect(TestObject.Property2).to.equal(Property)
            expect(function()
                TestObject.Property2 = "Fail"
            end).to.throw("BasePart expected, got string")
            expect(TestObject.Property2).to.equal(Property)
            
            Property = NexusInstance.new()
            TestObject.Property3 = Property
            expect(TestObject.Property3).to.equal(Property)
            expect(function()
                TestObject.Property3 = "Fail"
            end).to.throw("NexusObject expected, got string")
            expect(TestObject.Property3).to.equal(Property)
        end)
    end)
end