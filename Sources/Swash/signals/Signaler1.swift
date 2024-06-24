import struct Foundation.TimeInterval

/// The 1 in the name means 1 parameter in its dispatch method.
open class Signaler1: Signaler {
    private weak var entity: Entity? = nil

    public override init() { 
        super.init()
    }
    
    public init(_ entity: Entity) {
        self.entity = entity
        super.init()
    }

    public func dispatch(_ object: TimeInterval) {
        startDispatch()
        var listenerNode = head
        while let currentNode = listenerNode {
            currentNode.listener?(object)
            if currentNode.once {
                if let listener = currentNode.listener {
                    remove(listener)
                }
            }
            listenerNode = currentNode.next
        }
        endDispatch()
    }

    public func dispatch(_ object: Node) {
        startDispatch()
        var listenerNode = head
        while let currentNode = listenerNode {
            currentNode.listener?(object)
            if currentNode.once {
                if let listener = currentNode.listener {
                    remove(listener)
                }
            }
            listenerNode = currentNode.next
        }
        endDispatch()
    }

    public func dispatch(_ object: Entity) {
        startDispatch()
        var listenerNode = head
        while let currentNode = listenerNode {
            currentNode.listener?(object)
            if currentNode.once {
                if let listener = currentNode.listener {
                    remove(listener)
                }
            }
            listenerNode = currentNode.next
        }
        endDispatch()
    }
}
