//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

public protocol Family {
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
}
