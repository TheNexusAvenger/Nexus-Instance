--[[
TheNexusAvenger

Extends NexusObject to allow for changed singalling
and locking of properties.
--]]

local NexusObject = require(script.Parent:WaitForChild("NexusObject"))
local NexusEvent = require(script.Parent:WaitForChild("Event"):WaitForChild("NexusEvent"))

local NexusInstance = NexusObject:Extend()
NexusInstance:SetClassName("NexusInstance")



--[[
Creates an instance of a Nexus Instance.
--]]
function NexusInstance:__new()
    --Set up the base object.
    self:InitializeSuper()

    --Set up the internal properties.
    self:__InitInternalProperties()
    self:__InitMetaMethods()
end

--[[
Sets up the internal properties.
--]]
function NexusInstance:__InitInternalProperties()
    --Set up the properties.
    self.__InternalProperties = {}
    self.__GenericPropertyValidators = {}
    self.__PropertyValidators = {}
    self.__GenericPropertyFinalizers = {}
    self.__PropertyFinalizers = {}
    self.__HiddenProperties = {}
    self.__LockedProperties = {}
    self.__BlockNextChangedSignals = {}
    self.__PropertyChanged = {}
    self.__ChangedEvent = NexusEvent.new()
    self.Changed = self.__ChangedEvent

    --Lock the internal states.
    self:LockProperty("__GenericPropertyValidators")
    self:LockProperty("__PropertyValidators")
    self:LockProperty("__GenericPropertyFinalizers")
    self:LockProperty("__PropertyFinalizers")
    self:LockProperty("__HiddenProperties")
    self:LockProperty("__LockedProperties")
    self:LockProperty("__BlockNextChangedSignals")
    self:LockProperty("__PropertyChanged")
    self:LockProperty("__ChangedEvent")
    self:LockProperty("Changed")
    self:LockProperty("ClassName")
end

--[[
Sets up the meta methods.
--]]
function NexusInstance:__InitMetaMethods()
    --Set up the internal state.
    local InternalProperties = self.__InternalProperties
    local GenericPropertyValidators = self.__GenericPropertyValidators
    local PropertyFinalizers = self.__PropertyFinalizers
    local GenericPropertyFinalizers = self.__GenericPropertyFinalizers
    local PropertyValidators = self.__PropertyValidators
    local HiddenProperties = self.__HiddenProperties
    local LockedProperties = self.__LockedProperties
    local BlockNextChangedSignals = self.__BlockNextChangedSignals
    local PropertyChanged = self.__PropertyChanged
    local ChangedBindableEvent = self.__ChangedEvent

    --Set up custom indexing.
    local Metatable = {}
    local IndexMethod = self.object:__createindexmethod(self.object, self.class, self.class)
    Metatable.__index = IndexMethod
    setmetatable(self.object, Metatable)

    --Set up changes.
    Metatable.__newindex = function(_,Index,Value)
        --Throw an error if the property is locked.
        if LockedProperties[Index] then
            error(tostring(Index).." is read-only.")
        end

        --Return if the new and old values are the same.
        if IndexMethod(self, Index) == Value then
            return
        end

        --Validate the value.
        for _,Validator in pairs(GenericPropertyValidators) do
            Value = Validator:ValidateChange(self,Index,Value)
        end
        local Validators = PropertyValidators[Index]
        if Validators then
            for _,Validator in pairs(Validators) do
                Value = Validator:ValidateChange(self,Index,Value)
            end
        end

        --Change the property.
        InternalProperties[Index] = Value

        --Invoke the finalizers.
        --Will prevent sending changed signals if there is a problem.
        for _,Finalizer in pairs(GenericPropertyFinalizers) do
            Finalizer(Index,Value)
        end
        local Finalizers = PropertyFinalizers[Index]
        if Finalizers then
            for _,Finalizer in pairs(Finalizers) do
                Finalizer(Index,Value)
            end
        end

        --Return if the event is hidden.
        if BlockNextChangedSignals[Index] then
            BlockNextChangedSignals[Index] = nil
            return
        end

        --Invoke the property changed event.
        local PropertyChangedEvent = PropertyChanged[Index]
        if PropertyChangedEvent then
            PropertyChangedEvent:Fire()
        end

        --Invoke the Changed event.
        if HiddenProperties[Index] then
            return
        end
        ChangedBindableEvent:Fire(Index)
    end
end

--[[
Creates an __index metamethod for an object. Used to
setup custom indexing.
--]]
function NexusInstance:__createindexmethod(Object, Class, RootClass)
    local InternalProperties = self.__InternalProperties
    local ExistingMetatable = getmetatable(self.object)
    local ExistingIndex = ExistingMetatable.__index

    return function (_, Index)
        --Return the internal property.
        local InternalPropertyValue = InternalProperties[Index]
        if InternalPropertyValue ~= nil then
            return InternalPropertyValue
        end

        --Return the base return.
        return ExistingIndex[Index]
    end
end

--[[
Adds a validator that is called for all values.
These are called before any property-specific validators.
--]]
function NexusInstance:AddGenericPropertyValidator(Validator)
    table.insert(self.__GenericPropertyValidators,Validator)
end

--[[
Adds a validator for a given property.
--]]
function NexusInstance:AddPropertyValidator(PropertyName,Validator)
    if not self.__PropertyValidators[PropertyName] then
        self.__PropertyValidators[PropertyName] = {}
    end
    table.insert(self.__PropertyValidators[PropertyName],Validator)
end

--[[
Adds a finalizer for when a property is set.
This is intended to prevent invoking changed events
if there is a problem.
--]]
function NexusInstance:AddGenericPropertyFinalizer(Finalizer)
    table.insert(self.__GenericPropertyFinalizers,Finalizer)
end

--[[
Adds a finalizer for when a given property is set.
This is intended to prevent invoking changed events
if there is a problem.
--]]
function NexusInstance:AddPropertyFinalizer(PropertyName,Finalizer)
    if not self.__PropertyFinalizers[PropertyName] then
        self.__PropertyFinalizers[PropertyName] = {}
    end
    table.insert(self.__PropertyFinalizers[PropertyName],Finalizer)
end

--[[
Prevents a property from being overriden.
--]]
function NexusInstance:LockProperty(PropertyName)
    self.__LockedProperties[PropertyName] = true
end

--[[
Prevents a property being changed from registering the Changed property.
--]]
function NexusInstance:HidePropertyChanges(PropertyName)
    self.__HiddenProperties[PropertyName] = true
end

--[[
Prevents all changed signals being fired for a property change 1 time.
Does not stack with multiple calls.
--]]
function NexusInstance:HideNextPropertyChange(PropertyName)
    self.__BlockNextChangedSignals[PropertyName] = true
end

--[[
Returns a changed signal specific to the property.
--]]
function NexusInstance:GetPropertyChangedSignal(PropertyName)
    --If there is no event created, create a bindable event.
    if not self.__PropertyChanged[PropertyName] then
        self.__PropertyChanged[PropertyName] = NexusEvent.new()
    end

    --Return the event.
    return self.__PropertyChanged[PropertyName]
end

--[[
Disconnects the events of the instance.
--]]
function NexusInstance:Destroy()
    --Disconnect the changed event.
    self.Changed:Disconnect()

    --Disconnect the changed signal events.
    for _,Event in pairs(self.__PropertyChanged) do
        Event:Disconnect()
    end
    self.__PropertyChanged = {}
end



return NexusInstance