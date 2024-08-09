//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

@testable import Swash
import XCTest

class ListIteratingSystemTest: XCTestCase {
    private var entities: [Entity] = []
    private var callCount: Int = 0

    func test_UpdateIteratesOverNodes() {
        let engine = Engine()
        let entity1 = Entity()
        let component1 = MockComponent()
        entity1.add(component: component1)
        engine.add(entity: entity1)

        let entity2 = Entity()
        let component2 = MockComponent()
        entity2.add(component: component2)
        engine.add(entity: entity2)

        let entity3 = Entity()
        let component3 = MockComponent()
        entity3.add(component: component3)
        engine.add(entity: entity3)

        let system = ListIteratingSystem(nodeClass: MockNode.self)
        system.nodeUpdateFunction = updateNode
        engine.add(system: system, priority: 1)

        entities = [entity1, entity2, entity3]
        callCount = 0
        engine.update(time: 0.1)

        XCTAssertEqual(callCount, 3)
    }

    func test_NodeAdded() {
        callCount = 0
        entities = []

        let engine = Engine()

        let entity1 = Entity()
            .add(component: MockComponent())
        entities.append(entity1)

        // SUT1
        engine.add(entity: entity1)

        let system = ListIteratingSystem(nodeClass: MockNode.self)
        system.nodeAddedFunction = addedNode
        engine.add(system: system, priority: 1)

        let entity2 = Entity()
            .add(component: MockComponent())
        entities.append(entity2)

        // SUT2
        engine.add(entity: entity2)

        XCTAssertEqual(callCount, 2)
    }

    func test_NodeRemoved() {
        callCount = 0
        entities = []

        let engine = Engine()

        let entity1 = Entity(named: "entity1")
            .add(component: MockComponent())
        entities.append(entity1)
        engine.add(entity: entity1)

        let system = ListIteratingSystem(nodeClass: MockNode.self)
        system.nodeRemovedFunction = removedNode
        engine.add(system: system, priority: 1)

        let entity2 = Entity(named: "entity2")
            .add(component: MockComponent())
        entities.append(entity2)
        engine.add(entity: entity2)

        // Both of these result in a call to remove node
        // This because the entire entity is removed
        engine.remove(entity: entity1)
        // This because the component relative to the MockNode is removed
        entity2.remove(componentClass: MockComponent.self)

        XCTAssertEqual(callCount, 2)
    }

    func test_RemovedFromSystem() {
        let engine = Engine()
        let system = ListIteratingSystem(nodeClass: MockNode.self)
        system.nodeUpdateFunction = updateNode
        system.nodeAddedFunction = addedNode
        system.nodeRemovedFunction = removedNode
        XCTAssertNil(system.nodeList)
        engine.add(system: system, priority: 1)
        XCTAssertNotNil(system.nodeList)
        // SUT
        engine.remove(system: system)
        XCTAssertNil(system.nodeList)

    }

    func updateNode(node: Node, time: TimeInterval) {
        XCTAssertEqual(node.entity, entities[callCount])
        XCTAssertEqual(time, 0.1)
        callCount += 1
    }

    func removedNode(node: Node) {
        XCTAssertEqual(node.entity, entities[callCount])
        callCount += 1
    }

    func addedNode(node: Node) {
        XCTAssertEqual(node.entity, entities[callCount])
        callCount += 1
    }

    class MockComponent: Component {}

    class MockNode: Node {
        var mockComponent: MockComponent?

        required init() {
            super.init()
            components = [MockComponent.name: nil]
        }
    }
}
