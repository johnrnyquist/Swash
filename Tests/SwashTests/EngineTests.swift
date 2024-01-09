import XCTest
@testable import Swash

final class EngineTests: XCTestCase {
    var engine: Engine!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        engine = Engine()
        engine.familyClass = MockFamily.self
        MockFamily.reset()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        engine = nil
    }

    func test_replaceEntity() throws {
        let component1 = MockComponent()
        component1.value = 1
        let component2 = MockComponent()
        component2.value = 2
        let entity1 = Entity(named: "entity")
            .add(component: component1)
        let entity2 = Entity(named: "entity") // same name
            .add(component: component2)
        try? engine.add(entity: entity1)
        var component: MockComponent? = engine.getEntity(named: "entity")?[MockComponent.self]
        XCTAssertEqual(component?.value, 1)
        engine.replace(entity: entity2)
        component = engine.getEntity(named: "entity")?[MockComponent.self]
        XCTAssertEqual(component?.value, 2)
    }

    func test_addEntityWithSameName() {
        let entity1 = Entity(named: "entity")
        let entity2 = Entity(named: "entity") // same name
        try? engine.add(entity: entity1)
        XCTAssertThrowsError(try engine.add(entity: entity2)) { error in
            XCTAssertEqual(error as? SwashError, SwashError.entityNameAlreadyInUse("The entity name \(entity2.name) is already in use."))
        }
    }

    func test_addEntity() throws {
        let entity = Entity()
        try! engine.add(entity: entity)
        XCTAssertEqual(engine.entities.count, 1)
        entity.add(component: Component())
    }

    func test_removeEntity() throws {
        let entity = Entity()
        try! engine.add(entity: entity)
        engine.remove(entity: entity)
        XCTAssertEqual(engine.entities.count, 0)
    }

    func test_removeAllEntities() throws {
        let entity = Entity()
        try! engine.add(entity: entity)
        engine.removeAllEntities()
        XCTAssertEqual(engine.entities.count, 0)
    }

    func test_getEntityByName() throws {
        let entity = Entity()
        let name = entity.name
        try! engine.add(entity: entity)
        let entityFound = engine.getEntity(named: name)
        XCTAssertEqual(entityFound, entity)
    }

    func test_getNodeList_firstTime() {
        let entity1 = Entity()
            .add(component: MockComponent())
            .add(component: AnotherMockComponent())
        engine.familyClass = ComponentMatchingFamily.self
        try! engine.add(entity: entity1)
        XCTAssertEqual(engine.getNodeList(nodeClassType: MockNode.self).empty, false)
    }

    func test_getNodeList_secondTime() {
        let entity1 = Entity()
            .add(component: MockComponent())
            .add(component: AnotherMockComponent())
        engine.familyClass = ComponentMatchingFamily.self
        try! engine.add(entity: entity1)
        XCTAssertEqual(engine.getNodeList(nodeClassType: MockNode.self).empty, false)
        let entity2 = Entity()
            .add(component: MockComponent())
            .add(component: AnotherMockComponent())
        engine.familyClass = ComponentMatchingFamily.self
        try! engine.add(entity: entity2)
        XCTAssertEqual(engine.getNodeList(nodeClassType: MockNode.self).empty, false)
    }

    func test_addSystem() {
        engine.add(system: MockSystem(), priority: 1)
        XCTAssertNotNil(engine.getSystem(systemClassName: "MockSystem"))
    }

    func test_getSystem() {
        let mockSystem = MockSystem()
        let name = MockSystem.name
        engine.add(system: mockSystem, priority: 1)
        XCTAssertNotNil(engine.getSystem(systemClassName: name))
    }

    func test_entitiesGetterReturnsAllTheEntities() {
        let entity1: Entity = Entity()
        try! engine.add(entity: entity1)
        let entity2: Entity = Entity()
        try! engine.add(entity: entity2)
        XCTAssertEqual(engine.entities.count, 2)
        XCTAssertTrue(engine.entities.contains(entity1))
        XCTAssertTrue(engine.entities.contains(entity2))
    }

    func test_getEntityByNameReturnsCorrectEntity() {
        let entity1: Entity = Entity()
        entity1.name = "otherEntity"
        try! engine.add(entity: entity1)
        let entity2: Entity = Entity()
        entity2.name = "myEntity"
        try! engine.add(entity: entity2)
        XCTAssertTrue(engine.getEntity(named: "myEntity") === entity2)
    }

    func test_getEntityByNameReturnsNilIfNoEntity() {
        let entity1: Entity = Entity()
        entity1.name = "otherEntity"
        try! engine.add(entity: entity1)
        let entity2: Entity = Entity()
        entity2.name = "myEntity"
        try! engine.add(entity: entity2)
        XCTAssertNil(engine.getEntity(named: "wrongName"))
    }

    func test_addEntityChecksWithAllFamilies() {
        engine.getNodeList(nodeClassType: MockNode1.self)
        engine.getNodeList(nodeClassType: MockNode2.self)
        let entity: Entity = Entity()
        try! engine.add(entity: entity)
        XCTAssertEqual(MockFamily.instances[0].newEntityCalls, 1)
        XCTAssertEqual(MockFamily.instances[1].newEntityCalls, 1)
    }

    func test_removeEntityChecksWithAllFamilies() {
        engine.getNodeList(nodeClassType: MockNode1.self)
        engine.getNodeList(nodeClassType: MockNode2.self)
        let entity: Entity = Entity()
        try! engine.add(entity: entity)
        engine.remove(entity: entity)
        XCTAssertEqual(MockFamily.instances[0].removeEntityCalls, 1)
        XCTAssertEqual(MockFamily.instances[1].removeEntityCalls, 1)
    }

    func test_removeAllEntitiesChecksWithAllFamilies() {
        engine.getNodeList(nodeClassType: MockNode1.self)
        engine.getNodeList(nodeClassType: MockNode2.self)
        let entity: Entity = Entity()
        let entity2: Entity = Entity()
        try! engine.add(entity: entity)
        try! engine.add(entity: entity2)
        engine.removeAllEntities()
        XCTAssertEqual(MockFamily.instances[0].removeEntityCalls, 2)
        XCTAssertEqual(MockFamily.instances[1].removeEntityCalls, 2)
    }

    func test_componentAddedChecksWithAllFamilies() {
        engine.getNodeList(nodeClassType: MockNode1.self)
        engine.getNodeList(nodeClassType: MockNode2.self)
        let entity: Entity = Entity()
        try! engine.add(entity: entity)
        entity.add(component: PointComponent())
        XCTAssertEqual(MockFamily.instances[0].componentAddedCalls, 1)
        XCTAssertEqual(MockFamily.instances[1].componentAddedCalls, 1)
    }

    func test_componentRemovedChecksWithAllFamilies() {
        engine.getNodeList(nodeClassType: MockNode1.self)
        engine.getNodeList(nodeClassType: MockNode2.self)
        let entity: Entity = Entity()
        try! engine.add(entity: entity)
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
        try! engine.add(entity: Entity())
        try! engine.add(entity: Entity())
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
        try! engine.add(entity: entity)
        let other: Entity = engine.getEntity(named: "anything")!
        XCTAssertTrue(other === entity)
    }

    func test_getEntityByInvalidNameReturnsNil() {
        let entity: Entity? = engine.getEntity(named: "anything")
        XCTAssertNil(entity)
    }

    func test_entityCanBeObtainedByNameAfterRenaming() {
        let entity: Entity = Entity(named: "anything")
        try! engine.add(entity: entity)
        entity.name = "otherName"
        let other: Entity? = engine.getEntity(named: "otherName")
        XCTAssertTrue(other === entity)
    }

    func test_entityCannotBeObtainedByOldNameAfterRenaming() {
        let entity: Entity? = Entity(named: "anything")
        try! engine.add(entity: entity!)
        entity?.name = "otherName"
        let other: Entity? = engine.getEntity(named: "anything")
        XCTAssertNil(other)
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
    func newEntity(entity: Entity) { }

    func removeEntity(entity: Entity) { }

    func componentAddedToEntity(entity: Entity) { }

    func componentRemovedFromEntity(entity: Entity, componentClassName: ComponentClassName) { }
}
