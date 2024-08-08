import XCTest
@testable import Swash

final class EngineTests: XCTestCase {
    var engine: Engine!

    override func setUpWithError() throws {
        engine = Engine()
        engine.familyClass = MockFamily.self
    }

    override func tearDownWithError() throws {
        MockFamily.reset()
        engine = nil
    }

    func test_listenerSignatures() {
        XCTAssertNotNil(engine.componentAddedListener.entity_noReturn)
        XCTAssertNotNil(engine.componentRemovedListener.entity_string_noReturn)
    }
    

    func test_add_EntityWithSameNameReplacesPrevious() {
        let entity1 = Entity(named: "entity")
        let entity2 = Entity(named: "entity") // same name
        XCTAssertEqual(entity1.name, entity2.name)
        XCTAssertFalse(entity1 == entity2)
        XCTAssertFalse(entity1 === entity2)
        engine.add(entity: entity1)
        XCTAssertEqual(engine.entities.count, 1)
        engine.add(entity: entity2)
        XCTAssertEqual(engine.entities.count, 1)
        XCTAssertNotEqual(engine.findEntity(named: "entity"), entity1)
        XCTAssertEqual(engine.findEntity(named: "entity"), entity2)
        XCTAssertFalse(engine.findEntity(named: "entity") === entity1)
        XCTAssertTrue(engine.findEntity(named: "entity") === entity2)
    }

    func test_addEntity() throws {
        let entity = Entity()
        engine.add(entity: entity)
        XCTAssertEqual(engine.entities.count, 1)
    }

    func test_removeEntity() throws {
        let entity = Entity()
        engine.add(entity: entity)
        engine.remove(entity: entity)
        XCTAssertEqual(engine.entities.count, 0)
    }

    func test_removeAllEntities() throws {
        let entity = Entity()
        engine.add(entity: entity)
        engine.removeAllEntities()
        XCTAssertEqual(engine.entities.count, 0)
    }

    func test_findEntityNamed() throws {
        let entity = Entity()
        let name = entity.name
        engine.add(entity: entity)
        let entityFound = engine.findEntity(named: name)
        XCTAssertEqual(entityFound, entity)
    }

    func test_getNodeList_firstTime() {
        let entity1 = Entity()
                .add(component: MockComponent())
                .add(component: AnotherMockComponent())
        engine.familyClass = ComponentMatchingFamily.self
        engine.add(entity: entity1)
        XCTAssertEqual(engine.getNodeList(nodeClassType: MockNode.self).empty, false)
    }

    func test_getNodeList_secondTime() {
        let entity1 = Entity()
                .add(component: MockComponent())
                .add(component: AnotherMockComponent())
        engine.familyClass = ComponentMatchingFamily.self
        engine.add(entity: entity1)
        XCTAssertEqual(engine.getNodeList(nodeClassType: MockNode.self).numNodes, 1)
        let entity2 = Entity()
                .add(component: MockComponent())
                .add(component: AnotherMockComponent())
        engine.familyClass = ComponentMatchingFamily.self
        engine.add(entity: entity2)
        XCTAssertEqual(engine.getNodeList(nodeClassType: MockNode.self).numNodes, 2)
    }

    func test_addSystem() {
        engine.add(system: MockSystem(), priority: 1)
        XCTAssertNotNil(engine.findSystem(named: "MockSystem"))
    }

    func test_findSystemNamed() {
        let mockSystem = MockSystem()
        let name = MockSystem.name
        engine.add(system: mockSystem, priority: 1)
        XCTAssertNotNil(engine.findSystem(named: name))
    }

    func test_entitiesGetterReturnsAllTheEntities() {
        let entity1: Entity = Entity()
        engine.add(entity: entity1)
        let entity2: Entity = Entity()
        engine.add(entity: entity2)
        XCTAssertEqual(engine.entities.count, 2)
        XCTAssertTrue(engine.entities.contains(entity1))
        XCTAssertTrue(engine.entities.contains(entity2))
    }

    func test_findEntityNamed_ReturnsCorrectEntity() {
        let entity1: Entity = Entity(named: "otherEntity")
        engine.add(entity: entity1)
        let entity2: Entity = Entity(named: "myEntity")
        engine.add(entity: entity2)
        XCTAssertEqual(engine.findEntity(named: "myEntity"), entity2)
        XCTAssertEqual(engine.findEntity(named: "otherEntity"), entity1)
    }

    func test_getEntityByNameReturnsNilIfNoEntity() {
        let entity1: Entity = Entity(named: "otherEntity")
        engine.add(entity: entity1)
        let entity2: Entity = Entity(named: "myEntity")
        engine.add(entity: entity2)
        XCTAssertNil(engine.findEntity(named: "wrongName"))
    }

    func test_addEntityChecksWithAllFamilies() {
        engine.getNodeList(nodeClassType: MockNode1.self)
        engine.getNodeList(nodeClassType: MockNode2.self)
        let entity: Entity = Entity()
        engine.add(entity: entity)
        XCTAssertEqual(MockFamily.instances[0].newEntityCalls, 1)
        XCTAssertEqual(MockFamily.instances[1].newEntityCalls, 1)
    }

    func test_removeEntityChecksWithAllFamilies() {
        engine.getNodeList(nodeClassType: MockNode1.self)
        engine.getNodeList(nodeClassType: MockNode2.self)
        let entity: Entity = Entity()
        engine.add(entity: entity)
        engine.remove(entity: entity)
        XCTAssertEqual(MockFamily.instances[0].removeEntityCalls, 1)
        XCTAssertEqual(MockFamily.instances[1].removeEntityCalls, 1)
    }

    func test_removeAllEntitiesChecksWithAllFamilies() {
        engine.getNodeList(nodeClassType: MockNode1.self)
        engine.getNodeList(nodeClassType: MockNode2.self)
        let entity: Entity = Entity()
        let entity2: Entity = Entity()
        engine.add(entity: entity)
        engine.add(entity: entity2)
        engine.removeAllEntities()
        XCTAssertEqual(MockFamily.instances[0].removeEntityCalls, 2)
        XCTAssertEqual(MockFamily.instances[1].removeEntityCalls, 2)
    }

    func test_componentAddedChecksWithAllFamilies() {
        engine.getNodeList(nodeClassType: MockNode1.self)
        engine.getNodeList(nodeClassType: MockNode2.self)
        let entity: Entity = Entity()
        engine.add(entity: entity)
        entity.add(component: PointComponent())
        XCTAssertEqual(MockFamily.instances[0].componentAddedCalls, 1)
        XCTAssertEqual(MockFamily.instances[1].componentAddedCalls, 1)
    }

    func test_componentRemovedChecksWithAllFamilies() {
        engine.getNodeList(nodeClassType: MockNode1.self)
        engine.getNodeList(nodeClassType: MockNode2.self)
        let entity: Entity = Entity()
        engine.add(entity: entity)
        entity.add(component: PointComponent())
        entity.remove(componentClass: PointComponent.self)
        XCTAssertEqual(MockFamily.instances[0].componentRemovedCalls, 1)
        XCTAssertEqual(MockFamily.instances[1].componentRemovedCalls, 1)
    }

    func test_getNodeListCreatesFamily() {
        engine.getNodeList(nodeClassType: MockNode.self)
        XCTAssertEqual(MockFamily.instances.count, 1)
    }

    func test_getNodeListChecksAllEntities() {
        engine.add(entity: Entity())
        engine.add(entity: Entity())
        engine.getNodeList(nodeClassType: MockNode.self)
        XCTAssertEqual(MockFamily.instances[0].newEntityCalls, 2)
    }

    func test_releaseNodeListCallsCleanUp() {
        engine.getNodeList(nodeClassType: MockNode.self)
        engine.releaseNodeList(nodeClassName: "\(MockNode.self)")
        XCTAssertEqual(MockFamily.instances[0].cleanUpCalls, 1)
    }

    func test_entityCanBeObtainedByName() {
        let entity: Entity = Entity(named: "anything")
        engine.add(entity: entity)
        let other: Entity = engine.findEntity(named: "anything")!
        XCTAssertTrue(other === entity)
    }

    func test_getEntityByInvalidNameReturnsNil() {
        let entity: Entity? = engine.findEntity(named: "anything")
        XCTAssertNil(entity)
    }
}

fileprivate class MockNode1: Node {
}

fileprivate class MockNode2: Node {
}

class MockFamily: IFamily {
    static public var instances = [MockFamily]()

    public static func reset() {
        instances = [MockFamily]()
    }

    public var newEntityCalls = 0
    public var removeEntityCalls = 0
    public var componentAddedCalls = 0
    public var componentRemovedCalls = 0
    public var cleanUpCalls = 0

    required init(nodeClassType: Node.Type, engine: Engine) {
        MockFamily.instances.append(self)
    }

    public var nodeList: NodeList {
        return NodeList()
    }

    func new(entity: Swash.Entity) {
        newEntityCalls += 1
    }

    func remove(entity: Swash.Entity) {
        removeEntityCalls += 1
    }

    func componentAddedTo(entity: Swash.Entity) {
        componentAddedCalls += 1
    }

    func componentRemovedFrom(entity: Swash.Entity, componentClassName: Swash.ComponentClassName) {
        componentRemovedCalls += 1
    }

    public func cleanUp() {
        cleanUpCalls += 1
    }

    //MARK: - Deprecated Methods
    func newEntity(entity: Entity) {}

    func removeEntity(entity: Entity) {}

    func componentAddedToEntity(entity: Entity) {}

    func componentRemovedFromEntity(entity: Entity, componentClassName: ComponentClassName) {}
}
