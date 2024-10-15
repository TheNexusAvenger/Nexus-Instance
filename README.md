# Nexus-Instance
Nexus Instance is a utility for creating custom instances
with property change events while still providing proper
typing in Luau.

## Usage
### Simple Classes
Classes with metatables are created mostly the same, except:
- `NexusInstance.ToInstance` is called before using or returning
  the class.
- The recommended type of `self` becomes `NexusInstance<Class>`.

The return type of `NexusInstance.ToInstance` is
`NexusInstanceClass<TClass, TObject, TConstructor>`, which should be
casted to. The generic types are:
- `TClass`: Type of the class without properties. Typically will be
  `typeof(MyClass)` where `MyClass` is the table of the class.
- `TConstructor`: Type of the constructor function. It should be the
  arguments of `new(...)` with the return of `NexusInstance<MyClass>`.

```luau
--!strict
local NexusInstance = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance"))

local TestClass = {}
TestClass.__index = TestClass

--Exported test class type and Nexus Instance version (optional).
export type TestClass = {
    TestProperty: string,
} & typeof(setmetatable({}, TestClass))
export type NexusInstanceTestClass = NexusInstance.NexusInstance<TestClass>

--Optional constructor when `new` is called.
function TestClass.__new(self: NexusInstanceTestClass, Argument: string): ()
    self.TestProperty = Argument
end

--Custom function.
function TestClass.ChangeValue(self: NexusInstanceTestClass, NewValue: string): ()
    self.TestProperty = NewValue
end

--Optional destroy function to clear resources.
--Events are cleaned internally (`Changed`, `GetPropertyChangedSignal`, and `CreateEvent` only).
--The version returned by NexusInstance.ToInstance will always have a Destroy method.
function TestClass.Destroy(self: NexusInstanceTestClass): ()
    --Clear resources.
end

--Create the class to return in the ModuleScript, or use within the script.
--The constructor (second generic type) should match inputs for `__new` without the `self`.
local ReturnedTestClass = NexusInstance.ToInstance(TestClass) :: NexusInstance.NexusInstanceClass<typeof(TestClass), (Argument: string) -> (NexusInstanceTestClass)>



--Create and destroy the type.
local TestObject = ReturnedTestClass.new("TestValue")
print(TestObject.TestProperty) --"TestValue"
TestObject:ChangeValue("NewValue")
print(TestObject.TestProperty) --"NewValue"
TestObject:Destroy()
```

`__new` and `Destroy` are not required and can be omitted.

```luau
--!strict
local NexusInstance = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance"))

local TestClass = {}
TestClass.__index = TestClass

--Exported test class type and Nexus Instance version (optional).
export type TestClass = {
    TestProperty: string?, --No constructor initializes this.
} & typeof(setmetatable({}, TestClass))
export type NexusInstanceTestClass = NexusInstance.NexusInstance<TestClass>

--Custom function.
function TestClass.ChangeValue(self: NexusInstanceTestClass, NewValue: string): ()
    self.TestProperty = NewValue
end

--Create the class to return in the ModuleScript, or use within the script.
local ReturnedTestClass = NexusInstance.ToInstance(TestClass) :: NexusInstance.NexusInstanceClass<typeof(TestClass), () -> (NexusInstanceTestClass)>



--Create and destroy the type.
local TestObject = ReturnedTestClass.new()
print(TestObject.TestProperty) --nil
TestObject:ChangeValue("NewValue")
print(TestObject.TestProperty) --"NewValue"
TestObject:Destroy()
```

### Inheritance
Inheritance is nearly the same as doing so with metatables, except for
the calls to `NexusInstance.ToInstance`.

```luau
--!strict
local NexusInstance = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance"))

--Define TestClass1 (potentially in a ModuleScript).
local TestClass1 = {}
TestClass1.__index = TestClass1

export type TestClass1 = {
    TestProperty1: string,
} & typeof(setmetatable({}, TestClass1))
export type NexusInstanceTestClass1 = NexusInstance.NexusInstance<TestClass1>

function TestClass1.__new(self: NexusInstanceTestClass1, Input: string)
    self.TestProperty1 = Input
end

function TestClass1.ChangeValue1(self: NexusInstanceTestClass1, NewValue: string): ()
    self.TestProperty1 = NewValue
end

local TestClass1NexusInstance = NexusInstance.ToInstance(TestClass1) :: NexusInstance.NexusInstanceClass<typeof(TestClass1), (Input: string) -> (NexusInstanceTestClass1)>



--Define TestClass2 (potentially in a different ModuleScript).
local TestClass2 = {}
TestClass2.__index = TestClass2
setmetatable(TestClass2, TestClass1NexusInstance) --TestClass1NexusInstance would be returned instead of TestClass1.

export type TestClass2 = {
    TestProperty2: string,
} & typeof(setmetatable({}, TestClass2)) & TestClass1
export type NexusInstanceTestClass2 = NexusInstance.NexusInstance<TestClass2>

function TestClass2.__new(self: NexusInstanceTestClass2, Input1: string, Input2: string)
    TestClass1.__new(self, Input1) --Remember to call the parent constructor!
    self.TestProperty2 = Input2
end

function TestClass2.ChangeValue2(self: NexusInstanceTestClass2, NewValue: string): ()
    self.TestProperty2 = NewValue
end

local TestClass2NexusInstance = NexusInstance.ToInstance(TestClass2) :: NexusInstance.NexusInstanceClass<typeof(TestClass2), (Input1: string, Input2: string) -> (NexusInstanceTestClass2)>
        


--Use the classes.
local TestObject1 = TestClass1NexusInstance.new("TestValue1")
print(TestObject1.TestProperty1) --"TestValue1"
TestObject1:ChangeValue1("NewValue1")
print(TestObject1.TestProperty1) --"NewValue1"
TestObject1:Destroy()

local TestObject2 = TestClass2NexusInstance.new("TestValue1", "TestValue2")
print(TestObject2.TestProperty1) --"TestValue1"
print(TestObject2.TestProperty2) --"TestValue2"
TestObject2:ChangeValue1("NewValue1")
TestObject2:ChangeValue2("NewValue2")
print(TestObject2.TestProperty1) --"NewValue1"
print(TestObject2.TestProperty2) --"NewValue2"
TestObject2:Destroy()
```

### Metatable Passthrough
Classes can define some metatable methods, which will be passed
through. `__index` and `__newindex` are not supported for this.

```luau
--!strict
local NexusInstance = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance"))

local TestClass = {}
TestClass.__index = TestClass

--Exported test class type and Nexus Instance version (optional).
export type TestClass = typeof(setmetatable({}, TestClass))
export type NexusInstanceTestClass = NexusInstance.NexusInstance<TestClass>

--__tostring metatable method.
function TestClass.__tostring(self: NexusInstanceTestClass): ()
    return "TestClass"
end

--Create the class to return in the ModuleScript, or use within the script.
local ReturnedTestClass = NexusInstance.ToInstance(TestClass) :: NexusInstance.NexusInstanceClass<typeof(TestClass), () -> (NexusInstanceTestClass)>



--Create and destroy the type.
local TestObject = ReturnedTestClass.new()
print(tostring(TestObject)) --"TestClass"
TestObject:Destroy()
```

### Property Changes
Similar to normal Roblox `Instance`s, there is a `Changed` event
that is fired when any property changes, and `GetPropertyChangedSignal`
to listen to a specific property changing.

```luau
TestObject.Changed:Connect(function(PropertyName)
    print(`Property {PropertyName} changed.`)
end)
TestObject:GetPropertyChangedSignal("TestProperty"):Connect(function()
    print("PropertyName changed.")
end)
```

Changed events can be ignored using `HidePropertyChanges`.
`HideNextPropertyChange` can be used to only hide the next property change.

```luau
TestObject.Changed:Connect(function(PropertyName)
    print(`Property {PropertyName} changed.`)
end)
TestObject:GetPropertyChangedSignal("TestProperty"):Connect(function()
    print("PropertyName changed.")
end)

TestObject:HidePropertyChanges("TestProperty") --This makes it so changed events never invokes for TestProperty.
TestObject:HideNextPropertyChange("TestProperty") --This makes it so only the next changed event doesn't get invoked for TestProperty.
```

`OnAnyPropertyChanged` and `OnPropertyChanged` also exist. Unlike
the events, they will immediately invoke after a property change
(as opposed to waiting on deferred events). They do not respect
hidden changed events and will always be invoked.

```luau
TestObject:OnAnyPropertyChanged(function(PropertyName, Value)
    print(`Property {PropertyName} changed to {Value}.`)
end)
TestObject:OnPropertyChanged("TestProperty", function(Value)
    print(`TestProperty changed to {Value}.`)
end)
```

### Property Transformers
When a property is set, it is able to be transformed before
being stored and invoked with changed events. Generic transforms
will always run before property-speicifc ones.

```luau
TestObject:AddGenericPropertyTransform(function(Index, Value)
    return `{Value}_{Index}_1`
end)
TestObject:OnAnyPropertyChanged("TestProperty", function(Value)
    return `{Value}_2`
end)

TestObject.TestProperty = "NewValue"
print(TestObject.TestProperty) --"NewValue_TestProperty_1_2"
```

### Custom Events
`TypedEvent` exists for custom events. Compared to `BindableEvent`:
- `TypedEvent`s have typing for the arguments.
- Arguments that are passed retain their original table/function
  references, instead of being encoded away.

`CreateEvent` is always recommended unless being used outside
of an instance, since `CreateEvent` will handle disconnecting
the event when the instance is destroyed.

```luau
--!strict
local NexusInstance = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusInstance"))

local TestClass = {}
TestClass.__index = TestClass

--Exported test class type and Nexus Instance version (optional).
export type TestClass = {
    TestEvent: NexusInstance.TypedEvent<string>,
} & typeof(setmetatable({}, TestClass))
export type NexusInstanceTestClass = NexusInstance.NexusInstance<TestClass>

--Optional constructor when `new` is called.
function TestClass.__new(self: NexusInstanceTestClass): ()
    self.TestEvent = self:CreateEvent() :: NexusInstance.TypedEvent<string>
end

--Create the class to return in the ModuleScript, or use within the script.
local ReturnedTestClass = NexusInstance.ToInstance(TestClass) :: NexusInstance.NexusInstanceClass<typeof(TestClass), () -> (NexusInstanceTestClass)>



--Create and destroy the type.
local TestObject = ReturnedTestClass.new()
TestObject.TestEvent:Connect(function(Message)
    print(Message)
end)
TestObject.TestEvent:Fire("Test message") --Prints "Test message"
task.wait() --Required with deferred events, otherwise, Destroy beats the event being fired.
TestObject:Destroy() --Disconnects TestEvent.
```

## Contributing
Both issues and pull requests are accepted for this project.

## License
Nexus Instance is available under the terms of the MIT 
License. See [LICENSE](LICENSE) for details.