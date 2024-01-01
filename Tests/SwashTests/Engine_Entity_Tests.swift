import XCTest
@testable import Swash

final class Engine_Entity_Tests: XCTestCase {
    var engine: Engine?
    var entity: Entity?
    var component: MockComponent?
    var system: MockSystem?

    override func setUpWithError() throws {
        Entity.nameCount = 0
        engine = Engine()
        system = MockSystem()
        entity = Entity()
        component = MockComponent()
    }

    override func tearDownWithError() throws {
        system = nil
        component = nil
        entity = nil
        engine = nil
        Entity.nameCount = 0
    }

    func test_familiesIncremented() throws {
		engine?.add(system: system!, priority: SystemPriorities.preUpdate.rawValue)
        try! engine?.add(entity: entity!)
        entity!.add(component: component!)
        XCTAssertEqual(engine!.families.count, 1)
    }

    func test_callingGetNodeListCreatesFamily() throws {
        XCTAssertEqual(engine?.families.count, 0)
        XCTAssertNotNil(engine?.getNodeList(nodeClassType: MockNode.self))
    }
}
