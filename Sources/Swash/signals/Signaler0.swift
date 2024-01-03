/// Provides a fast signal for use where no parameters are dispatched with the signal. 
/// The zero in the name means zero parameters.
final public class Signaler0: Signaler {
    override public init() {
        super.init()
    }

    public func dispatch() {
        startDispatch()
        var node = head
        while let currentNode = node {
            currentNode.listener?()
            if currentNode.once {
                if let listener = currentNode.listener {
                    remove(listener)
                }
            }
            node = currentNode.next
        }
        endDispatch()
    }
}
