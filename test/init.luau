--Tests NexusInstance.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusInstance = require(ReplicatedStorage:WaitForChild("NexusInstance"))

return function()
    --Events cleared on Destroy are invoked with task.defer, which will fire events in immediate events
    --before the task.defer, but not with deferred events.
    local IsImmediateMode = false
    beforeAll(function()
        local EventImmediatelyCalled = false
        local Event = Instance.new("BindableEvent")
        Event.Event:Once(function()
            EventImmediatelyCalled = true
        end)
        Event:Fire()
        IsImmediateMode = EventImmediatelyCalled
    end)

    describe("A NexusInstance with a simple class", function()
        local TestClass1 = {}
        TestClass1.__index = TestClass1

        type TestClass1 = {
            TestProperty: string,
        } & typeof(setmetatable({}, TestClass1))

        function TestClass1.__new(self: NexusInstance.NexusInstance<TestClass1>, Input: string)
            self.TestProperty = Input
        end

        function TestClass1.TestFunction(self: NexusInstance.NexusInstance<TestClass1>, NewValue: string): ()
            self.TestProperty = NewValue
        end

        function TestClass1.__tostring(self: NexusInstance.NexusInstance<TestClass1>)
            return `TestClass1_{self.TestProperty}`
        end

        function TestClass1.Destroy(self: NexusInstance.NexusInstance<TestClass1>)
            self.TestProperty = "DESTROYED"
        end

        local TestClass1NexusInstance = NexusInstance.ToInstance(TestClass1) :: NexusInstance.NexusInstanceClass<typeof(TestClass1), (Input: string) -> (NexusInstance.NexusInstance<TestClass1>)>
        local TestObject = nil
        beforeEach(function()
            TestObject = TestClass1NexusInstance.new("TestValue")
        end)
        afterEach(function()
            TestObject:Destroy()
        end)

        it("should call the constructor.", function()
            expect(TestObject.TestProperty).to.equal("TestValue")
        end)

        it("should copy metamethods.", function()
            expect(tostring(TestObject)).to.equal("TestClass1_TestValue")
        end)

        it("should expose class functions.", function()
            TestObject:TestFunction("NewValue")
            expect(TestObject.TestProperty).to.equal("NewValue")
        end)

        it("should call changed events.", function()
            local ChangedProperty = nil
            TestObject.Changed:Connect(function(PropertyName)
                ChangedProperty = PropertyName
            end)

            TestObject.TestProperty = "NewValue"
            task.wait()
            expect(ChangedProperty).to.equal("TestProperty")
            expect(TestObject.TestProperty).to.equal("NewValue")
        end)

        it("should call not changed events when nothing changes.", function()
            local ChangedProperty = nil
            TestObject.Changed:Connect(function(PropertyName)
                ChangedProperty = PropertyName
            end)

            TestObject.TestProperty = "TestValue"
            task.wait()
            expect(ChangedProperty).to.equal(nil)
            expect(TestObject.TestProperty).to.equal("TestValue")
        end)

        it("should create events.", function()
            local TestEvent = TestObject:CreateEvent() :: NexusInstance.TypedEvent<string>
            local FiredString = nil
            TestEvent:Connect(function(Value)
                FiredString = Value
            end)

            TestEvent:Fire("Test")
            task.wait()
            expect(FiredString).to.equal("Test")
        end)

        it("should add generic transforms.", function()
            TestObject:AddGenericPropertyTransform(function(Name, Value)
                return `{Name}_{Value}`
            end)

            TestObject.TestProperty = "NewValue"
            expect(TestObject.TestProperty).to.equal("TestProperty_NewValue")
        end)

        it("should add property transforms.", function()
            TestObject:AddPropertyTransform("TestProperty", function(Value)
                return `{Value}_2`
            end)

            TestObject.TestProperty = "NewValue"
            expect(TestObject.TestProperty).to.equal("NewValue_2")
        end)

        it("should invoke any property change callbacks.", function()
            local ChangedPropertyName, ChangedValue = nil, nil
            TestObject:OnAnyPropertyChanged(function(PropertyName, Value)
                ChangedPropertyName = PropertyName
                ChangedValue = Value
            end)

            TestObject.TestProperty = "NewValue"
            expect(ChangedPropertyName).to.equal("TestProperty")
            expect(ChangedValue).to.equal("NewValue")
            expect(TestObject.TestProperty).to.equal("NewValue")
        end)

        it("should invoke property change callbacks.", function()
            local ChangedValue = nil
            TestObject:OnPropertyChanged("TestProperty", function(Value)
                ChangedValue = Value
            end)

            TestObject.TestProperty = "NewValue"
            expect(ChangedValue).to.equal("NewValue")
            expect(TestObject.TestProperty).to.equal("NewValue")
        end)

        it("should hide property changes.", function()
            local ChangedCalled, ChangedPropertyCalled = false, false
            TestObject.Changed:Connect(function()
                ChangedCalled = true
            end)
            TestObject:GetPropertyChangedSignal("TestProperty"):Connect(function()
                ChangedPropertyCalled = true
            end)

            TestObject:HidePropertyChanges("TestProperty")
            TestObject.TestProperty = "NewValue1"
            task.wait()
            expect(ChangedCalled).to.equal(false)
            expect(ChangedPropertyCalled).to.equal(false)

            TestObject.TestProperty = "NewValue2"
            task.wait()
            expect(ChangedCalled).to.equal(false)
            expect(ChangedPropertyCalled).to.equal(false)
        end)

        it("should hide next property changes.", function()
            local ChangedCalled, ChangedPropertyCalled = false, false
            TestObject.Changed:Connect(function()
                ChangedCalled = true
            end)
            TestObject:GetPropertyChangedSignal("TestProperty"):Connect(function()
                ChangedPropertyCalled = true
            end)

            TestObject:HideNextPropertyChange("TestProperty")
            TestObject.TestProperty = "NewValue1"
            task.wait()
            expect(ChangedCalled).to.equal(false)
            expect(ChangedPropertyCalled).to.equal(false)

            TestObject.TestProperty = "NewValue2"
            task.wait()
            expect(ChangedCalled).to.equal(true)
            expect(ChangedPropertyCalled).to.equal(true)
        end)

        it("should call changed events for properties.", function()
            local ChangedPropertyCalled = false
            TestObject:GetPropertyChangedSignal("TestProperty"):Connect(function()
                ChangedPropertyCalled = true
            end)

            TestObject.TestProperty = "NewValue"
            task.wait()
            expect(ChangedPropertyCalled).to.equal(true)
            expect(TestObject.TestProperty).to.equal("NewValue")
        end)

        it("should not call changed events for properties with no changes.", function()
            local ChangedPropertyCalled = false
            TestObject:GetPropertyChangedSignal("TestProperty"):Connect(function()
                ChangedPropertyCalled = true
            end)

            TestObject.TestProperty = "TestValue"
            task.wait()
            expect(ChangedPropertyCalled).to.equal(false)
            expect(TestObject.TestProperty).to.equal("TestValue")
        end)

        it("should call the destroy function.", function()
            TestObject:Destroy()
            expect(TestObject.TestProperty).to.equal("DESTROYED")
        end)

        it("should disconnect events.", function()
            local TestEvent = TestObject:CreateEvent() :: NexusInstance.TypedEvent<string>
            local FiredString = nil
            TestEvent:Connect(function(Value)
                FiredString = Value
            end)

            TestObject:Destroy()
            if IsImmediateMode then task.wait() end
            TestEvent:Fire("Test")
            task.wait()
            expect(FiredString).to.equal(nil)
        end)

        it("should allow for events to complete when destroying.", function()
            local FiredString = nil
            TestObject:GetPropertyChangedSignal("TestProperty"):Connect(function()
                FiredString = TestObject.TestProperty
            end)

            TestObject:Destroy()
            task.wait()
            expect(FiredString).to.equal("DESTROYED")
        end)
    end)

    describe("A NexusInstance with a simple class with no constructor or destroy", function()
        local TestClass2 = {}
        TestClass2.__index = TestClass2

        type TestClass2 = typeof(setmetatable({}, TestClass2))

        local TestClass2NexusInstance = NexusInstance.ToInstance(TestClass2) :: NexusInstance.NexusInstanceClass<typeof(TestClass2), (Input: string) -> (NexusInstance.NexusInstance<TestClass2>)>
        local TestObject = nil
        beforeEach(function()
            TestObject = TestClass2NexusInstance.new("TestValue")
        end)
        afterEach(function()
            TestObject:Destroy()
        end)

        it("should disconnect events.", function()
            local TestEvent = TestObject:CreateEvent() :: NexusInstance.TypedEvent<string>
            local FiredString = nil
            TestEvent:Connect(function(Value)
                FiredString = Value
            end)

            TestObject:Destroy()
            if IsImmediateMode then task.wait() end
            TestEvent:Fire("Test")
            task.wait()
            expect(FiredString).to.equal(nil)
        end)
    end)

    describe("A NexusInstance with a subclass", function()
        local TestClass3 = {}
        TestClass3.__index = TestClass3

        type TestClass3 = {
            TestProperty1: string,
        } & typeof(setmetatable({}, TestClass3))

        function TestClass3.__new(self: NexusInstance.NexusInstance<TestClass3>, Input: string)
            self.TestProperty1 = Input
        end

        function TestClass3.TestFunction1(self: NexusInstance.NexusInstance<TestClass3>, NewValue: string): ()
            self.TestProperty1 = NewValue
        end

        function TestClass3.__tostring(self: NexusInstance.NexusInstance<TestClass3>)
            return `TestClass3_{self.TestProperty1}`
        end

        local TestClass3NexusInstance = NexusInstance.ToInstance(TestClass3) :: NexusInstance.NexusInstanceClass<typeof(TestClass3), (Input: string) -> (NexusInstance.NexusInstance<TestClass3>)>
        
        local TestClass4 = {}
        TestClass4.__index = TestClass4
        setmetatable(TestClass4, TestClass3NexusInstance) --TestClass3NexusInstance would be returned instead of TestClass3.

        type TestClass4 = {
            TestProperty2: string,
        } & typeof(setmetatable({}, TestClass4)) & TestClass3

        function TestClass4.__new(self: NexusInstance.NexusInstance<TestClass4>, Input1: string, Input2: string)
            TestClass3.__new(self, Input1)
            self.TestProperty2 = Input2
        end

        function TestClass4.TestFunction2(self: NexusInstance.NexusInstance<TestClass4>, NewValue: string): ()
            self.TestProperty2 = NewValue
        end
        
        function TestClass4.__tostring(self: NexusInstance.NexusInstance<TestClass4>)
            return `TestClass4_{self.TestProperty1}_{self.TestProperty2}`
        end

        local TestClass4NexusInstance = NexusInstance.ToInstance(TestClass4) :: NexusInstance.NexusInstanceClass<typeof(TestClass4), (Input1: string, Input2: string) -> (NexusInstance.NexusInstance<TestClass4>)>
        
        local TestObject = nil
        beforeEach(function()
            TestObject = TestClass4NexusInstance.new("TestValue1", "TestValue2")
        end)
        afterEach(function()
            TestObject:Destroy()
        end)

        it("should call the constructor.", function()
            expect(TestObject.TestProperty1).to.equal("TestValue1")
            expect(TestObject.TestProperty2).to.equal("TestValue2")
        end)

        it("should copy correct metamethods.", function()
            expect(tostring(TestObject)).to.equal("TestClass4_TestValue1_TestValue2")
        end)

        it("should expose all functions.", function()
            TestObject:TestFunction1("NewValue1")
            TestObject:TestFunction2("NewValue2")
            expect(TestObject.TestProperty1).to.equal("NewValue1")
            expect(TestObject.TestProperty2).to.equal("NewValue2")
        end)
    end)
end