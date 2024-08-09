//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import struct Foundation.TimeInterval

/// The 1 in the name means 1 parameter in its dispatch method.
open class Signaler1: Signaler {
    
    override public init() {}

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
