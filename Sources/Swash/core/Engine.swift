//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import struct Foundation.TimeInterval

/**
The Engine class is the central point for creating and managing your game state. Add
entities and systems to the engine, and fetch families of nodes from the engine.
*/
public class Engine {
    // Each add has a distinct membership, including a re-add of the same object from a callback.
    private final class Membership {
        let entity: Entity
        // Nil while active. A nested removal resumes at the next family in this iterator.
        var remainingFamilies: Dictionary<NodeClassName, Family>.Values.Iterator?

        init(_ entity: Entity) {
            self.entity = entity
        }
    }

    public var name: String?
    private var entityNames: [EntityName: Membership] = [:]
    private var entityList = EntityList()
    private var systemList = SystemList()
    /**
    The class used to manage node lists. In most cases the default class is sufficient
    but it is exposed here so advanced developers can choose to create and use a 
    different implementation.
    
    The class must implement the Family interface.
    */
    public var familyClass: Family.Type = ComponentMatchingFamily.self
    var families: [NodeClassName: Family] = [:]
    /**
    Indicates if the engine is currently in its update loop.
    */
    var updating = false
    /**
    Dispatched when the update loop ends. If you want to add and remove systems from the
    engine it is usually best not to do so during the update loop. To avoid this you can
    listen for this signal and make the change when the signal is dispatched.
    */
    public var updateComplete = Signaler0()
    // Create listeners to be used on entities. 
    lazy var componentAddedListener = { Listener(componentAdded) }()
    lazy var componentRemovedListener = { Listener(componentRemoved) }()

    public init(name: String? = nil) {
        self.name = name
    }

    /// Add an entity to the engine.
    /// - Parameter entity: The entity to add. Replaces an entity with the same name.
    ///   If a removal callback adds an entity with that name, the callback's addition takes precedence.
    public func add(entity: Entity) {
        if let existingEntity = findEntity(named: entity.name) {
            remove(entity: existingEntity)
            // A removal listener may already have installed a replacement for this name.
            guard entityNames[entity.name] == nil else { return }
        }
        entityList.add(entity: entity)
        entityNames[entity.name] = Membership(entity)
        entity.componentAdded?.add(componentAddedListener)
        entity.componentRemoved?.add(componentRemovedListener)
        notifyFamilies(for: entity) { $0.new(entity: entity) }
    }

    /// This must search all entities for the component, which may not be efficient.
    public func findComponents<T: Component>(componentClass: T.Type) -> [T] {
        entityNames.values.compactMap { $0.entity.find(componentClass: componentClass) }
    }

    /// This must search all entities for the component, which may not be efficient.
    public func findEntitiesContaining(componentClass: Component.Type) -> [Entity] {
        entityNames.values.compactMap { $0.entity.has(componentClass: componentClass) ? $0.entity : nil }
    }

    /// Remove an entity from the engine.
    /// - Parameter entity: The registered instance to remove. Passing a previous instance with the same name has no effect.
    public func remove(entity: Entity) {
        guard let membership = entityNames[entity.name], membership.entity === entity else { return }
        if membership.remainingFamilies == nil {
            entity.componentAdded?.remove(componentAddedListener)
            entity.componentRemoved?.remove(componentRemovedListener)
            membership.remainingFamilies = families.values.makeIterator()
        }
        while let family = membership.remainingFamilies?.next() {
            family.remove(entity: entity)
        }
        guard entityNames[entity.name] === membership else { return }
        entityNames.removeValue(forKey: entity.name)
        entityList.remove(entity: entity)
    }

    public func removeEntities(named names: [EntityName]) {
        for name in names {
            if let entity = findEntity(named: name) {
                remove(entity: entity)
            } else {
                SwashLog.log(.info, "Engine did not contain `\(name)` entity.")
            }
        }
    }
    
    /**
    Get an entity based n its name.
    
    @param name The name of the entity
    @return The entity, or nil if no entity with that name exists on the engine
    */
    public func findEntity(named: EntityName) -> Entity? {
        return entityNames[named]?.entity
    }

    /**
    Remove all entities from the engine.
    */
    public func removeAllEntities() {
        while let head = entityList.head {
            remove(entity: head)
        }
    }

    /**
    Returns an array containing all the entities in the engine.
    */
    public var entities: [Entity] {
        entityList.map { $0 }
    }

    private func componentAdded(entity: Entity) {
        notifyFamilies(for: entity) { $0.componentAddedTo(entity: entity) }
    }

    private func componentRemoved(entity: Entity, componentClassName: ComponentClassName) {
        notifyFamilies(for: entity) {
            $0.componentRemovedFrom(entity: entity, componentClassName: componentClassName)
        }
    }

    private func notifyFamilies(for entity: Entity, _ notify: (Family) -> Void) {
        guard let membership = entityNames[entity.name], membership.entity === entity else { return }
        for family in families.values {
            guard membership.remainingFamilies == nil else { return }
            notify(family)
        }
    }

    /**
    Get a collection of nodes from the engine, based on the type of the node required.
    
    The engine will create the appropriate NodeList if it doesn't already exist and will keep its contents up to date as entities are added to and removed from the engine.
    
    If a NodeList is no longer required, release it with the releaseNodeList method.
    - Parameter nodeClassType: The type of the node.
    - Returns: A linked list of all nodes of this type from all entities in the engine.
    */
    @discardableResult
    public func getNodeList(nodeClassType: Node.Type) -> NodeList {
        let nodeClassName = nodeClassType.name
        if let family = families[nodeClassName] {
            return family.nodeList
        }
        let family: Family = familyClass.init(nodeClassType: nodeClassType, engine: self)
        families[nodeClassName] = family

        let memberships = entityList.compactMap { entityNames[$0.name] }
        for membership in memberships where membership.remainingFamilies == nil {
            family.new(entity: membership.entity)
        }

        return family.nodeList
    }

    /**
    If a NodeList is no longer required, this method will stop the engine updating
    the list and will release all references to the list within the framework
    classes, enabling it to be garbage collected.
    
    It is not essential to release a list, but releasing it will free
    up memory and processor resources.
    
    - Parameter nodeClassName: The type of the node class if the list to be released.
    */
    public func releaseNodeList(nodeClassName: NodeClassName) {
        if let _ = families[nodeClassName] {
            families[nodeClassName]?.cleanUp()
        }
        families.removeValue(forKey: nodeClassName)
    }

    /**
     Add a system to the engine, and set its priority for the order in which the
     systems are updated by the engine update loop.
     The priority dictates the order in which the systems are updated by the engine update
     loop. Lower numbers for priority are updated first. i.e. a priority of 1 is
     updated before a priority of 2.
     - Parameter system: The system to add to the engine.
     - Parameter priority: The priority for updating the systems during the engine loop. A
     lower number means the system is updated sooner.
     */
    @discardableResult
    public func add(system: System, priority: Int) -> Self {
        system.priority = priority
        system.addToEngine(engine: self)
        systemList.add(system: system)
        return self
    }

    /**
    Get the system instance of a particular type from within the engine.
    
    - Parameter  systemClassName: The type of system
    - Returns: The instance of the system type that is in the engine, or
    nil if no systems of this type are in the engine.
    */
    public func findSystem(named name: SystemClassName) -> System? {
        return systemList.get(systemClassName: name)
    }

    /**
    Returns an array containing all the systems in the engine.
    */
    public var systems: [System] {
        systemList.map { $0 }
    }

    /**
     Remove a system from the engine.
     - Parameter system: The system to remove from the engine.
     */
    public func remove(system: System) {
        systemList.remove(system: system)
        system.removeFromEngine(engine: self)
    }

    /// Remove all systems from the engine.
    public func removeAllSystems() {
        while let system = systemList.head {
            systemList.head = system.next
            system.previous = nil
            system.next = nil
            system.removeFromEngine(engine: self)
        }
        systemList.head = nil
        systemList.tail = nil
    }

    /// Remove all systems of a particular type from the engine.
    public func remove(systemType: System.Type) {
        var currentSystem = systemList.head
        while let system = currentSystem {
            currentSystem = system.next
            if type(of: system) == systemType {
                remove(system: system)
            }
        }
    }

    /**
    Update the engine. This causes the engine update loop to run, calling update on all the
    systems in the engine.
     
     One way to call `update` is to listen to a `FrameTickProvider`.
    
     - Parameter time: The duration, in seconds, of this update step.
    */
    public func update(time: TimeInterval) {
        updating = true
        var system: System? = systemList.head
        while let currentSystem = system {
            currentSystem.update(time: time)
            system = currentSystem.next
        }
        updating = false
        updateComplete.dispatch()
    }
}
