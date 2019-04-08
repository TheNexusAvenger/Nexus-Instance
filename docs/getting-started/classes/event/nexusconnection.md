# NexusConnection
(Extends [NexusObject](../nexusobject.md))

Stores the function of an event connection and 
handles invoking the function.

### `static NexusConnection.ClassName`
The class name of the object. By default, this will
be `"NexusConnection"`.

### `static NexusConnection.new(Event,ConnectedFunction)`
Creates a connection for a given [NexusEvent](nexusevent.md).
The connected function is called when the connection is fired.

### `NexusConnection.Connected`
Boolean represneting if the connection is active.

### `NexusConnection:Fire(...)`
Fires the connection with the given parameters.

### `NexusConnection:Disconnect()`
Disconnects the connection from the event.