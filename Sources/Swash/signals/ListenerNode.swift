
/// A node in the list of listeners in a signal.
final public class ListenerNode {
    public var next: ListenerNode?
    public var previous: ListenerNode?
    public var listener: Listener? // Function in AS3
    public var once = false
}

extension ListenerNode: Equatable {
    static public func ==(lhs: ListenerNode, rhs: ListenerNode) -> Bool {
        lhs === rhs
    }
}
