let nil_component: Component? = nil

/// All components must extend this class
open class Component {
	weak var entity: Entity?
	static public var name: String {
		"\(Self.self)"
	}
}

extension Component: Equatable {
	public static func == (lhs: Component, rhs: Component) -> Bool {
		lhs.entity == rhs.entity
	}
}

extension Component: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(entity)
	}
}
