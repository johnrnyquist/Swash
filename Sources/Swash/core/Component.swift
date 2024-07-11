@available(*, deprecated, message: "Use `nil` directly instead.")
public let nil_component: Component? = nil

/// All components must extend this class
open class Component {
	static public var name: ComponentClassName {
		"\(Self.self)"
	}
    
    public init() {}
}

extension Component: Equatable {
	public static func == (lhs: Component, rhs: Component) -> Bool {
		lhs === rhs
	}
}
