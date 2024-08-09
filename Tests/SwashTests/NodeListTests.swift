//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
@testable import Swash

final class NodeListTests: XCTestCase {
    var nodes: NodeList!

    override func setUpWithError() throws {
        nodes = NodeList()
    }

    override func tearDownWithError() throws {
        nodes = nil
    }

    func test_addingNodeTriggersAddedSignal() {
        var result = 0
        let node = MockPosNode()
        nodes.nodeAdded.add(Listener { (node: Node) in result = 1 })
        nodes.add(node: node)
        XCTAssertEqual(result, 1)
    }

    func test_removingNodeTriggersRemovedSignal() {
        var result = 0
        let node = MockPosNode()
        nodes.add(node: node)
        nodes.nodeRemoved.add(Listener { (node: Node) in result = 1 })
        nodes.remove(node: node)
        XCTAssertEqual(result, 1)
    }

    func test_AllNodesAreCoveredDuringIteration() {
        var nodeArray = [Node]()
        for _ in 1...5 {
            let node = MockPosNode()
            nodeArray.append(node)
            nodes.add(node: node)
        }
        var node = nodes.head //as? MockPosNode
        while let currentNode = node {
            let index = nodeArray.firstIndex(of: currentNode)!
            nodeArray.remove(at: index)
            node = currentNode.next
        }
        XCTAssertTrue(nodeArray.isEmpty)
    }

    func test_removingCurrentNodeDuringIterationIsValid() {
        var nodeArray = [Node]()
        for _ in 1...5 {
            let node = MockPosNode()
            nodeArray.append(node)
            nodes.add(node: node)
        }
        var count = 0
        var node = nodes.head //as? MockPosNode
        while let currentNode = node {
            let index = nodeArray.firstIndex(of: currentNode)!
            nodeArray.remove(at: index)
            count += 1
            if (count == 2) {
                nodes.remove(node: currentNode)
            }
            node = currentNode.next
        }
        XCTAssertTrue(nodeArray.isEmpty)
    }

    func test_removingNextNodeDuringIterationIsValid() {
        var nodeArray = [Node]()
        for _ in 1...5 {
            let node = MockPosNode()
            nodeArray.append(node)
            nodes.add(node: node)
        }
        var count = 0
        var node = nodes.head //as? MockPosNode
        while let currentNode = node {
            let index = nodeArray.firstIndex(of: currentNode)!
            nodeArray.remove(at: index)
            count += 1
            if (count == 2) {
                nodes.remove(node: currentNode.next!)
            }
            node = currentNode.next
        }
        XCTAssertEqual(nodeArray.count, 1)
    }

    var tempNode: Node!

    func test_componentAddedSignalContainsCorrectParameters() {
        tempNode = MockPosNode()
        nodes.nodeAdded.add(Listener(assertSignalContent))
        nodes.add(node: tempNode)
    }

    func test_componentRemovedSignalContainsCorrectParameters() {
        tempNode = MockPosNode()
        nodes.add(node: tempNode)
        nodes.nodeRemoved.add(Listener(assertSignalContent))
        nodes.remove(node: tempNode)
    }

    func assertSignalContent(_ signalNode: Node) {
        XCTAssertTrue(signalNode === tempNode)
    }

    func test_nodesInitiallySortedInOrderOfAddition() {
        let node1 = MockPosNode()
        let node2 = MockPosNode()
        let node3 = MockPosNode()
        nodes.add(node: node1)
        nodes.add(node: node2)
        nodes.add(node: node3)
        XCTAssertEqual(Array(nodes), [node1, node2, node3])
    }
}
