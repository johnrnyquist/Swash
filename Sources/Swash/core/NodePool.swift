/**
 This internal class maintains a pool of deleted nodes for reuse by the framework. 
 This reduces the overhead from object creation and destruction. 
 
 Because nodes may be deleted from a NodeList while in use  
 (by deleting Nodes from a NodeList while iterating through the NodeList), 
 the pool also maintains a cache of nodes that are added to the pool but should not be reused yet. 
 They are then released into the pool by calling the releaseCache method.
*/
class NodePool {
    private var tail: Node?
    private var nodeClassName: NodeClassName
    private var cacheTail: Node?

/**
Creates a pool for the given node class.
*/
    init(nodeClassName: NodeClassName) {
        self.nodeClassName = nodeClassName
    }

/**
Fetches a node from the pool.
*/
    func get() -> Node {
        if let node = tail {
            tail = tail?.previous
            node.previous = nil
            return node
        } else {
            return (classFromString(className: nodeClassName) as! Node.Type).init()
        }
    }

/**
When you dispose of a node, it is added to the pool so it can be reused.
*/
    func dispose(node: Node) {
        node.entity = nil
        node.next = nil
        node.previous = tail
        tail = node
    }

/**
Adds a node to the cache because it cannot be disposed of yet as the engine is still updating.
*/
    func cache(node: Node) {
        node.previous = cacheTail
        cacheTail = node
    }

/**
Releases all nodes from the cache into the pool
*/
    func releaseCache() {
        while let currentNode = cacheTail {
            cacheTail = currentNode.previous
            dispose(node: currentNode)
        }
    }
}

