import struct Foundation.TimeInterval

/**
A useful class for systems which simply iterate over a set of nodes, performing the same action on each node. This class removes the need for a lot of boilerplate code in such systems. Extend this class and pass the node type and a node update method into the constructor. The node update method will be called once per node on the update cycle with the node instance and the frame time as parameters. e.g.
 <code>
     public class MySystem: ListIteratingSystem {
        public init() {
          super.init( MyNode, updateNode )
        }
        private function updateNode( node : MyNode, time : TimeInterval ) {
          // process the node here
        }
      }
</code>
*/
open class ListIteratingSystem: System {
    var nodeList: NodeList?
    var nodeClass: Node.Type
    public var nodeUpdateFunction: Node_TimeInterval_NoReturn? {
        didSet { if let nodeUpdateFunction { nodeUpdateFunctionListener = Listener(nodeUpdateFunction) } }
    }
    public var nodeAddedFunction: Node_NoReturn? {
        didSet { if let nodeAddedFunction { nodeAddedFunctionListener = Listener(nodeAddedFunction) } }
    }
    public var nodeRemovedFunction: NoArg_NoReturn? {
        didSet { if let nodeRemovedFunction { nodeRemovedFunctionListener = Listener(nodeRemovedFunction) } }
    }
    private var nodeUpdateFunctionListener: Listener!
    private var nodeAddedFunctionListener: Listener!
    private var nodeRemovedFunctionListener: Listener!

    public init(nodeClass: Node.Type) {
        self.nodeClass = nodeClass
    }

    open override func addToEngine(engine: Engine) {
        nodeList = engine.getNodeList(nodeClassType: nodeClass)
        if let nodeAddedFunction  {
            var node = nodeList?.head
            while let currentNode = node {
                nodeAddedFunction(currentNode)
                node = currentNode.next
            }
            nodeList?.nodeAdded.add(Listener(nodeAddedFunction))
        }
        if let nodeRemovedFunction {
            nodeList?.nodeRemoved.add(Listener(nodeRemovedFunction))
        }
    }

    open override func removeFromEngine(engine: Engine) {
        if let _ = nodeAddedFunction {
            nodeList?.nodeAdded.remove(nodeAddedFunctionListener)
        }
        if let _ = nodeRemovedFunction {
            nodeList?.nodeRemoved.remove(nodeRemovedFunctionListener)
        }
        nodeList = nil
    }

    open override func update(time: TimeInterval) {
        var node = nodeList?.head
        while let currentNode = node {
            nodeUpdateFunction?(currentNode, time)
            node = currentNode.next
        }
    }
}


