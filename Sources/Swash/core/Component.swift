//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

@available(*, deprecated, message: "Use `nil` directly instead.")
public let nil_component: Component? = nil

/// All components must extend this class
open class Component {
	static public var name: ComponentClassName {
		"\(Self.self)"
	}
    public weak var entity: Entity?
    public init() {}
}

extension Component: Equatable {
	public static func == (lhs: Component, rhs: Component) -> Bool {
		lhs === rhs
	}
}
