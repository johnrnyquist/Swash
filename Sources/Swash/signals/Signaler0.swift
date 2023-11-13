/// Provides a fast signal for use where no parameters are dispatched with the signal. 
/// The zero in the name means zero parameters.
final public class Signaler0: Signaler {
    override public init() {
        super.init()
    }

    public func dispatch() {
        startDispatch()
        var node = head
        while node != nil {
            node?.listener?()
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
