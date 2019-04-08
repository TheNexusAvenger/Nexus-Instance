# NexusInterface
(Extends [NexusObject](nexusobject.md))

`NexusInterface` provides defining of the interface of
a class without defining the implementation.

### `static NexusInterface.ClassName`
The class name of the object. By default, this will
be `"NexusInterface"`.

### `static NexusInterface:MustImplement(PropertyName)`
Sets an attribute as required for an object. Although
it is intended to be a name of a function, it can be
any type, and can be implemented after the constructor
is run.

### `static NexusInterface:GetMissingAttributes(Object)`
Returns a list of the missing attributes from an object
based on the interface. If no attributes are missing,
an empty list is returned.