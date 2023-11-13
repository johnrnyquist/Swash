//
//  NodeListTests.swift
//  SwashTests
//
//  Created by John Nyquist on 11/14/22.
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
        while node != nil {
            let index = nodeArray.firstIndex(of: node!)!
            nodeArray.remove(at: index)
            node = node!.next
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
        while node != nil {
            let index = nodeArray.firstIndex(of: node!)!
            nodeArray.remove(at: index)
            count += 1
            if (count == 2) {
                nodes.remove(node: node!)
            }
            node = node!.next
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
        while node != nil {
            let index = nodeArray.firstIndex(of: node!)!
            nodeArray.remove(at: index)
            count += 1
            if (count == 2) {
                nodes.remove(node: node!.next!)
            }
            node = node!.next
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
        var array = [Node]()
        var node = nodes.head //as? MockPosNode
        while node != nil {
            array.append(node!)
            node = node!.next
        }
        XCTAssertTrue(array == [node1, node2, node3])
    }

    func test_swappingOnlyTwoNodesChangesTheirOrder() {
        let node1 = MockPosNode()
        let node2 = MockPosNode()
        nodes.add(node: node1)
        nodes.add(node: node2)
        nodes.swap(node1: node1, node2: node2)
        var array = [Node]()
        var node = nodes.head //as? MockPosNode
        while node != nil {
            array.append(node!)
            node = node!.next
        }
        XCTAssertTrue(array == [node2, node1])
    }

    func test_swappingAdjacentNodesChangesTheirPositions() {
        let node1 = MockPosNode()
        let node2 = MockPosNode()
        let node3 = MockPosNode()
        let node4 = MockPosNode()
        nodes.add(node: node1)
        nodes.add(node: node2)
        nodes.add(node: node3)
        nodes.add(node: node4)
        nodes.swap(node1: node2, node2: node3)
        var array = [Node]()
        var node = nodes.head
        while node != nil {
            array.append(node!)
            node = node!.next
        }
        XCTAssertTrue(array == [node1, node3, node2, node4])
    }

    func test_swappingNonAdjacentNodesChangesTheirPositions() {
        let node1 = MockPosNode()
        let node2 = MockPosNode()
        let node3 = MockPosNode()
        let node4 = MockPosNode()
        let node5 = MockPosNode()
        nodes.add(node: node1)
        nodes.add(node: node2)
        nodes.add(node: node3)
        nodes.add(node: node4)
        nodes.add(node: node5)
        nodes.swap(node1: node2, node2: node4)
        var array = [Node]()
        var node = nodes.head
        while node != nil {
            array.append(node!)
            node = node!.next
        }
        XCTAssertTrue(array == [node1, node4, node3, node2, node5])
    }

    func test_swappingEndNodesChangesTheirPositions() {
        let node1 = MockPosNode()
        let node2 = MockPosNode()
        let node3 = MockPosNode()
        nodes.add(node: node1)
        nodes.add(node: node2)
        nodes.add(node: node3)
        nodes.swap(node1: node1, node2: node3)
        var array = [Node]()
        var node = nodes.head
        while node != nil {
            array.append(node!)
            node = node!.next
        }
        XCTAssertTrue(array == [node3, node2, node1])
    }

    func sortFunction(_ node1: Node?, _ node2: Node?) -> Int {
        guard let node1 = node1 as? MockPosNode,
              let node2 = node2 as? MockPosNode
        else { fatalError() }
        return node1.pos - node2.pos
    }

    func test_insertionSortCorrectlySortsSortedNodes() {
        let node1 = MockPosNode(1)
        let node2 = MockPosNode(2)
        let node3 = MockPosNode(3)
        let node4 = MockPosNode(4)
        nodes.add(node: node1)
        nodes.add(node: node2)
        nodes.add(node: node3)
        nodes.add(node: node4)
        nodes.insertionSort(sortFunction: sortFunction)
        var array = [Node]()
        var node = nodes.head
        while node != nil {
            array.append(node!)
            node = node!.next
        }
        XCTAssertTrue(array == [node1, node2, node3, node4])
    }

    func test_insertionSortCorrectlySortsReversedNodes() {
        let node1 = MockPosNode(1)
        let node2 = MockPosNode(2)
        let node3 = MockPosNode(3)
        let node4 = MockPosNode(4)
        nodes.add(node: node4)
        nodes.add(node: node3)
        nodes.add(node: node2)
        nodes.add(node: node1)
        nodes.insertionSort(sortFunction: sortFunction)
        var array = [Node]()
        var node = nodes.head
        while node != nil {
            array.append(node!)
            node = node!.next
        }
        XCTAssertTrue(array == [node1, node2, node3, node4])
    }

    func test_insertionSortCorrectlySortsMixedNodes() {
        let node1 = MockPosNode(1)
        let node2 = MockPosNode(2)
        let node3 = MockPosNode(3)
        let node4 = MockPosNode(4)
        let node5 = MockPosNode(5)
        nodes.add(node: node3)
        nodes.add(node: node4)
        nodes.add(node: node1)
        nodes.add(node: node5)
        nodes.add(node: node2)
        nodes.insertionSort(sortFunction: sortFunction)
        var array = [Node]()
        var node = nodes.head
        while node != nil {
            array.append(node!)
            node = node!.next
        }
        XCTAssertTrue(array == [node1, node2, node3, node4, node5])
    }

    func test_insertionSortRetainsTheOrderOfEquivalentNodes() {
        let node1 = MockPosNode(1)
        let node2 = MockPosNode(1)
        let node3 = MockPosNode(3)
        let node4 = MockPosNode(4)
        let node5 = MockPosNode(4)
        nodes.add(node: node3)
        nodes.add(node: node4)
        nodes.add(node: node1)
        nodes.add(node: node5)
        nodes.add(node: node2)
        nodes.insertionSort(sortFunction: sortFunction)
        var array = [Node]()
        var node = nodes.head
        while node != nil {
            array.append(node!)
            node = node!.next
        }
        XCTAssertTrue(array == [node1, node2, node3, node4, node5])
    }
}

/*
func test_mergeSortCorrectlySortsSortedNodes() {
    var node1 = MockPosNode(1)
    var node2 = MockPosNode(2)
    var node3 = MockPosNode(3)
    var node4 = MockPosNode(4)
    nodes.add(node1)
    nodes.add(node2)
    nodes.add(node3)
    nodes.add(node4)
    nodes.mergeSort(sortFunction)
    assertThat(nodes, nodeList(node1, node2, node3, node4))
}
func test_mergeSortCorrectlySortsReversedNodes() {
    var node1 = MockPosNode(1)
    var node2 = MockPosNode(2)
    var node3 = MockPosNode(3)
    var node4 = MockPosNode(4)
    nodes.add(node4)
    nodes.add(node3)
    nodes.add(node2)
    nodes.add(node1)
    nodes.mergeSort(sortFunction)
    assertThat(nodes, nodeList(node1, node2, node3, node4))
}
func test_mergeSortCorrectlySortsMixedNodes() {
    var node1 = MockPosNode(1)
    var node2 = MockPosNode(2)
    var node3 = MockPosNode(3)
    var node4 = MockPosNode(4)
    var node5 = MockPosNode(5)
    nodes.add(node3)
    nodes.add(node4)
    nodes.add(node1)
    nodes.add(node5)
    nodes.add(node2)
    nodes.mergeSort(sortFunction)
    assertThat(nodes, nodeList(node1, node2, node3, node4, node5))
}
}
}
*/
