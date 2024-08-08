/**
The ComponentMatchingFamily class is responsible for managing a NodeList.

This class dynamically updates the NodeList by adding or removing nodes as entities and their components change within the engine.

Entities are included in this family’s NodeList if they possess components that match all the component class names specified in the node’s components dictionary.

This class ensures that the NodeList is always up-to-date with the current state of entities and their components in the engine.

The engine maintains a collection of ComponentMatchingFamily instances.*/
 
import Foundation

open class ComponentMatchingFamily: Family, CustomStringConvertible {
    /// The NodeList managed by this family.
    /// This is a reference that always remains valid since it is retained and reused by Systems that use the list. 
    /// i.e. we never recreate the list, we always modify it in place.
    public private(set) var nodeList: NodeList
    private var componentClassNames: [ComponentClassName] = []
    private var entities: [String: Node] = [:]
    private var nodeClassType: Node.Type
    private var nodePool: NodePool
    private weak var engine: Engine?
    public var description: String { "\(Self.self)_" + "\(nodeClassType)" }
    lazy private var listenForUpdateComplete = { Listener(releaseNodePoolCache) }()
    
    /**
     Creates a ComponentMatchingFamily to provide a NodeList for the given `Node` subclass.
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

    deinit {
        engine = nil
    }

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
        guard entities[entity.name] == nil else { return }
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
        entities[entity.name] = node
        nodeList.add(node: node)
    }

    /**
    Removes the entity if it is in this family's NodeList.
    */     
    func removeIfMatch(entity: Entity) {
        guard let node = entities[entity.name] else { return }
        entities.removeValue(forKey: entity.name)
        nodeList.remove(node: node)
        if let engine, engine.updating {
            nodePool.cache(node: node)
            engine.updateComplete.add(listenForUpdateComplete)
        } else {
            nodePool.dispose(node: node)
        }
    }

    /**
     Releases the nodes that were added to the node pool during this engine update, 
     so they can be reused.
     */
    private func releaseNodePoolCache() {
        engine?.updateComplete.remove(listenForUpdateComplete)
        nodePool.releaseCache()
    }

    /**
     Removes all nodes from the NodeList.
     */
    open func cleanUp() {
        var node: Node? = nodeList.head
        while let currentNode = node {
            if let entity = currentNode.entity {
                entities.removeValue(forKey: entity.name)
            }
            node = currentNode.next //end
        }
        nodeList.removeAll()
    }
}
