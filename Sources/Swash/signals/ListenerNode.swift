/// A node in the list of listeners in a signal.
final public class ListenerNode {
    public var next: ListenerNode?
    public var previous: ListenerNode?
    public var listener: Listener? // Function in AS3
    public var once = false

    public func remove() {
        previous?.next = next
        next?.previous = previous
        next = nil
        previous = nil
    }
}

extension ListenerNode: Equatable {
    static public func ==(lhs: ListenerNode, rhs: ListenerNode) -> Bool {
        lhs === rhs
    }
}

extension ListenerNode: Sequence {
    public func makeIterator() -> ListenerNodeIterator {
        ListenerNodeIterator(current: self)
    }
}

public class ListenerNodeIterator: IteratorProtocol {
    private var current: ListenerNode?

    init(current: ListenerNode?) {
        self.current = current
    }

    public func next() -> ListenerNode? {
        let node = current
        current = current?.next
        return node
    }
}