//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

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
    static var nameCount = 0

    private var _name: String
    /// This signal is dispatched when a component is added to the entity.
    public private(set) var componentAdded: Signaler1?
    /// This signal is dispatched when a component is removed from the entity.
    public private(set) var componentRemoved: Signaler2?
    /// All the components that are on the entity.
    public var components: [Component] { Array(componentClassNameInstanceMap.values) }
    /// CustomStringConvertible conformance
    public var description: String { _name }
    var componentClassNameInstanceMap: [ComponentClassName: Component] = [:]
    // An entity is a node in a doubly-linked list.
    var previous: Entity?
    var next: Entity?

    /// The initializer
    /// - Parameter name: The name for the entity. If left blank, a default name is assigned with the form _entityN where N is an integer.
    public init(named name: String = "") {
        if !name.isEmpty {
            _name = name
        } else {
            Entity.nameCount += 1
            _name = "_entity\(Entity.nameCount)"
        }
        componentAdded = Signaler1()
        componentRemoved = Signaler2()
    }

    deinit {
        componentAdded = nil
        componentRemoved = nil
        componentClassNameInstanceMap.removeAll()
        previous = nil
        next = nil
    }

    /// All entities have a name. One is created if one is not supplied. 
    /// Names are used to fetch specific entities from the engine, 
    /// and can also help to identify an entity when debugging.
    public private(set) var name: String {
        get { _name }
        set {
            if _name != newValue {
                _name = newValue
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
        component.entity = self
        let componentClassName = String(reflecting: type(of: component))
        if componentClassNameInstanceMap[componentClassName] !== component {
            componentClassNameInstanceMap[componentClassName] = component
            componentAdded?.dispatch(self)
        }
        return self
    }

    /// Remove a component from the entity.
    /// - Parameter componentClass: The class of the component to be removed.
    /// - Returns: the component’s entity or the entity itself
    @discardableResult
    public func remove<T: Component>(componentClass: T.Type) -> Entity {
        let componentClassName = componentClass.name
        if let component = componentClassNameInstanceMap.removeValue(forKey: componentClassName) {
            component.entity = nil
            componentRemoved?.dispatch(self, componentClass.name)
        } else {
            print("Component of class `\(componentClass.name)` does not exist in `\(name)` entity.")
        }
        return self
    }

    /// Find a component in the entity.
    /// - Parameter componentClassName: The class of the component requested.
    /// - Returns: The component, or nil if none was found.
    public func find(componentClassName: ComponentClassName) -> Component? {
        componentClassNameInstanceMap[componentClassName]
    }

    /// Find a component in the entity.
    /// - Parameter componentClass: the class of the component requested.
    /// - Returns: The component, or nil if none was found.
    public func find<T: Component>(componentClass: T.Type) -> T? {
        componentClassNameInstanceMap[T.name] as? T
    }

    /// Get a component from the entity by its class name.  
    public subscript(componentName: ComponentClassName) -> Component? {
        find(componentClassName: componentName)
    }

    /// Get a component from the entity by its class type.
    public subscript<T: Component>(componentClass: T.Type) -> T? {
        find(componentClass: componentClass)
    }

    /// Does the entity have a component of a particular type?
    /// - Parameter componentClassName: The class of the component sought.
    /// - Returns: true if the entity has a component of the type, false if not.
    public func has(componentClassName: ComponentClassName) -> Bool {
        componentClassNameInstanceMap[componentClassName] != nil
    }

    /// Does the entity have a component of a particular type?
    /// - Parameter componentClass: The class of the component sought.
    /// - Returns: true if the entity has a component of the type, false if not.
    public func has<T: Component>(componentClass: T.Type) -> Bool {
        componentClassNameInstanceMap[T.name] != nil
    }

    func removeAllComponents() {
        for component in components {
            remove(componentClass: type(of: component))
        }
    }
}

extension Entity: Equatable {
    static public func ==(lhs: Entity, rhs: Entity) -> Bool {
        lhs === rhs
    }
}

extension Entity: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
