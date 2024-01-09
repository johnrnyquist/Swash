/**
An entity is composed from components. As such, it is essentially a collection object for components. 
Sometimes, the entities in a game will mirror the actual characters and objects in the game, but this 
is not necessary.
Components are simple value objects that contain data relevant to the entity. Entities
with similar functionality will have instances of the same components. So we might have 
a position component
All entities that have a position in the game world, will have an instance of the
position component. Systems operate on entities based on the components they have.
*/
open class Entity: CustomStringConvertible {
    public var description: String { _name }
    //
    static var nameCount = 0
    /// Optional, give the entity a name. This can help with debugging and with serialising the entity.
    private var _name: String
    /// This signal is dispatched when a component is added to the entity.
    public var componentAdded: Signaler1?
    /// This signal is dispatched when a component is removed from the entity.
    public var componentRemoved: Signaler2?
    /// Dispatched when the name of the entity changes. Used internally by the engine to track entities based on their names.
    var nameChanged: Signaler2?
    //
    var previous: Entity?
    var next: Entity?
    var components: [ComponentClassName: Component] = [:]

    /// The initializer
    /// - Parameter name: The name for the entity. If left blank, a default name is assigned with the form _entityN where N is an integer.
    public init(named name: String = "") {
        if !name.isEmpty {
            _name = name
        } else {
            Entity.nameCount += 1
            _name = "_entity\(Entity.nameCount)"
        }
        componentAdded = Signaler1(self)
        componentRemoved = Signaler2()
        nameChanged = Signaler2()
    }

    /// All entities have a name. If no name is set, a default name is used. 
    /// Names are used to fetch specific entities from the engine, 
    /// and can also help to identify an entity when debugging.
    public var name: String {
        get { _name }
        set {
            if (_name != newValue) {
                let previous: String = _name
                _name = newValue
                nameChanged?.dispatch(self, previous)
            }
        }
    }

    /// Add a component to the entity.
    /// - Parameters:
    ///   - component: The component object to add.
    /// - Returns: A reference to the entity. This enables the chaining of calls to add, to make
    /// creating and configuring entities cleaner. 
    @discardableResult
    public func add<T: Component>(component: T) -> Entity {
        let componentClass = type(of: component)
        let componentClassName = "\(componentClass)"
        if let _ = components[componentClassName] {
            components.removeValue(forKey: componentClassName)
        }
        components[componentClassName] = component
        componentAdded?.dispatch(self)
        return self
    }

    /// Remove a component from the entity.
    /// - Parameter componentClass: The class of the component to be removed.
    /// - Returns: the component’s entity or the entity itself
    @discardableResult
    public func remove<T: Component>(componentClass: T.Type) -> Entity {
        guard let _ = components[componentClass.name] as? T else {
            print("Component of class \(componentClass.name) does not exist in the entity.")
            return self
        }
        components.removeValue(forKey: componentClass.name)
        componentRemoved?.dispatch(self, componentClass.name)
        return self
    }

    /// Get a component from the entity.
    /// - Parameter componentClassName: The class of the component requested.
    /// - Returns: The component, or nil if none was found.
    public func get(componentClassName: ComponentClassName) -> Component? {
        components[componentClassName]
    }

    /// Get a component from the entity by its class name.  
    public subscript(componentName: ComponentClassName) -> Component? {
        self.get(componentClassName: componentName)
    }
    
    /// Get all components from the entity.
    /// - Returns: An array containing all the components that are on the entity.
    public func getAll() -> [Component] {
        var componentArray: [Component] = []
        for component in components {
            componentArray.append(component.value)
        }
        return componentArray
    }

    /// Does the entity have a component of a particular type?
    /// - Parameter componentClassName: The class of the component sought.
    /// - Returns: true if the entity has a component of the type, false if not.
    public func has(componentClassName: ComponentClassName) -> Bool {
        return components[componentClassName] != nil
    }

    func removeAllComponents() {
        for component in getAll() {
            remove(componentClass: type(of: component))
        }
    }

    // MARK: - Deprecated
    @available(iOS,
               deprecated,
               message: "The initializer `init(name:)` is deprecated and will be removed in version 1.1. Please use `init(named:)` instead.")
    public convenience init(name: EntityName = "") {
        self.init(named: name)
    }
}

extension Entity: Equatable {
    static public func ==(lhs: Entity, rhs: Entity) -> Bool {
        lhs.name == rhs.name
    }
}

extension Entity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
