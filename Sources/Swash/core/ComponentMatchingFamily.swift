/**
This class adds and removes nodes to/from a node list as the entities and the components 
in the engine change.  An `Entity` is added to this family’s node list if it contains components 
matching all component class names in the components dictionary of the node subclass. 
The Engine in turn has a list of `ComponentMatchingFamily`s.
*/
open class ComponentMatchingFamily: IFamily, CustomStringConvertible {
    public var description: String { "\(Self.self)_" + "\(nodeClassType)" }
    private var componentClassNames: [ComponentClassName] = []
    private var engine: Engine
    private var entities: [Entity: Node] = [:]
    private var nodePool: NodePool
    private var nodeClassType: Node.Type
    /**
     Creates a ComponentMatchingFamily to provide a NodeList for the
     given `Node` subclass.
     - Parameters:
      - nodeClassType: The type for the node subclass.
      - engine: The engine for which this family is managing its node list.
    */
    required public init(nodeClassType: Node.Type, engine: Engine) {
        self.nodeClassType = nodeClassType
        nodeList = NodeList()
        self.engine = engine
        nodePool = NodePool(nodeClassType: nodeClassType)
        for (componentClassName, _) in nodeClassType.init().components {
            componentClassNames.append(componentClassName) //component.value
        }
    }

    /**
    The nodelist managed by this family. This is a reference that remains valid always since it is retained and reused by Systems that use the list. i.e. we never recreate the list, we always modify it in place.
    */
    public var nodeList: NodeList

    /**
     Called by the engine when an entity has been added to it.
     We check if the entity should be in this family's NodeList and add it if appropriate.
     */
    open func new(entity: Entity) {
        addIfMatch(entity: entity)
    }

    /**
     Called by the engine when a component has been added to an entity. We check if the entity is not in this family's NodeList and should be, and add it if appropriate.
     - Parameters:
     - entity: The entity with the component added.
     */
    open func componentAddedTo(entity: Entity) {
        addIfMatch(entity: entity)
    }

    /**
     Called by the engine when a component has been removed from an entity. We check if the removed component is required by this family's NodeList and if so, we check if the entity is in this this NodeList and remove it if so.
     */
    open func componentRemovedFrom(entity: Entity, componentClassName: ComponentClassName) {
        guard let _ = componentClassNames.firstIndex(of: componentClassName) else { return }
        removeIfMatch(entity: entity)
    }

    /**
     Called by the engine when an entity has been rmoved from it. We check if the entity is in this family's NodeList and remove it if so.
     */
    open func remove(entity: Entity) {
        removeIfMatch(entity: entity)
    }

    /**
     If the entity is not in this family's NodeList, tests the components of the entity to see if it should be in this NodeList and adds it if so.
    */
    func addIfMatch(entity: Entity) {
        // does the ComponentMatchingFamily have a reference to this entity yet?
        guard entities[entity] == nil else { return }
        // go through all the components return if it does not have a component required by this family. 
        for componentClassName in componentClassNames {
            if entity.has(componentClassName: componentClassName) == false { return }
        }
        // This family is related to a specific Node name. 
        // A Node defines components used together in a system.
        let node: Node = nodePool.get() // This will dynamically create an instance of the right Node type.
        node.entity = entity
        // Populate the nodes’s components
        for componentClassName in componentClassNames {
            node.components[componentClassName] = entity[componentClassName]
        }
        entities[entity] = node
        nodeList.add(node: node)
    }

    /**
    Removes the entity if it is in this family's NodeList.
    */
    func removeIfMatch(entity: Entity) {
        guard let _ = entities[entity],
              let node = entities[entity] else { return }
        entities.removeValue(forKey: entity)
        nodeList.remove(node: node)
        if (engine.updating) {
            nodePool.cache(node: node)
            engine.updateComplete.add(Listener(releaseNodePoolCache))
        } else {
            nodePool.dispose(node: node)
        }
    }

    /**
     Releases the nodes that were added to the node pool during this engine update, 
     so they can be reused.
     */
    private func releaseNodePoolCache() {
        engine.updateComplete.remove(Listener(releaseNodePoolCache))
        nodePool.releaseCache()
    }

    /**
     Removes all nodes from the NodeList.
     */
    open func cleanUp() {
        var node: Node? = nodeList.head
        while let currentNode = node {
            if let entity = currentNode.entity {
                entities.removeValue(forKey: entity)
            }
            node = currentNode.next //end
        }
        nodeList.removeAll()
    }

    // MARK: - Deprecated
    @available(iOS,
               deprecated,
               message: "The function `newEntity(entity:)` is deprecated and will be removed in version 1.1. Please use `new(entity:)` instead.")
    public func newEntity(entity: Entity) {
        new(entity: entity)
    }

    @available(iOS,
               deprecated,
               message: "The function `componentAddedToEntity(entity:)` is deprecated and will be removed in version 1.1. Please use `componentAddedTo(entity:)` instead.")
    public func componentAddedToEntity(entity: Entity) {
        componentAddedTo(entity: entity)
    }

    @available(iOS,
               deprecated,
               message: "The function `componentRemovedFromEntity(entity:)` is deprecated and will be removed in version 1.1. Please use `componentRemovedFrom(entity:)` instead.")
    public func componentRemovedFromEntity(entity: Entity, componentClassName: ComponentClassName) {
        componentRemovedFrom(entity: entity, componentClassName: componentClassName)
    }

    @available(iOS,
               deprecated,
               message: "The function `removeEntity(entity:)` is deprecated and will be removed in version 1.1. Please use `remove(entity:)` instead.")
    public func removeEntity(entity: Entity) {
        remove(entity: entity)
    }
}
