import XCTest
@testable import Swash

final class Engine_Entity_Tests: XCTestCase {
    var engine: Engine!
    var system: MockSystem!

    override func setUpWithError() throws {
        Entity.nameCount = 0
        engine = Engine()
        system = MockSystem()
    }

    override func tearDownWithError() throws {
        system = nil
        engine = nil
        Entity.nameCount = 0
    }

    // Integration test
    // adding a system to the engine results in a getNodes of the type specified by the system.
    // this results in a new family being made.
    func test_familiesIncremented() throws {
        XCTAssertEqual(engine.families.count, 0)
        engine.add(system: system, priority: SystemPriorities.preUpdate.rawValue)
        XCTAssertEqual(engine.families.count, 1)
        engine.remove(system: system)
        // removing the system did not affect the families
        XCTAssertEqual(engine.families.count, 1)
    }

    func test_callingGetNodeListCreatesFamily() throws {
        XCTAssertEqual(engine.families.count, 0)
        XCTAssertNotNil(engine.getNodeList(nodeClassType: MockNode.self))
    }
}
