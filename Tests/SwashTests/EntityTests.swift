import XCTest
@testable import Swash

final class EntityTests: XCTestCase {
    var entity: Entity!

    override func setUpWithError() throws {
        Entity.nameCount = 0
        entity = Entity()
    }

    override func tearDownWithError() throws {
        entity = nil
    }

    func test_name() throws {
        XCTAssertEqual(entity.name, "_entity1")
    }

    func test_addComponent() {
        let mockComponent = MockComponent()
        entity.add(component: mockComponent)
        XCTAssertEqual(entity.componentClassNameInstanceMap.count, 1)
    }

    /**********/
    func test_addReturnsReferenceToEntity() {
        let component: MockComponent = MockComponent()
        let e: Entity = entity.add(component: component)
        XCTAssertTrue(e === entity)
    }

    func test_canStoreAndRetrieveComponent() {
        let component: MockComponent = MockComponent()
        entity.add(component: component)
        XCTAssertTrue(entity[MockComponent.self] === component)
    }

    func test_canStoreAndRetrieveMultipleComponents() {
        let component1: MockComponent = MockComponent()
        entity.add(component: component1)
        let component2: MockComponent2 = MockComponent2()
        entity.add(component: component2)
        XCTAssertTrue(entity[MockComponent.self] === component1)
        XCTAssertTrue(entity[MockComponent2.self] === component2)
    }

    func test_canReplaceComponent() {
        let component1: MockComponent = MockComponent()
        entity.add(component: component1)
        let component2: MockComponent = MockComponent()
        entity.add(component: component2)
        XCTAssertTrue(entity[MockComponent.self] === component2)
    }

    func test_canStoreBaseAndExtendedComponents() {
        let component1: MockComponent = MockComponent()
        entity.add(component: component1)
        let component2: MockComponentExtended = MockComponentExtended()
        entity.add(component: component2)
        XCTAssertTrue(entity[MockComponent.self] === component1)
        XCTAssertTrue(entity[MockComponentExtended.self] === component2)
    }

    // TODO: This may be a problem. 
    func xtest_canStoreExtendedComponentAsBaseType() {
        let component = MockComponentExtended()
        entity.add(component: component)
        XCTAssertTrue(entity[MockComponent.self] === component)
    }

    func test_getReturnNilIfNoComponent() {
        XCTAssertNil(entity[MockComponent.self])
    }

    func test_willRetrieveAllComponents() {
        let component1: MockComponent = MockComponent()
        entity.add(component: component1)
        let component2: MockComponent2 = MockComponent2()
        entity.add(component: component2)
        let all: Array = entity.components
        XCTAssertEqual(all.count, 2)
        XCTAssertTrue(all.contains(component1))
        XCTAssertTrue(all.contains(component2))
    }

    func test_hasComponentIsFalseIfComponentTypeNotPresent() {
        entity.add(component: MockComponent2())
        XCTAssertFalse(entity.has(componentClassName: "\(MockComponent.self)"))
    }

    func test_hasComponentIsTrueIfComponentTypeIsPresent() {
        entity.add(component: MockComponent())
        XCTAssertTrue(entity.has(componentClassName: "\(MockComponent.self)"))
    }

    func test_canRemoveComponent() {
        let component: MockComponent = MockComponent()
        entity.add(component: component)
        entity.remove(componentClass: MockComponent.self)
        XCTAssertFalse(entity.has(componentClassName: "\(MockComponent.self)"))
    }

    func test_noComponentToRemove() {
        let result = entity.remove(componentClass: MockComponent.self)
        XCTAssertEqual(entity, result)
    }

    func test_removeAllComponents() {
        let component1: MockComponent = MockComponent()
        let component2: MockComponent2 = MockComponent2()
        entity.add(component: component1)
        entity.add(component: component2)
        XCTAssertEqual(entity.componentClassNameInstanceMap.count, 2)
        entity.removeAllComponents()
        XCTAssertEqual(entity.componentClassNameInstanceMap.count, 0)
    }

    func test_testEntityHasNameByDefault() {
        entity = Entity()
        XCTAssertGreaterThan(entity.name.count, 0)
    }

    func test_testEntityNameStoredAndReturned() {
        let name: String = "anything"
        entity = Entity(named: name)
        XCTAssertEqual(entity.name, name)
    }

    func test_testEntityNameCanBeChanged() {
        entity = Entity(named: "anything")
        entity.name = "otherThing"
        XCTAssertEqual(entity.name, "otherThing")
    }

    func nameChangedSignal(signalEntity: Entity, oldName: String) {
        XCTAssertTrue(signalEntity === entity)
        XCTAssertEqual(entity.name, "otherThing")
        XCTAssertEqual(oldName, "anything")
    }
}
