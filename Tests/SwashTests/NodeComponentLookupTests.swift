import Swash
import XCTest

final class NodeComponentLookupTests: XCTestCase {
    private class Base: Component {}
    private enum First {
        final class Marker: Base {}
    }
    private enum Second {
        final class Marker: Base {}
    }
    private typealias FirstMarker = First.Marker

    private final class MarkerNode: Node {
        required init() {
            super.init(components: [First.Marker.name: nil, Second.Marker.name: nil])
        }
    }

    func testFamilyNodeDistinguishesTypesWithTheSameShortName() throws {
        let engine = Engine()
        let nodes = engine.getNodeList(nodeClassType: MarkerNode.self)
        let first = First.Marker()
        let second = Second.Marker()
        engine.add(entity: Entity().add(component: first).add(component: second))
        let node = try XCTUnwrap(nodes.head)

        XCTAssertTrue(node[FirstMarker.self] === first)
        XCTAssertTrue(node[Second.Marker.self] === second)
        XCTAssertNil(node[Base.self])
    }

    func testTypedReadsObservePublicDictionaryMutations() throws {
        let engine = Engine()
        let nodes = engine.getNodeList(nodeClassType: MarkerNode.self)
        let first = First.Marker()
        let second = Second.Marker()
        engine.add(entity: Entity().add(component: first).add(component: second))
        let node = try XCTUnwrap(nodes.head)
        let replacement = First.Marker()

        node.components[First.Marker.name] = replacement
        XCTAssertTrue(node[First.Marker.self] === replacement)
        node.components[First.Marker.name] = second
        XCTAssertNil(node[First.Marker.self])
        node.components.updateValue(nil, forKey: First.Marker.name)
        XCTAssertNil(node[First.Marker.self])
        node.components = ["alternate": first, Base.name: replacement]
        XCTAssertNil(node[First.Marker.self])
        XCTAssertNil(node[Second.Marker.self])
        XCTAssertTrue(node[Base.self] === replacement)
        let baseType: Base.Type = First.Marker.self
        XCTAssertTrue(node[baseType] === replacement)
        XCTAssertTrue((node.components["alternate"] ?? nil) === first)
    }

    func testManualNodesUseTheRequestedGenericTypeAndItsDictionaryKey() {
        let first = First.Marker()
        let second = Second.Marker()
        let node = Node(components: [First.Marker.name: first, Base.name: second])
        let baseType: Base.Type = First.Marker.self

        XCTAssertTrue(node[FirstMarker.self] === first)
        XCTAssertTrue(node[baseType] === second)
        XCTAssertNil(node[Second.Marker.self])

        let customNode = MarkerNode()
        customNode.components[Second.Marker.name] = second
        XCTAssertTrue(customNode[Second.Marker.self] === second)
        XCTAssertNil(customNode[First.Marker.self])
    }

    func testPoolClearsAndRebindsTypedReads() throws {
        let engine = Engine()
        let nodes = engine.getNodeList(nodeClassType: MarkerNode.self)
        let node: Node
        weak var oldMarker: First.Marker?
        do {
            let first = First.Marker()
            let original = Entity().add(component: first).add(component: Second.Marker())
            engine.add(entity: original)
            node = try XCTUnwrap(nodes.head)
            oldMarker = first
            XCTAssertTrue(node[First.Marker.self] === first)
            engine.remove(entity: original)
        }
        XCTAssertNil(oldMarker)
        XCTAssertNil(node[First.Marker.self])
        XCTAssertNil(node[Second.Marker.self])

        let replacement = First.Marker()
        let other = Second.Marker()
        engine.add(entity: Entity().add(component: replacement).add(component: other))
        XCTAssertTrue(nodes.head === node)
        XCTAssertTrue(node[First.Marker.self] === replacement)
        XCTAssertTrue(node[Second.Marker.self] === other)
    }
}
