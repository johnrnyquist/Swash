/// Instances of this class can dispatch a "signal" to its listners.
/// This is a base class, it should not be instantiated.
public class Signaler {
    var head: ListenerNode?
    var tail: ListenerNode?
    private var nodes: [Listener: ListenerNode] = [:]
    private var listenerNodePool: ListenerNodePool
    private var toAddHead: ListenerNode?
    private var toAddTail: ListenerNode?
    private var dispatching = false
    private var _numListeners = 0

    public init() {
        nodes = [:]
        listenerNodePool = ListenerNodePool()
    }

    func startDispatch() {
        dispatching = true
    }

    func endDispatch() {
        dispatching = false
        if (toAddHead != nil) {
            if head == nil {
                head = toAddHead
                tail = toAddTail
            } else {
                tail?.next = toAddHead
                toAddHead?.previous = tail
                tail = toAddTail
            }
            toAddHead = nil
            toAddTail = nil
        }
        listenerNodePool.releaseCache()
    }

    public var numListeners: Int {
        return _numListeners
    }

    public func add(_ listener: Listener) {
        if nodes[listener] != nil {
            return
        }
        if let node = listenerNodePool.get() {
            node.listener = listener
            nodes[listener] = node
            addNode(node)
        }
    }

    public func addOnce(_ listener: Listener) {
        if nodes[listener] != nil {
            return
        }
        if let node = listenerNodePool.get() {
            node.listener = listener
            node.once = true
            nodes[listener] = node
            addNode(node)
        }
    }

    public func addNode(_ node: ListenerNode) {
        if dispatching {
            if toAddHead == nil {
                toAddHead = node
                toAddTail = node
            } else {
                toAddTail?.next = node
                node.previous = toAddTail
                toAddTail = node
            }
        } else {
            if head == nil {
                head = node
                tail = node
            } else {
                tail?.next = node
                node.previous = tail
                tail = node
            }
        }
        _numListeners += 1
    }

    public func remove(_ listener: Listener) {
        let node: ListenerNode? = nodes[listener]
        if node != nil {
            if head == node {
                head = head?.next
            }
            if tail == node {
                tail = tail?.previous
            }
            if (toAddHead == node) {
                toAddHead = toAddHead?.next
            }
            if toAddTail == node {
                toAddTail = toAddTail?.previous
            }
            if node?.previous != nil {
                node?.previous?.next = node?.next
            }
            if node?.next != nil {
                node?.next?.previous = node?.previous
            }
            nodes.removeValue(forKey: listener)
            if dispatching {
                listenerNodePool.cache(node)
            } else {
                listenerNodePool.dispose(node)
            }
            _numListeners -= 1
        }
    }

    public func removeAll() {
        while head != nil {
            let node: ListenerNode? = head
            head = head?.next
            nodes.removeValue(forKey: node!.listener!) //HACK
            listenerNodePool.dispose(node)
        }
        tail = nil
        toAddHead = nil
        toAddTail = nil
        _numListeners = 0
    }
}


