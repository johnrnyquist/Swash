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
