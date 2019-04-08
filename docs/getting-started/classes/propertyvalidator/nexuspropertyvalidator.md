# NexusPropertyValidator
(Extends [NexusInterface](../nexusinterface.md))

Interface for a property validator.

### `static NexusPropertyValidator.ClassName`
The class name of the object. By default, this will
be `"NexusPropertyValidator"`.

### `static NexusPropertyValidator:ValidateChange(Object,ValueName,Value)`
Validates a change to the property of a NexusObject.
The new value must be returned. If the input is invalid,
an error should be thrown.