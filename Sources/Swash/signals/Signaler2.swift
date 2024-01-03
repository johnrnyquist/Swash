/// The 2 in the name means 2 parameters.
/// Only used in Entity class
final public class Signaler2: Signaler {
    public init(_ entity: Entity, _ value: Any?) {
        super.init()
    }

    public func dispatch(_ object1: Entity, _ object2: ComponentClassName) {
        startDispatch()
        var node = head
        while let currentNode = node {
            node?.listener?(object1, object2)
            if node?.once ?? false {
                if let listener = currentNode.listener {
                    remove(listener)
                }
            }
            node = currentNode.next
        }
        endDispatch()
    }
}
