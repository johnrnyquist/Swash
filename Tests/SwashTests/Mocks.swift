import Foundation
@testable import Swash

class MockSystem: System {
    var mockNodes: NodeList!

    public override func addToEngine(engine: Engine) {
        mockNodes = engine.getNodeList(nodeClassType: MockNode.self)
    }
}

class MockNode: Node {
    var mockComponent: MockComponent?
    var anotherMockComponent: AnotherMockComponent?

    required init() {
        super.init()
        components = [MockComponent.name: nil_component,
                      AnotherMockComponent.name: nil_component]
    }
}

class AnotherMockComponent: Component {
}

class AMockNode: Node {
    required init() {
        super.init()
        components = [PointComponent.name: nil_component]
    }
}

class PointComponent: Component {}

class MatrixComponent: Component {
}

class MockPointMatixNode: Node {
    public var point: PointComponent!
    public var matrix: MatrixComponent!

    required init() {
        super.init()
        components = [PointComponent.name: nil_component,
                      MatrixComponent.name: nil_component
        ]
    }
}

class PosComponent: Component {
    var pos: Int

    init(pos: Int) {
        self.pos = pos
        super.init()
    }
}

class MockPosNode: Node, CustomStringConvertible {
    var pos: Int = 0

	var description: String {
		return "pos \(pos)"
	}

    convenience init(_ value: Int = 0) {
        self.init()
        pos = value
    }

    required init() {
        super.init()
        components = [PosComponent.name: nil_component]
    }
}

class MockComponent: Component {
    public var value: Int?

    override init() { super.init() }
}

class MockComponent2: Component {
    public var value: String?

    override init() { super.init() }
}

class MockComponentExtended: MockComponent {
    public var other: Int?

    override init() { super.init() }
}
