# Interfaces

Extending classes is a common method to ensure subclasses
implement methods with a specific implementation. However,
there may be a case where the implementation can only be
determined by the subclass, but you need to ensure a set
of classes implement a method.

## Creating an Interface
`NexusInterface` extends `NexusObject`, meaning that
all methods in `NexusObject` are implemented. To create
an interface, `NexusInterface` needs to be extended.
Since error handling is handled internally, the class name
should also be set.
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sources = ReplicatedStorage:WaitForChild("Sources")
local NexusInterface = require(Sources:WaitForChild("NexusObject"):WaitForChild("NexusInterface"))

--Create a custom interface.
local CustomInterface = NexusInterface:Extend()
CustomInterface:SetClassName("CustomInterface")
```

## Defining Required Methods
To define methods that are required to be implemented,
the method `NexusInterface::MustImplement` should be used.
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sources = ReplicatedStorage:WaitForChild("Sources")
local NexusInterface = require(Sources:WaitForChild("NexusObject"):WaitForChild("NexusInterface"))

--Create a custom interface.
local CustomInterface = NexusInterface:Extend()
CustomInterface:SetClassName("CustomInterface")

--Define some custom functions to implement.
CustomInterface:MustImplement("GetClassName")
CustomInterface:MustImplement("GetName")
```

## Implenting Interfaces
To make a class implement an interface, you need
to use the `NexusObject::Implements`. When this done,
all functions must be implemented or the class can't
be instanciated.
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sources = ReplicatedStorage:WaitForChild("Sources")
local NexusObject = require(Sources:WaitForChild("NexusObject"):WaitForChild("NexusObject"))
local NexusInterface = require(Sources:WaitForChild("NexusObject"):WaitForChild("NexusInterface"))

--Create a custom interface.
local CustomInterface = NexusInterface:Extend()
CustomInterface:SetClassName("CustomInterface")

--Define some custom functions to implement.
CustomInterface:MustImplement("GetClassName")
CustomInterface:MustImplement("GetName")

--Create a class.
local CustomClass = NexusObject:Extend()
CustomClass:SetClassName("CustomClass")
CustomClass:Implements(CustomInterface)

--Implement the methods.
function CustomClass:()
	return self.GetClassName
end

function CustomClass:GetName()
	return "TestClass"
end

--Use the methods.
print(CustomClass:IsA("CustomInterface")) --true
print(CustomClass:GetClassName()) --"CustomClass"
print(CustomClass:GetName()) --"TestClass"
```

## Implementing Methods

!!! warning
	This is supported, but is considered a bad practice.
	It is recommended to use proper classes with inheritance
	for this.

If you want to implement a method for all classes
that implement the behavior, it can be done as if
it was a normal class. This behavior is not recommended
because the purpose of the interfaces is not to define
how a method is implemented.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sources = ReplicatedStorage:WaitForChild("Sources")
local NexusObject = require(Sources:WaitForChild("NexusObject"):WaitForChild("NexusObject"))
local NexusInterface = require(Sources:WaitForChild("NexusObject"):WaitForChild("NexusInterface"))

--Create a custom interface.
local CustomInterface = NexusInterface:Extend()
CustomInterface:SetClassName("CustomInterface")

--Define some custom functions to implement.
CustomInterface:MustImplement("GetClassName")

--Implement a method in the interface.
function CustomInterface:GetName()
	return "TestClass"
end

--Create a class.
local CustomClass = NexusObject:Extend()
CustomClass:SetClassName("CustomClass")
CustomClass:Implements(CustomInterface)

--Implement the method.
function CustomClass:()
	return self.GetClassName
end

--Use the methods.
print(CustomClass:IsA("CustomInterface")) --true
print(CustomClass:GetClassName()) --"CustomClass"
print(CustomClass:GetName()) --"TestClass"
```