# NexusObject

`NexusObject` is the root object that is used for extending.
It contains the least amount of functionality, with the rest
expected to be implemented by extending the class. `NexusObject`
may work in a vanilla Lua environment, but Roblox is the only
environment it is validated for.

### `static NexusObject.ClassName`
The class name of the object. By default, this will
be `"NexusObject"`, but isn't locked.

!!! note
    If the class name isn't overriden, it will inherit
    from the class it extends from.

### `static NexusObject.new()`
Creates an instance of `NexusObject`. It isn't intended
to be used since it should be extended.

### `static NexusObject:__classextended(OtherClass)`
Called after extending when another class extends
the class. The purpose of this is to add attributes
to the class.
!!! note
    When this function is overriden, it isn't called
    explicitly to the next super class. It is recommended to
    have `self.super:__classextended(OtherClass)` if this function
    is overriden. If it isn't, this done implicitly.

### `static NexusObject:__createindexmethod(Object,Class,RootClass)
Creates the `__index` metamethod for an object. Used to
setup custom indexing.

### `static NexusObject:SetClassName(ClassName)`
Sets the class name of the object. It should be called staticly
(ex: `ExtendedClass:SetClassName("ClassName")`, not
`self:SetClassName("ClassName")`).

### `static NexusObject:Implements(NexusInterface)`
Sets the class as implementing a given interface. It should 
be called staticly (ex: `ExtendedClass:Implements(Interface)`,
not `self:Implements(Interface)`).

### `static NexusObject:GetInterfaces()`
Returns a list of the interfaces that the class implements.
This includes ones implemented by super classes.

### `NexusObject.super`
The super class of the object. If the object has called
`NexusObject::InitializeSuper`, then `super` will reflect
a partial instanciation of the class. If it isn't called,
then `super` will represent the static class it inherits from.
For `NexusObject`, this will be `nil` since it is the
root class.

### `NexusObject:__new()`
Base constructor of `NexusObject`. When an object extends
`NexusObject`, this function should be overriden by the
constructor required for that class. For `NexusObject`,
this function is empty.

### `NexusObject:InitializeSuper(...)`
Initializes the super class. The paramters given by `...`
are passed into the constructor of the super class (`__new(...)`).
It should be called in the constructor of the class.

### `NexusObject:IsA(ClassName)`
Returns if the object is or inherits from a class
with the given class name.

### `NexusObject:Extend()`
Extends a class to allow for implementing properties and
functions while inheriting the super class's behavior.