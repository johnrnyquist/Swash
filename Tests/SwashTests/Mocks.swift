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
        let keyPath: ReferenceWritableKeyPath<MockNode, MockComponent?> = \MockNode.mockComponent
        let paths: [ReferenceWritableKeyPath<MockNode, MockComponent?>: Component?] = [keyPath: nil]
        components = ["\(MockComponent.self)": nil, "\(AnotherMockComponent.self)": nil]
    }
}

class AnotherMockComponent: Component {
}

class AMockNode: Node {
    required init() {
        super.init()
        components = ["\(PointComponent.self)": nil]
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
        components = ["\(PointComponent.self)": nil,
                      "\(MatrixComponent.self)": nil
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

class MockPosNode: Node {
    var pos: Int = 0

    convenience init(_ value: Int = 0) {
        self.init()
        pos = value
    }

    required init() {
        super.init()
        components = ["\(PosComponent.self)": nil, ]
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
