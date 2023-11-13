import struct Foundation.UUID

/// A node in the list of listeners in a signal.
final public class ListenerNode {
    private let _id = UUID()
    public var next: ListenerNode?
    public var previous: ListenerNode?
    public var listener: Listener? // Function in AS3
    public var once = false
}

extension ListenerNode: Identifiable {
    public var id: UUID { _id }
}

extension ListenerNode: Equatable {
    static public func ==(lhs: ListenerNode, rhs: ListenerNode) -> Bool {
        lhs.id == rhs.id
    }
}
