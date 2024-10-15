--Main module for Nexus Instance.
--!strict

local METATABLE_METHODS = {
    "__call",
    "__concat",
    "__unm",
    "__add",
    "__sub",
    "__mul",
    "__div",
    "__idiv",
    "__mod",
    "__pow",
    "__tostring",
    "__eq",
    "__lt",
    "__le",
    "__gc",
    "__len",
    "__iter",
}

local TypedEvent = require(script:WaitForChild("Event"):WaitForChild("TypedEvent"))

local NexusInstance = {}

export type TypedEvent<T...> = TypedEvent.TypedEvent<T...>

export type NexusInstanceClass<TClass, TConstructor> = {
    new: TConstructor
} & TClass

export type NexusInstance<TObject> = {
    Changed: TypedEvent<string>,
    BaseClass: any,
    Events: {TypedEvent<unknown>},
    TransformFunctions: {(Index: any, Value: any) -> (any)},
    PropertyTransformFunctions: {[string]: {(Value: any) -> (any)}},
    OnAnyPropertyChangedFunctions: {(PropertyName: any, Value: any) -> ()},
    OnPropertyChangedFunctions: {[string]: {(Value: any) -> ()}},
    HiddenPropertyChanges: {[string]: boolean},
    HiddenNextPropertyChanges: {[string]: boolean},
    PropertyChangedEvents: {[string]: TypedEvent<>},
} & typeof(NexusInstance) & TObject



--[[
Creates an instance version of the given class.
--]]
function NexusInstance.ToInstance<TClass, TConstructor>(Class: TClass): NexusInstanceClass<TClass, TConstructor>
    --Add the constructor.
    local ExtendedClass = (Class :: any) :: NexusInstanceClass<TClass, TConstructor>
    ExtendedClass.new = (function(...)
        --Prepare the object.
        local ChangedEvent = (TypedEvent.new() :: any) :: TypedEvent<string>
        local Properties = {}
        local TransformFunctions = {} :: {(Index: any, Value: any) -> (any)}
        local PropertyTransformFunctions = {} :: {[string]: {(Value: any) -> (any)}}
        local OnAnyPropertyChangedFunctions = {} :: {(PropertyName: any, Value: any) -> ()}
        local OnPropertyChangedFunctions = {} :: {[string]: {(Value: any) -> ()}}
        local HiddenPropertyChanges = {} :: {[string]: boolean}
        local HiddenNextPropertyChanges = {} :: {[string]: boolean}
        local PropertyChangedEvents = {} :: {[string]: TypedEvent<>}

        --Create the object.
        local Object = {
            Changed = ChangedEvent,
            BaseClass = Class,
            Events = {ChangedEvent},
            TransformFunctions = TransformFunctions,
            PropertyTransformFunctions = PropertyTransformFunctions,
            OnAnyPropertyChangedFunctions = OnAnyPropertyChangedFunctions,
            OnPropertyChangedFunctions = OnPropertyChangedFunctions,
            HiddenPropertyChanges = HiddenPropertyChanges,
            HiddenNextPropertyChanges = HiddenNextPropertyChanges,
            PropertyChangedEvents = PropertyChangedEvents,
        }
        local Metatable = {
            __index = function(_, Index: string): any?
                --Return the property.
                local PropertyValue = Properties[Index]
                if PropertyValue ~= nil then
                    return PropertyValue 
                end

                --Return the NexusInstance value.
                local NexusInstanceValue = (NexusInstance :: any)[Index]
                if NexusInstanceValue ~= nil then
                    return NexusInstanceValue
                end

                --Return the class's value.
                return (Class :: any)[Index]
            end,
            __newindex = function(self: any, Index: string, Value: any): ()
                --Perform the transform functions.
                for _, TransformFunction in TransformFunctions do
                    Value = TransformFunction(Index, Value)
                end
                if PropertyTransformFunctions[Index] then
                    for _, TransformFunction in PropertyTransformFunctions[Index] do
                        Value = TransformFunction(Value)
                    end
                end

                --Return if the new and old values are the same.
                if self[Index] == Value then
                    return
                end

                --Change the property.
                Properties[Index] = Value

                --Invoke that the property has changed.
                for _, ChangedCallback in OnAnyPropertyChangedFunctions do
                    ChangedCallback(Index, Value)
                end
                local PropertyChangedCallbacks = OnPropertyChangedFunctions[Index]
                if PropertyChangedCallbacks then
                    for _, ChangedCallback in PropertyChangedCallbacks do
                        ChangedCallback(Value)
                    end
                end

                --Return if the property is hidden.
                if HiddenNextPropertyChanges[Index] then
                    HiddenNextPropertyChanges[Index] = nil
                    return
                end
                if HiddenPropertyChanges[Index] then
                    return
                end

                --Invoke the changed event.
                self.Changed:Fire(Index)
                local PropertyChangedEvent = PropertyChangedEvents[Index]
                if PropertyChangedEvent then
                    PropertyChangedEvent:Fire()
                end
            end,
        }
        for _, MetatableMethod in METATABLE_METHODS do
            (Metatable :: any)[MetatableMethod] = (Class :: any)[MetatableMethod] 
        end
        local self = setmetatable(Object, Metatable)

        --Call the __new constructor of the class.
        local Constructor = (Class :: any).__new
        if Constructor then
            Constructor(self, ...)
        end

        --Return the object.
        return self
    end :: any) :: TConstructor
    
    --Return the extended class.
    return ExtendedClass 
end

--[[
Creates an event that is disconnected when the instance is destroyed.
--]]
function NexusInstance.CreateEvent<T, TEventArguments...>(self: NexusInstance<T>): TypedEvent<TEventArguments...>
    local NewEvent = TypedEvent.new() :: TypedEvent<TEventArguments...>
    table.insert(self.Events, NewEvent :: any)
    return NewEvent
end

--[[
Adds a generic property transformer.
--]]
function NexusInstance.AddGenericPropertyTransform<T>(self: NexusInstance<T>, Transform: (Index: any, Value: any) -> (any)): ()
    table.insert(self.TransformFunctions, Transform)
end

--[[
Adds a property transformer for a specific property.
--]]
function NexusInstance.AddPropertyTransform<T>(self: NexusInstance<T>, PropertyName: any, Transform: (Value: any) -> (any)): ()
    if not self.PropertyTransformFunctions[PropertyName] then
        self.PropertyTransformFunctions[PropertyName] = {}
    end
    table.insert(self.PropertyTransformFunctions[PropertyName], Transform)
end

--[[
Adds a callback when a property is changed.
This invokes immediately as opposed to using events.
--]]
function NexusInstance.OnAnyPropertyChanged<T>(self: NexusInstance<T>, Callback: (PropertyName: any, Value: any) -> ()): ()
    table.insert(self.OnAnyPropertyChangedFunctions, Callback)
end

--[[
Adds a callback when the given property is changed.
This invokes immediately as opposed to using events.
--]]
function NexusInstance.OnPropertyChanged<T>(self: NexusInstance<T>, PropertyName: string, Callback: (Value: any) -> ()): ()
    if not self.OnPropertyChangedFunctions[PropertyName] then
        self.OnPropertyChangedFunctions[PropertyName] = {}
    end
    table.insert(self.OnPropertyChangedFunctions[PropertyName], Callback)
end

--[[
Hides all changed events for a property.
--]]
function NexusInstance.HidePropertyChanges<T>(self: NexusInstance<T>, PropertyName: string): ()
    self.HiddenPropertyChanges[PropertyName] = true
end

--[[
Hides the next changed events for a property.
--]]
function NexusInstance.HideNextPropertyChange<T>(self: NexusInstance<T>, PropertyName: string): ()
    self.HiddenNextPropertyChanges[PropertyName] = true
end

--[[
Returns an event for when a property is changed.
--]]
function NexusInstance.GetPropertyChangedSignal<T>(self: NexusInstance<T>, PropertyName: string): TypedEvent<>
    if not self.PropertyChangedEvents[PropertyName] then
        self.PropertyChangedEvents[PropertyName] = self:CreateEvent()
    end
    return self.PropertyChangedEvents[PropertyName]
end

--[[
Destroys the instance.
--]]
function NexusInstance.Destroy<T>(self: NexusInstance<T>): ()
    --Call the class's destroy event.
    local DestroyFunction = (self.BaseClass :: any).Destroy
    if DestroyFunction then
        DestroyFunction(self)
    end

    --Disconnect the events.
    task.defer(function()
        for _, Event in self.Events do
            (Event :: TypedEvent<unknown>):Destroy()
        end
        self.Events = {}
    end)
end



return NexusInstance