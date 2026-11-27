import XCTest
import Swash

final class ReplacementTests: XCTestCase {
    private final class Health: Component {
        let points: Int
        init(_ points: Int) { self.points = points }
    }

    private final class Visible: Component {}
    private final class HealthNode: Node {
        required init() { super.init(components: [Health.name: nil]) }
    }
    private final class VisibleHealthNode: Node {
        required init() { super.init(components: [Health.name: nil, Visible.name: nil]) }
    }

    func testReplacementUpdatesExistingNodesWithoutChangingMembership() throws {
        let engine = Engine()
        let entity = Entity().add(component: Health(10)).add(component: Visible())
        let neighbor = Entity().add(component: Health(20)).add(component: Visible())
        engine.add(entity: entity)
        engine.add(entity: neighbor)
        let groups = [engine.getNodeList(nodeClassType: HealthNode.self),
                      engine.getNodeList(nodeClassType: VisibleHealthNode.self)]
        let originals = groups.map { Array($0) }
        let newHealth = Health(40)
        var membershipChanges = 0
        for group in groups {
            group.nodeAdded.add(Listener { (_: Node) in membershipChanges += 1 })
            group.nodeRemoved.add(Listener { (_: Node) in membershipChanges += 1 })
        }

        entity.add(component: newHealth)

        XCTAssertTrue(entity[Health.self] === newHealth)
        for (index, group) in groups.enumerated() {
            XCTAssertEqual(Array(group), originals[index])
            let node = try XCTUnwrap(group.head)
            XCTAssertTrue(node[Health.self] === newHealth)
            XCTAssertEqual(node[Health.self]?.points, 40)
        }
        XCTAssertEqual(membershipChanges, 0)
    }
}
