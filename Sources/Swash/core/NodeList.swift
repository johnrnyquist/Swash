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
public class NodeList {
    /// The first item in the node list, or nil if the list contains no nodes.
    public var head: Node?
    /// The last item in the node list, or nil if the list contains no nodes.
    public var tail: Node?
    /**
    A signal that is dispatched whenever a node is added to the node list.
    
    The signal will pass a single parameter to the listeners - the node that was added.
    */
    public var nodeAdded: Signaler1
    /**
    A signal that is dispatched whenever a node is removed from the node list.
    
    The signal will pass a single parameter to the listeners - the node that was removed.
    */
    public var nodeRemoved: Signaler1
    public var numNodes = 0

    public init() {
        nodeAdded = Signaler1()
        nodeRemoved = Signaler1()
    }

    func add(node: Node) {
        if head == nil {
            head = node
            tail = node
            node.next = nil
            node.previous = nil
        } else {
            tail?.next = node
            node.previous = tail
            node.next = nil
            tail = node
        }
        numNodes += 1
        nodeAdded.dispatch(node)
    }

    func remove(node: Node) {
        if head === node {
            head = head?.next
        }
        if tail === node {
            tail = tail?.previous
        }
        if let previous = node.previous {
            previous.next = node.next
        }
        if let next = node.next {
            next.previous = node.previous
        }
        numNodes -= 1
        nodeRemoved.dispatch(node)
    }

    func removeAll() {
        numNodes = 0
        while let node = head {
            head = node.next
            node.previous = nil
            node.next = nil
            nodeRemoved.dispatch(node)
        }
        tail = nil
    }

    /**
    true if the list is empty, false otherwise.
    */
    public var empty: Bool { head == nil }

    /**
    Swaps the positions of two nodes in the list. Useful when sorting a list.
    */
    public func swap(node1: Node, node2: Node) {
        if node1 === node2 {
            // No need to swap if both nodes are the same
            return
        } else if node1.next === node2 { // node1 is before node2
            let node0 = node1.previous
            let node3 = node2.next
            node0?.next = node2
            node2.previous = node0
            node2.next = node1
            node1.previous = node2
            node1.next = node3
            node3?.previous = node1
        } else if node2.next === node1 { // node2 is before node1
            let node0 = node2.previous
            let node3 = node1.next
            node0?.next = node1
            node1.previous = node0
            node1.next = node2
            node2.previous = node1
            node2.next = node3
            node3?.previous = node2
        } else { // node1 and node2 are not adjacent
            let node0 = node1.previous
            let node1next = node1.next
            let node2prev = node2.previous
            let node3 = node2.next
            node0?.next = node2
            node2.previous = node0
            node2.next = node1next
            node1next?.previous = node2
            node2prev?.next = node1
            node1.previous = node2prev
            node1.next = node3
            node3?.previous = node1
        }

        if head === node1 {
            head = node2
        } else if (head === node2) {
            head = node1
        }
        if tail === node1 {
            tail = node2
        } else if (tail === node2) {
            tail = node1
        }
        if let previous = node1.previous {
            previous.next = node1
        }
        if let previous = node2.previous {
            previous.next = node2
        }
        if let next = node1.next {
            next.previous = node1
        }
        if let next = node2.next {
            next.previous = node2
        }
    }

    /**
    Performs an insertion sort on the node list. In general, insertion sort is very efficient with short lists 
    and with lists that are mostly sorted, but is inefficient with large lists that are randomly ordered.
    The sort function takes two nodes and returns a Number.
    If the returned number is less than zero, the first node should be before the second. If it is greater
    than zero the second node should be before the first. If it is zero the order of the nodes doesn't matter
    and the original order will be retained.
    This insertion sort implementation runs in place so no objects are created during the sort.
    */
    public func insertionSort(sortFunction: (Node?, Node?) -> Int) {
        guard let headNode = head, let tailNode = tail, headNode !== tailNode else { return }
        var remains: Node? = headNode.next
        var node: Node? = remains
        while let currentNode = node {
            remains = currentNode.next
            var other: Node? = currentNode.previous
        inner:
            while let otherNode = other {
                if (sortFunction(currentNode, otherNode) >= 0) {
                    // move node to after other
                    if let otherNext = otherNode.next, currentNode !== otherNext {
                        // remove from place
                        if tailNode === currentNode {
                            tail = currentNode.previous
                        }
                        currentNode.previous?.next = currentNode.next
                        currentNode.next?.previous = currentNode.previous
                        // insert after other
                        currentNode.next = otherNext
                        currentNode.previous = otherNode
                        otherNext.previous = currentNode
                        otherNode.next = currentNode
                    }
                    break inner // exit the inner for loop
                }
                other = otherNode.previous //end inner
            }
            if other == nil // the node belongs at the start of the list
            {
                // remove from place
                if tailNode === currentNode {
                    tail = currentNode.previous
                }
                currentNode.previous?.next = currentNode.next
                currentNode.next?.previous = currentNode.previous
                // insert at head
                currentNode.next = head
                head?.previous = currentNode
                currentNode.previous = nil
                head = currentNode
            }
            node = remains //end outer
        }
    }

    public func toArray() -> [Node] {
        var array = [Node]()
        var node = head
        while let currentNode = node {
            array.append(currentNode)
            node = currentNode.next
        }
        return array
    }
}

