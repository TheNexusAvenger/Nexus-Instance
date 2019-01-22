# NexusObject

`NexusObject` is the root object that is used for extending.
It contains the least amount of functionality, with the rest
expected to be implemented by extending the class. `NexusObject`
may work in a vanilla Lua environment, but Roblox is the only
environment it is validated for.

### `NexusObject.ClassName`
The class name of the object. By default, this will
be `"NexusObject"`, but isn't locked.

!!! note
    If the class name isn't overriden, it will inherit
    from the class it extends from.

### `NexusObject.super`
The super class of the object. If the object has called
`NexusObject::InitializeSuper`, then `super` will reflect
a partial instanciation of the class. If it isn't called,
then `super` will represent the static class it inherits from.
For `NexusObject`, this will be `nil` since it is the
root class.

### `NexusObject.new()`
Creates an instance of `NexusObject`. It isn't intended
to be used since it should be extended.

### `NexusObject:__new()`
Base constructor of `NexusObject`. When an object extends
`NexusObject`, this function should be overriden by the
constructor required for that class. For `NexusObject`,
this function is empty.

### `NexusObject:__extended(OtherObject)`
Called after the constructor for `NexusObject::InitializeSuper`
when a class (Lua table) extends the base object. The
only intended use case is for where modifying
the Lua Metatables is required. It can also be used to
check if an extension implements a set of functions,
but it isn't supported or tested for.
!!! note
    When this function is overriden, it isn't called
    explicitly to the next super class. It is recommended to
    have `self.super:__extended(OtherObject)` if this function
    is overriden. If it isn't, this done implicitly.

### `NexusObject:InitializeSuper(...)`
Initializes the super class. The paramters given by `...`
are passed into the constructor of the super class (`__new(...)`).
It should be called in the constructor of the class.

### `NexusObject:SetClassName(ClassName)`
Sets the class name of the object. It should be called staticly
(ex: `ExtendedClass:SetClassName("ClassName")`, not
`self:SetClassName("ClassName")`).

### `NexusObject:IsA(ClassName)`
Returns if the object is or inherits from a class
with the given class name.

### `NexusObject:Extend()`
Extends a class to allow for implementing properties and
functions while inheriting the super class's behavior.