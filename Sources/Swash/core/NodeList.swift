//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//
/**
A collection of nodes.
Systems within the engine access the components of entities via NodeLists. A NodeList contains
a node for each Entity in the engine that has all the components required by the node. To iterate
over a NodeList, start from the head and step to the next on each loop, until the returned value
is nil.
It is safe to remove items from a nodelist during the loop. When a Node is removed form the 
NodeList it's previous and next properties still point to the nodes that were before and after
it in the NodeList just before it was removed.
*/
final public class NodeList: Sequence, Collection {
    public var head: Node?
    public var tail: Node?
    /**
    A signal that is dispatched whenever a node is added to the node list.
    
    The signal will pass a single parameter to the listeners - the node that was added.
    */
    public var nodeAdded = Signaler1()
    /**
    A signal that is dispatched whenever a node is removed from the node list.
    
    The signal will pass a single parameter to the listeners - the node that was removed.
    */
    public var nodeRemoved = Signaler1()
    public var numNodes = 0

    public init() {}

    func add(node: Node) {
        if head == nil {
            head = node
            tail = node
            node.previous = nil
        } else {
            tail?.next = node
            node.previous = tail
            tail = node
        }
        node.next = nil
        numNodes += 1
        nodeAdded.dispatch(node)
    }

    func remove(node: Node) {
        if head === node {
            head = node.next
        }
        if tail === node {
            tail = node.previous
        }
        node.previous?.next = node.next
        node.next?.previous = node.previous
        numNodes -= 1
        nodeRemoved.dispatch(node)
    }

    func removeAll() {
        while let node = head {
            head = node.next
            node.previous = nil
            node.next = nil
            nodeRemoved.dispatch(node)
        }
        tail = nil
        numNodes = 0
    }

    public var empty: Bool { head == nil }

    // Sequence conformance
    public func makeIterator() -> NodeListIterator {
        NodeListIterator(current: head)
    }

    // Collection conformance
    public var startIndex: Int { 0 }
    public var endIndex: Int { numNodes }

    public var count: Int {
        var count = 0
        var node = head
        while let current = node {
            count += 1
            node = current.next
        }
        return count
    }

    public func index(after i: Int) -> Int { i + 1 }

    public subscript(position: Int) -> Node {
        var current = head
        for _ in 0..<position {
            current = current?.next
        }
        guard let node = current else {
            fatalError("Index out of bounds")
        }
        return node
    }
}

public struct NodeListIterator: IteratorProtocol {
    var current: Node?

    public mutating func next() -> Node? {
        let node = current
        current = current?.next
        return node
    }
}
