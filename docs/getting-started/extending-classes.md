# Extending Classes

## Extending a Class
Any class that inherits from `NexusObject` can be extended.
Extending can be done by using `NexusObject::Extend` on the
base class.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sources = ReplicatedStorage:WaitForChild("Sources")
local NexusObject = require(Sources:WaitForChild("NexusObject"):WaitForChild("NexusObject"))

--Base extension of NexusObject.
local ExtendedClass = NexusObject:Extend()

--Base extension of ExtendedClass (inherits from NexusObject).
local ExtendedClass2 = ExtendedClass:Extend()
```

## Setting the `ClassName`
`NexusObject` includes an `IsA` function for checking if 
an object inherits from a class. All objects will inherit
from `NexusObject`, so `IsA("NexusObject")` will always
return true. A custom class name can be added to any class
using `NexusObject::SetClassName`, which should always be
called on the static class.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sources = ReplicatedStorage:WaitForChild("Sources")
local NexusObject = require(Sources:WaitForChild("NexusObject"):WaitForChild("NexusObject"))

--Base extension of NexusObject.
local ExtendedClass = NexusObject:Extend()
ExtendedClass:SetClassName("ExtendedClass")

print(ExtendedClass:IsA("ExtendedClass")) --true
print(ExtendedClass:IsA("NexusObject")) --true
print(ExtendedClass:IsA("Instance")) --false
```

## Overriding the Constructor
Objects can be created by calling `.new(...)`, which
will handle the new class. To handle a custom constructor,
`NexusObject::__new" can be overriden. To set up the super
class, `NexusObject::InitializeSuper` can be called. By default,
the default constructor calls `NexusObject::InitializeSuper`
with the same arguments.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sources = ReplicatedStorage:WaitForChild("Sources")
local NexusObject = require(Sources:WaitForChild("NexusObject"):WaitForChild("NexusObject"))

--Base extension of NexusObject.
local ExtendedClass = NexusObject:Extend()
ExtendedClass:SetClassName("ExtendedClass")

--Overrides the constructor.
function ExtendedClass:__new(Value1,Value2)
	self.Value1 = Value1
	self.Value2 = Value2
end

--Base extension of ExtendedClass.
local ExtendedClass2 = ExtendedClass:Extend()
ExtendedClass2:SetClassName("ExtendedClass2")

--Overrides the constructor.
function ExtendedClass2:__new(...)
	self:InitializeSuper(...)
	self.Value3 = self.Value1 + self.Value2
end

--Create the object.
local ExtendedObject2 = ExtendedClass2.new(1,2)
```