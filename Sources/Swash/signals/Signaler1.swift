import struct Foundation.TimeInterval

/// The 1 in the name means 1 parameter.
public class Signaler1: Signaler {
    private var type: Node.Type? = nil
    private weak var entity: Entity? = nil

    public override init() { 
        super.init()
    }

    public init(_ type: Node.Type) {
        self.type = type
        super.init()
    }

    public init(_ entity: Entity) {
        self.entity = entity
        super.init()
    }

    public func dispatch(_ object: TimeInterval) {
        startDispatch()
        var node = head
        while node != nil {
            node?.listener?(object)
            if node?.once ?? false {
                if let listener = node?.listener {
                    remove(listener)
                }
            }
            node = node?.next
        }
        endDispatch()
    }

    public func dispatch(_ object: Node) {
        startDispatch()
        var node = head
        while node != nil {
            node?.listener?(object)
            if node?.once ?? false {
                if let listener = node?.listener {
                    remove(listener)
                }
            }
            node = node?.next
        }
        endDispatch()
    }

    public func dispatch(_ object: Entity) {
        startDispatch()
        var node = head
        while node != nil {
            node?.listener?(object)
            if node?.once ?? false {
                if let listener = node?.listener {
                    remove(listener)
                }
            }
            node = node?.next
        }
        endDispatch()
    }
}
