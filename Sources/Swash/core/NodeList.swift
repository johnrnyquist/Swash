/**
A collection of nodes.
Systems within the engine access the components of entities via NodeLists. A NodeList contains
a node for each Entity in the engine that has all the components required by the node. To iterate
over a NodeList, start from the head and step to the next on each loop, until the returned value
is null.
 
It is safe to remove items from a nodelist during the loop. When a Node is removed form the 
NodeList it's previous and next properties still point to the nodes that were before and after
it in the NodeList just before it was removed.
*/
public class NodeList {
    /// The first item in the node list, or null if the list contains no nodes.
    public var head: Node?
    /// The last item in the node list, or null if the list contains no nodes.
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
        nodeAdded = Signaler1(Node.self)
        nodeRemoved = Signaler1(Node.self)
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
        if head == node {
            head = head?.next
        }
        if tail == node {
            tail = tail?.previous
        }
        if node.previous != nil {
            node.previous?.next = node.next
        }
        if node.next != nil {
            node.next?.previous = node.previous
        }
        numNodes -= 1
        nodeRemoved.dispatch(node)
    }

    func removeAll() {
        numNodes = 0
        while head != nil {
            let node: Node? = head
            head = node?.next
            node?.previous = nil
            node?.next = nil
            nodeRemoved.dispatch(node!)
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
        if node1.previous != nil {
            node1.previous?.next = node1
        }
        if node2.previous != nil {
            node2.previous?.next = node2
        }
        if node1.next != nil {
            node1.next?.previous = node1
        }
        if node2.next != nil {
            node2.next?.previous = node2
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
        guard head != tail else { return }
        var remains: Node? = head?.next
        var node: Node? = remains
        while node != nil {
            remains = node?.next
            var other: Node? = node?.previous
            inner:
            while other != nil {
                if (sortFunction(node, other) >= 0) {
                    // move node to after other
                    if node != other?.next {
                        // remove from place
                        if tail == node {
                            tail = node?.previous
                        }
                        node?.previous?.next = node?.next
                        if node?.next != nil {
                            node?.next?.previous = node?.previous
                        }
                        // insert after other
                        node?.next = other?.next
                        node?.previous = other
                        node?.next?.previous = node
                        other?.next = node
                    }
                    break inner // exit the inner for loop
                }
                other = other?.previous //end inner
            }
            if other == nil // the node belongs at the start of the list
            {
                // remove from place
                if tail == node {
                    tail = node?.previous
                }
                node?.previous?.next = node?.next
                if node?.next != nil {
                    node?.next?.previous = node?.previous
                }
                // insert at head
                node?.next = head
                head?.previous = node
                node?.previous = nil
                head = node
            }
            node = remains //end outer
        }
    }
    
    public func toArray() -> [Node] {
        var array = [Node]()
        var node = head
        while node != nil {
            array.append(node!)
            node = node!.next
        }
        return array
    }

    /* THESE ARE NOT USED, CONVERSION IS LOW PRIORITY
    /**
    Performs a merge sort on the node list. In general, merge sort is more efficient than insertion sort
    with long lists that are very unsorted.
    
    The sort function takes two nodes and returns a Number.
    
    <code>function sortFunction( node1 : MockNode, node2 : MockNode ) : Number</code>
    
    If the returned number is less than zero, the first node should be before the second. If it is greater
    than zero the second node should be before the first. If it is zero the order of the nodes doesn't matter.
    
    This merge sort implementation creates and uses a single Vector during the sort operation.
    */
public function mergeSort(sortFunction: Function) : void {
    if (head == tail) {
        return
    }
    var lists: Vector.<Node> = new Vector .< Node>
    // disassemble the list
    var start: Node = head
    var end: Node
    while (start) {
        end = start
        while (end.next && sortFunction(end, end.next) <= 0) {
            end = end.next
        }
        var next: Node = end.next
        start.previous = end.next = null
        lists[lists.length] = start
        start = next
    }
    // reassemble it in order
    while (lists.length > 1) {
        lists.push(merge(lists.shift(), lists.shift(), sortFunction))
    }
    // find the tail
    tail = head = lists[0]
    while (tail.next) {
        tail = tail.next
    }
}
private function merge(head1: Node?, head2: Node?, sortFunction: Function) : Node {
    var node: Node
    var head: Node
    if (sortFunction(head1, head2) <= 0) {
        head = node = head1
        head1 = head1.next
    } else {
        head = node = head2
        head2 = head2.next
    }
    while (head1 && head2) {
        if (sortFunction(head1, head2) <= 0) {
            node.next = head1
            head1.previous = node
            node = head1
            head1 = head1.next
        } else {
            node.next = head2
            head2.previous = node
            node = head2
            head2 = head2.next
        }
    }
    if head1 != nil {
        node.next = head1
        head1.previous = node
    } else {
        node.next = head2
        head2.previous = node
    }
    return head
}
    */
}

