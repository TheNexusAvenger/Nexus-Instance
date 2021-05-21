# Why Nexus Instance
The purpose of Nexus Instance is to simplify classes on
Roblox. Although it isn't supported, `NexusObject` should
work off of Roblox. `NexusInstance` uses Roblox's
`BindableEvent` object, so it will only work on Roblox.

## Simplified Constructor
The main advantage of the Nexus Instance is simplfying
the constructor. This removes the requirement for
knowledge of metamethods.

Example with metamethods:
```lua
local TestClass = {}

--[[
Constructor for TestClass.
--]]
function TestClass.new(Value)
    --Create the base object.
    local Object = {Value = Value}
    setmetatable(Object,TestClass)
    TestClass.__index = TestClass
    
    --Return the object.
    return Object
end

--[[
Returns the value of the class.
--]]
function TestClass:GetValue()
    return self.Value
end

--Create an instance of the class.
local TestObject = TestClass.new(2)
print(TestObject:GetValue()) --2
```

Example:
```lua
local NexusObject = game:GetService("ReplicatedStorage"):WaitForChild("NexusObject")
local NexusInstance = require(NexusObject:WaitForChild("NexusInstance"))
local TestClass = NexusInstance:Extend()

--[[
Constructor for TestClass.
--]]
function TestClass:__new(Value)
    --Set the value.
    self.Value = Value
end

--[[
Returns the value of the class.
--]]
function TestClass:GetValue()
    return self.Value
end

--Create an instance of the class.
local TestObject = TestClass.new(2)
print(TestObject:GetValue()) --2
```

## Improved Extending
Nexus Instance provides the context of "super" objects.
Instanciating the super class can also include parameters
using the `NexusObject:InitializeSuper(...)` function.

Example:
```lua
local NexusObject = game:GetService("ReplicatedStorage"):WaitForChild("NexusObject")
local NexusInstance = require(NexusObject:WaitForChild("NexusInstance"))
local TestClass = NexusInstance:Extend()
local TestSubClass = TestClass:Extend()

--[[
Constructor for TestClass.
--]]
function TestClass:__new(Value)
    --Set the value.
    self.Value = Value
end

--[[
Returns the value of the class.
--]]
function TestClass:GetValue()
    return self.Value
end

--[[
Constructor for TestSubClass.
--]]
function TestSubClass:__new(Value)
    self:InitializeSuper(Value)
end

--[[
Returns the value of the super class plus one.
--]]
function TestClass:GetValuePlusOne()
    return self.super:GetValue() + 1
end

--Create an instance of the class.
local TestObject = TestSubClass.new(2)
print(TestObject:GetValue()) --2
print(TestObject:GetValuePlusOne()) --3
```


## Interfaces

!!! note
    This was added in V.1.1.0. Make sure you are
    using this version or later.

Interfaces exist to enforce the implementation
of behavior. Interfaces can also implement behavior,
but this is not recommended because interfaces are
meant to enforce the implementation of a behavior without
implementing it.

Example:
```lua
local NexusObject = game:GetService("ReplicatedStorage"):WaitForChild("NexusObject")
local NexusInstance = require(NexusObject:WaitForChild("NexusInstance"))
local NexusInterface = require(NexusObject:WaitForChild("NexusInterface"))
local TestClass = NexusInstance:Extend()
TestClass:SetClassName("TestClass")

--Create an interface.
local TestInterface = NexusInterface:Extend()
TestInterface:SetClassName("TestInterface")
TestInterface:MustImplement("Test")
TestClass:Implements(TestInterface)

--[[
Implement the test function. Not doing
this will result in an error for not
implementing the function test.
--]]
function TestClass:Test()
    --Implementation
end


--Create an instance of the class.
local TestObject = TestClass.new()
print(TestObject:IsA("TestClass")) --true
print(TestObject:IsA("TestInterface")) --true
```

## Changed Event
Nexus Instance provides both a `NexusObject` and
a `NexusInstance` class. The `NexusInstance` class
is an extension of `NexusObject` that adds a
`Changed` event and `GetPropertyChangedSignal`
function.

Example:
```lua
local NexusObject = game:GetService("ReplicatedStorage"):WaitForChild("NexusObject")
local NexusInstance = require(NexusObject:WaitForChild("NexusInstance"))
local TestClass = NexusInstance:Extend()

--[[
Constructor for TestClass.
--]]
function TestClass:__new(Value)
    self:InitializeSuper()
    
    --Set the value.
    self.Value = Value
    
    --Set up a basic changed event.
    self.Changed:Connect(function()
        self:HideNextPropertyChange("Value")
        self.Value = self.Value ^ 2
    end)
end

--[[
Returns the value of the class.
--]]
function TestClass:GetValue()
    return self.Value
end

--Create an instance of the class.
local TestObject = TestClass.new(2)
print(TestObject:GetValue()) --2
TestObject.Value = 3
print(TestObject:GetValue()) --9
```

## Property Locking
It may be intended to make a property read only.
Properties can be made explicitly read only using
the `LockProperty` function.

Example:
```lua
local NexusObject = game:GetService("ReplicatedStorage"):WaitForChild("NexusObject")
local NexusInstance = require(NexusObject:WaitForChild("NexusInstance"))
local TestClass = NexusInstance:Extend()

--[[
Constructor for TestClass.
--]]
function TestClass:__new(Value)
    self:InitializeSuper()
    
    --Set the value.
    self.Value = Value
    self:LockProperty("Value")
end

--[[
Returns the value of the class.
--]]
function TestClass:GetValue()
    return self.Value
end

--Create an instance of the class.
local TestObject = TestClass.new(2)
print(TestObject:GetValue()) --2
TestObject.Value = 3
print(TestObject:GetValue()) --"Value is read-only."
```

## Property Validation

!!! note
    This was added in V.1.1.0. Make sure you are
    using this version or later.

Property changes can be validated before set. This
allows for modifying of inputs to correct values,
or throwing errors if the new property is invalid.

Example:
```lua
local NexusObject = game:GetService("ReplicatedStorage"):WaitForChild("NexusObject")
local NexusInstance = require(NexusObject:WaitForChild("NexusInstance"))
local TypePropertyValidator = require(NexusObject:WaitForChild("PropertyValidator"):WaitForChild("NexusInstance"))
local TestClass = NexusInstance:Extend()

--Create and add a property validator.
local TestObject = TestClass.new()
local Valdiator = TypePropertyValidator.new("CFrame")
TestObject:AddPropertyValidator("Location",Validator)

--Set the property.
TestObject.Location = CFrame.new()
TestObject.Location = "Test" --Throws an error
```

## Metamethods

!!! note
    This was added in V.1.1.0. Make sure you are
    using this version or later.

Most of the metamethods can be implemented
into classes directly. This is mostly for
`__tostring`, but can be used for any other
Lua metamethod that isn't `__index` or `__newindex`.

Example:
```lua
local NexusObject = game:GetServic exusObject:WaitForChild("NexusInstance"))
local TestClass = NexusInstance:Extend()

--[[
Constructor for TestClass.
--]]
function TestClass:__new(Value)
    self:InitializeSuper()
    
    --Set the value.
    self.Value = Value
    self:LockProperty("Value")
end

--[[
Returns the object as a string.
--]]
function TestClass:__tostring()
    return "Test: "..self.Value
end

--Create an instance of the class.
local TestObject = TestClass.new(2)
print(tostring(TestObject)) --"Test: 2"
```