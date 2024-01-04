public protocol IFamily {
    /**
    Returns the NodeList managed by this class. This should be a reference that remains valid always since it is retained and reused by Systems that use the list. i.e. never recreate the list, always modify it in place.
     */
    var nodeList: NodeList { get }
    init(nodeClassType: Node.Type, engine: Engine)
    /**
     An entity has been added to the engine. It may already have components so test the entity for inclusion in this family's NodeList.
     */
    func new(entity: Entity)
    /**
     An entity has been removed from the engine. If it's in this family's NodeList it should be removed.
     */
    func remove(entity: Entity)
    /**
     A component has been added to an entity. Test whether the entity's inclusion in this family's NodeList should be modified.
     */
    func componentAddedTo(entity: Entity)
    /**
     A component has been removed from an entity. Test whether the entity's inclusion in this family's NodeList should be modified.
     */
    func componentRemovedFrom(entity: Entity, componentClassName: ComponentClassName)
    /**
    The family is about to be discarded. Clean up all properties as necessary. Usually, you will want to empty the NodeList at this time.
     */
    func cleanUp()
    
    // MARK: - Deprecated
    @available(iOS,
               deprecated,
               message: "The function `newEntity(entity:)` is deprecated and will be removed in version 1.1. Please use `new(entity:)` instead.")
    func newEntity(entity: Entity)
    @available(iOS,
               deprecated,
               message: "The function `removeEntity(entity:)` is deprecated and will be removed in version 1.1. Please use `remove(entity:)` instead.")
    func removeEntity(entity: Entity)
    @available(iOS,
               deprecated,
               message: "The function `componentAddedToEntity(entity:)` is deprecated and will be removed in version 1.1. Please use `componentAddedTo(entity:)` instead.")
    func componentAddedToEntity(entity: Entity)
    @available(iOS,
               deprecated,
               message: "The function `componentRemovedFromEntity(entity:)` is deprecated and will be removed in version 1.1. Please use `componentRemovedFrom(entity:)` instead.")
    func componentRemovedFromEntity(entity: Entity, componentClassName: ComponentClassName)
}
