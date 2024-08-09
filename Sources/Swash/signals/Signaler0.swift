//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

/// The zero in the name means zero parameters in the dispatch method.
final public class Signaler0: Signaler {
    override public init() {
        super.init()
    }

    public func dispatch() {
        startDispatch()
        var listenerNode = head
        while let currentNode = listenerNode {
            currentNode.listener?()
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
