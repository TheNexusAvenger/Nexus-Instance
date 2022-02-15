# RobloxEvent
(Extends [NexusObject](../nexusobject.md))

Sends and listens to events.

### `static NexusEvent.ClassName`
The class name of the object. By default, this will
be `"NexusEvent"`.

### `NexusEvent:Disconnected(Connection)`
Invoked when a connection is disconnected. This is
used for clearing events when they are disconnected.

### `NexusEvent:Connection(Function)`
Establishes a function to be called whenever the 
event is raised. The parameters of the passed
in function can vary in length since they are
dependent on what is passed into `NexusEvent::Fire`.
Returns a [`NexusConnection`](nexusconnection.md).

### `NexusEvent:Disconnect()`
Disconnects all connected events.

### `NexusEvent:Fire(...)`
Fires the event with the given parameters.

### `NexusEvent:Wait()`
Waits for the event to be fired and returns
the parameters that were fired.