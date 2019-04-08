# NexusInstance
(Extends [NexusObject](nexusobject.md))

`NexusInstance` is an extension of `NexusObject` to add
an event for changes to properties and locking properties.
The documentation below is only for what is overriden or
implemented by `NexusInstance`. Everything else from
`NexusObject` is inherited.

### `static NexusInstance.ClassName`
The class name of the object. By default, this will
be `"NexusInstance"` and is locked by the constructor.

### `static NexusInstance.new()`
Creates an instance of `NexusInstance`. It isn't intended
to be used since it should be extended.

### `NexusInstance.Changed`
A [`NexusEvent`](event/nexusevent.md) that is invoked when a property
change is made. When a change is made, the signal is
invoked with the first parameter of the callback being
the name of the property that changed.

### `NexusInstance:AddPropertyValidator(PropertyName,Validator)`
Adds a [`NexusPropertyValidator`](propertyvalidator/nexuspropertyvalidator.md)
to validate changes to properties when the property is changed.

### `NexusInstance:LockProperty(PropertyName)`
Locks a property from being modified. If changing the property
is attempted, an error will be thrown saying `"PROPERTY_NAME is read-only."`
When a property is locked, it can't be unlocked.

### `NexusInstance:HidePropertyChanges(PropertyName)`
Hides all changed signals from being fired for a given
property. This is intended for internal states.

!!! note
    This function only prevents the changed signal for
    `NexusObject.Changed`. Using `NexusInstance:GetPropertyChangedSignal(PropertyName)`
    will bypass this, but it is only recommended for the
    internal state.

### `NexusInstance:HideNextPropertyChange(PropertyName)`
Hides the next changed signal from being fired for a given 
property. This is intended for cases where a `Changed`
signal will invoke a change that causes a stack overflow.

### `NexusInstance:GetPropertyChangedSignal(PropertyName)`
Returns an `RBXScriptSignal` that is invoked when a specific
property is changed.