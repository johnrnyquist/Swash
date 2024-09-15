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

/**
A useful class for systems which simply iterate over a set of nodes, performing the same action on each node. 
 This class removes the need for a lot of boilerplate code in such systems. 
 Extend this class and pass the node type and a node update method into the constructor. 
 The node update method will be called once per node on the update cycle with the node 
 instance and the frame time as parameters. e.g.
 <code>
    final class ThrustSystem: ListIteratingSystem {
        init() {
            super.init(nodeClass: ThrustNode.self)
            nodeUpdateFunction = updateNode
        }
        private func updateNode(node: Node, time: TimeInterval) {
          // process the node here
        }
      }
</code>
*/
open class ListIteratingSystem: System {
    var nodeList: NodeList?
    var nodeClass: Node.Type
    /// These are set from this class’ subclass. 
    public var nodeUpdateFunction: Node_TimeInterval_NoReturn?
    public var nodeAddedFunction: Node_NoReturn?
    public var nodeRemovedFunction: Node_NoReturn?

    public init(nodeClass: Node.Type) {
        self.nodeClass = nodeClass
    }

    open override func addToEngine(engine: Engine) {
        nodeList = engine.getNodeList(nodeClassType: nodeClass)
        if let nodeAddedFunction {
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


