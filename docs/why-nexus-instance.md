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