//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

/// The 2 in the name means 2 parameters in its dispatch method.
/// Only used in Entity class
final public class Signaler2: Signaler {
    public func dispatch(_ object1: Entity, _ object2: ComponentClassName) {
        startDispatch()
        var listenerNode = head
        while let currentNode = listenerNode {
            listenerNode?.listener?(object1, object2)
            if listenerNode?.once ?? false {
                if let listener = currentNode.listener {
                    remove(listener)
                }
            }
            listenerNode = currentNode.next
        }
        endDispatch()
    }
}
