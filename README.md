# Nexus-Instance
Nexus Instance is a framework meant to simplify the
creation of classes in Lua. The framework
includes a base `NexusObject` class, as well as a more
powerful `NexusInstance` class to allow for locking
of properties and a `Changed` event.

## Usage
### Creating Classes
Nexus Instance provides 2 classes meant for creating
classes: `NexusObject` and `NexusInstance`. `NexusInstance`
extends `NexusObject` to allow for events for when
properties change, but it has a performance cost.
Both of them can be extended using the `Extend` method
and optionally `SetClassName` after that to set the
class name used with `IsA`. Typing is covered in a
separate section.

```lua
local MyClass1 = NexusObject:Extend():SetClassName("MyClass1") --NexusObject can be swapped with NexusInstance.
local MyClass2 = MyClass1:Extend():SetClassName("MyClass2")

local MyObject1 = MyClass1.new() --Creates an instance of MyClass1
print(MyObject1.ClassName) --MyClass1
print(MyObject1:IsA("NexusObject")) --true
print(MyObject1:IsA("MyClass1")) --true
print(MyObject1:IsA("MyClass2")) --false
local MyObject2 = MyClass2.new() --Creates an instance of MyClass2
print(MyObject2.ClassName) --MyClass1
print(MyObject2:IsA("NexusObject")) --true
print(MyObject2:IsA("MyClass1")) --true
print(MyObject2:IsA("MyClass2")) --true
```

To initialize the class, `__new()` can be defined for each
class that requires initialization. In the constructor,
`__new(self, ...)` is used to call the parent constructor.
**Calling this is not enforced - be aware of missing calls.**

```lua
local MyClass1 = NexusObject:Extend():SetClassName("MyClass1")
local MyClass2 = MyClass1:Extend():SetClassName("MyClass2")

function MyClass1:__new(Value1)
    NexusObject.__new(self) --NexusObject requires no parameters.
    self.Value1 = Value1
end

function MyClass2:__new(Value1, Value2)
    MyClass1.__new(self, Value1) --MyClass1 requires a paramter.
    self.Value2 = Value2
end

local MyObject1 = MyClass1.new("MyValue1")
print(MyObject1.Value1) --MyValue1
print(MyObject1.Value2) --nil
local MyObject2 = MyClass2.new("MyValue1", "MyValue2")
print(MyObject2.Value1) --MyValue1, defined in the constructor for MyClass1
print(MyObject2.Value2) --MyValue2
```

In addition to `__new`, custom functions can be defined. Classes
can override functions of super classes as well. Metatable passthrough
is also supported.

```lua
local MyClass1 = NexusObject:Extend():SetClassName("MyClass1")
local MyClass2 = MyClass1:Extend():SetClassName("MyClass2")

function MyClass1:__new(Value1)
    NexusObject.__new(self)
    self.Value1 = Value1
end

function MyClass1:GetValue()
    return self.Value1
end

function MyClass2:__new(Value1, Value2)
    MyClass1.__new(self, Value1)
    self.Value2 = Value2
end

function MyClass2:GetValue()
    return self.Value1.."_"..self.Value2
end

function MyClass2:__tostring()
    return self.Value2
end

local MyObject1 = MyClass1.new("MyValue1")
print(MyObject1:GetValue()) --MyValue1
local MyObject2 = MyClass2.new("MyValue1", "MyValue2")
print(MyObject2:GetValue()) --MyValue1_MyValue2
print(tostring(MyObject2)) --MyValue2
```

### `NexusInstance` Additions
`NexusInstance` provides several more functions for managing
`Changed` events. When a property is changed, the lifecycle
of the change includes:
1. Throw an error if the property was set to read-only using `LockProperty(PropertyName: string)`.
2. Ignore sending any changed events if the value is the same.
3. Run any property validators added using `AddGenericPropertyValidator(Validator: (string, any) -> (any))`.
4. Run any property validators added using `AddPropertyValidator(PropertyName: string, Validator: (string, any) -> (any))`.
5. Update the property.
6. Run any property finalizers added using `AddGenericPropertyFinalizer(Finalizer: (string, any) -> ())` to bypass deferred events.
7. Run any property finalizers added using `AddPropertyFinalizer(PropertyName: string, Finalizer: (string, any) -> ())` to bypass deferred events.
8. Invoke any changed events connected to from `GetPropertyChangedSignal(PropertyName: string)`.
9. Fire the `Changed` event as long as the property was not hidden using `HidePropertyChanges(PropertyName: string)`.

With the changed events is a `Destroy` method that will disconnect
the changed events. Classes that extend `NexusInstance` should
make sure to call the `Destroy` method if it is overriden.

```lua
local MyClass = NexusInstance:Extend():SetClassName("MyClass")

function MyClass:Destroy()
    NexusInstance.Destroy(self) --Calls NexusInstance:Destroy()
    --Some other Destroy logic here.
end
```

### Events
`NexusEvent` is included for creating custom events that can
be listened to and invoked. Unlike `BindableEvent`s, `NexusEvent`
do not modify the passed variables, but still internally use
`BindableEvent`s to use Roblox's event scheduling. Typing is
covered in another section.

```lua
local MyEvent = NexusEvent.new()
MyEvent:Connect(function(Value1, Value2, Value)
    print(Value1) --1
    print(Value2) --2
    print(Value3) --3
end)

task.spawn(function()
    local Value1, Value2, Value3 = MyEvent:Wait()
    print(Value1) --1
    print(Value2) --2
    print(Value3) --3
end)

MyEvent:Fire(1, 2, 3)
MyEvent:Disconnect() --Disconnects all connections.
```

### Typing
Typing for metatables is complicated in Luau. The recommended
pattern for typing is the following:

```lua
--Extend the class.
local MyClass = NexusObject:Extend():SetClassName("MyClass") --Or NexusInstance, or any other class.

--Create the type. The type name is arbitrary (can be MyClass).
--new should be set with the constructor and return, regardless if it matches the super.
--Extend should be set with the class.
--The union of the parent type must be after the type definition.
export type MyClassType = {
    new: () -> MyClassType,
    Extend: (self: MyClassType) -> MyClassType,

    --Custom properties and methods can be defined here.
    MyProperty: string,
    MyEvent: NexusEvent.NexusEvent<string, number>, --NexusEvents support typing.
    MyMethod: (self: MyClassType, Value: string) -> (number),
} & NexusObject.NexusObject --Or NexusInstance.NexusInstance, or any other type definition.

--Define any functions.
function MyClass:__new(): ()
    NexusObject.__new(self)
    self.MyProperty = "MyProperty"
    self.MyEvent = NexusEvent.new() --From NexusInstance.Event.NexusEvent
end

function MyClass:MyMethod(Value: string): number
    return 5
end

--Return the class with the type casted.
return MyClass :: MyClassType
```

## Contributing
Both issues and pull requests are accepted for this project.

## License
Nexus Instance is available under the terms of the MIT 
Licence. See [LICENSE](LICENSE) for details.