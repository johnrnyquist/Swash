//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

/**
The base class for a node.
A node is a set of different components that are required by a system.
A system can request a collection of nodes from the engine. Subsequently the Engine object creates
a node for every entity that has all of the components in the node class and adds these nodes
to the list obtained by the system. The engine keeps the list up to date as entities are added
to and removed from the engine and as the components on entities change.
*/
open class Node {
    public var components: [ComponentClassName: Component?] 

    public subscript<T: Component>(_ type: T.Type) -> T? {
        components[T.name] as? T
    }

    static public var name: NodeClassName {
        String(reflecting: Self.self)
    }

    required public init() {
        components = [:]
    }

    public init(components: [ComponentClassName: Component?]) {
        self.components = components
    }

    /// The entity whose components are included in the node. It should always be populated.
    ///  It is optional because it needs to be cleared when in the pool and if the node is re-used, entity is re-assigned.
    weak public var entity: Entity!
    /// Used by the NodeList class. The previous node in a node list.
    public var previous: Node?
    /// Used by the NodeList class. The next node in a node list.
    public var next: Node?
}

extension Node: Equatable {
	public static func ==(lhs: Node, rhs: Node) -> Bool {
		lhs === rhs
	}
}
