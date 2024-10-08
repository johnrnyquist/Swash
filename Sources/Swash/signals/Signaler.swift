//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

/// Instances of this class can dispatch a "signal" to its listners.
/// This is a base class, it should not be instantiated.
open class Signaler {
    var head: ListenerNode?
    var tail: ListenerNode?
    private var listenerDictionary: [Listener: ListenerNode] = [:]
    private var listenerNodePool: ListenerNodePool
    private var toAddHead: ListenerNode?
    private var toAddTail: ListenerNode?
    private var dispatching = false
    private var _numListeners = 0

    public init() {
        listenerDictionary = [:]
        listenerNodePool = ListenerNodePool()
    }

    public func startDispatch() {
        dispatching = true
    }

    public func endDispatch() {
        // Set dispatching to false to indicate that the dispatching process has ended
        dispatching = false

        // Check if there are any nodes queued to be added during the dispatching process
        if toAddHead != nil {
            // If the main listener list is empty, set head and tail to the queued nodes
            if head == nil {
                head = toAddHead
                tail = toAddTail
            } else {
                // If the main listener list is not empty, append the queued nodes to the end of the list
                tail?.next = toAddHead
                toAddHead?.previous = tail
                tail = toAddTail
            }
            // Clear the queued nodes
            toAddHead = nil
            toAddTail = nil
        }

        // Release any cached listener nodes in the listenerNodePool
        listenerNodePool.releaseCache()
    }

    public var numListeners: Int {
        return _numListeners
    }

    public func add(_ listener: Listener) {
        if let _ = listenerDictionary[listener] {
            return
        }
        if let node = listenerNodePool.get() {
            node.listener = listener
            listenerDictionary[listener] = node
            addNode(node)
        }
    }

    public func addOnce(_ listener: Listener) {
        if let _ = listenerDictionary[listener] {
            return
        }
        if let listenerNode = listenerNodePool.get() {
            listenerNode.listener = listener
            listenerNode.once = true
            listenerDictionary[listener] = listenerNode
            addNode(listenerNode)
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
        let listenerNode = listenerDictionary[listener]
        if let listenerNode {
            if head == listenerNode {
                head = head?.next
            }
            if tail == listenerNode {
                tail = tail?.previous
            }
            if (toAddHead == listenerNode) {
                toAddHead = toAddHead?.next
            }
            if toAddTail == listenerNode {
                toAddTail = toAddTail?.previous
            }
            if let previous = listenerNode.previous {
                previous.next = listenerNode.next
            }
            if let next = listenerNode.next {
                next.previous = listenerNode.previous
            }
            listenerDictionary.removeValue(forKey: listener)
            if dispatching {
                listenerNodePool.cache(listenerNode)
            } else {
                listenerNodePool.dispose(listenerNode)
            }
            _numListeners -= 1
        }
    }

    public func removeAll() {
        while let listenerNode = head {
            head = head?.next
            listenerDictionary.removeValue(forKey: listenerNode.listener!) //HACK
            listenerNodePool.dispose(listenerNode)
        }
        tail = nil
        toAddHead = nil
        toAddTail = nil
        _numListeners = 0
    }
}


