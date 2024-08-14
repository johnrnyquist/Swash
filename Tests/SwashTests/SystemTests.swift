//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
@testable import Swash

class AnotherMockSystem: System {
    private var tests: SystemTests

    init(_ tests: SystemTests) {
        self.tests = tests
        super.init()
    }

    public override func addToEngine(engine: Engine) {
        tests.addRemoveCallback?(self, "added", engine)
    }

    public override func removeFromEngine(engine: Engine) {
        tests.addRemoveCallback?(self, "removed", engine)
    }

    public override func update(time: TimeInterval) {
        tests.updateCallback?(self, "update", time)
    }
}

typealias addRemove = (System, String, Engine) -> ()
typealias update = (System, String, TimeInterval) -> ()

final class SystemTests: XCTestCase {
    var engine: Engine!
    var system1: AnotherMockSystem!
    var system2: AnotherMockSystem!
//    var async: IAsync
    var addRemoveCallback: addRemove?
    var updateCallback: update?

    override func setUpWithError() throws {
        engine = Engine()
    }

    override func tearDownWithError() throws {
        system2 = nil
        system1 = nil
        engine = nil
    }

    func test_systemsGetterReturnsAllTheSystems() {
        let system1 = System()
        engine.add(system: system1, priority: 1)
        let system2 = System()
        engine.add(system: system2, priority: 1)
        XCTAssertEqual(engine.systems.count, 2)
        XCTAssertTrue(engine.systems == [system1, system2])
    }

    func test_addSystemCallsAddToEngine() {
        _ = 0
        let system: System = AnotherMockSystem(self)
        addRemoveCallback = addedCallbackMethod
        engine.add(system: system, priority: 0)
    }

    func addedCallbackMethod(_ system: System, _ action: String, _ systemEngine: Engine) {
        XCTAssertEqual(action, "added")
        XCTAssertTrue(systemEngine === engine)
    }

    func test_removeSystemCallsRemovedFromEngine() {
        let system = AnotherMockSystem(self)
        engine.add(system: system, priority: 0)
        addRemoveCallback = removedCallbackMethod
        engine.remove(system: system)
    }

    func removedCallbackMethod(system: System, action: String, systemEngine: Engine) {
        XCTAssertEqual(action, "removed")
        XCTAssertTrue(systemEngine === engine)
    }

    func test_engineCallsUpdateOnSystems() {
        let system: System = AnotherMockSystem(self)
        engine.add(system: system, priority: 0)
        updateCallback = updateCallbackMethod
        engine.update(time: 0.1)
    }

    func updateCallbackMethod(system: System, action: String, time: TimeInterval) {
        XCTAssertEqual(action, "update")
        XCTAssertEqual(time, 0.1)
    }

    func test_defaultPriorityIsZero() {
        let system: System = AnotherMockSystem(self)
        XCTAssertEqual(system.priority, 0)
    }

    func test_canSetPriorityWhenAddingSystem() {
        let system: System = AnotherMockSystem(self)
        engine.add(system: system, priority: 10)
        XCTAssertEqual(system.priority, 10)
    }

    func test_systemsUpdatedInPriorityOrderIfSameAsAddOrder() {
        system1 = AnotherMockSystem(self)
        engine.add(system: system1, priority: 10)
        system2 = AnotherMockSystem(self)
        engine.add(system: system2, priority: 20)
        updateCallback = updateCallbackMethod1
        engine.update(time: 0.1)
    }

    func updateCallbackMethod1(system: System, action: String, time: TimeInterval) {
        XCTAssertTrue(system === system1)
        updateCallback = updateCallbackMethod2
    }

    func updateCallbackMethod2(system: System, action: String, time: TimeInterval) {
        XCTAssertTrue(system === system2)
    }

    func test_systemsUpdatedInPriorityOrderIfReverseOfAddOrder() {
        system2 = AnotherMockSystem(self)
        engine.add(system: system2, priority: 20)
        system1 = AnotherMockSystem(self)
        engine.add(system: system1, priority: 10)
        updateCallback = updateCallbackMethod1
        engine.update(time: 0.1)
    }

    func test_systemsUpdatedInPriorityOrderIfPrioritiesAreNegative() {
        system2 = AnotherMockSystem(self)
        engine.add(system: system2, priority: 10)
        system1 = AnotherMockSystem(self)
        engine.add(system: system1, priority: -20)
        updateCallback = updateCallbackMethod1
        engine.update(time: 0.1)
    }

    func test_updatingIsTrueDuringUpdate() {
        let system: System = AnotherMockSystem(self)
        engine.add(system: system, priority: 0)
        updateCallback = assertsUpdatingIsTrue
        engine.update(time: 0.1)
    }

    func assertsUpdatingIsTrue(system: System, action: String, time: TimeInterval) {
        XCTAssertTrue(engine.updating)
    }

    func test_updatingIsFalseBeforeUpdate() {
        XCTAssertFalse(engine.updating)
    }

    func test_updatingIsFalseAfterUpdate() {
        engine.update(time: 0.1)
        XCTAssertFalse(engine.updating)
    }

    func test_completeSignalIsDispatchedAfterUpdate() {
        let system: System = AnotherMockSystem(self)
        engine.add(system: system, priority: 0)
        updateCallback = listensForUpdateComplete
        engine.update(time: 0.1)
    }

    func listensForUpdateComplete(system: System, action: String, time: TimeInterval) {
        engine.updateComplete.add(Listener { XCTAssertTrue(true) })
    }

    func test_getSystemReturnsTheSystem() {
        let system1: System = AnotherMockSystem(self)
        engine.add(system: system1, priority: 0)
        engine.add(system: System(), priority: 0)
        XCTAssertTrue(engine.findSystem(named: String(reflecting: AnotherMockSystem.self)) === system1)
    }

    func test_getSystemReturnsNilIfNoSuchSystem() {
        engine.add(system: System(), priority: 0)
        XCTAssertNil(engine.findSystem(named: "\(AnotherMockSystem.self)"))
    }

    func test_removeAllSystemsDoesWhatItSays() {
        engine.add(system: System(), priority: 0)
        engine.add(system: AnotherMockSystem(self), priority: 0)
        engine.removeAllSystems()
        XCTAssertNil(engine.findSystem(named: "\(AnotherMockSystem.self)"))
        XCTAssertNil(engine.findSystem(named: "\(System.self)"))
    }

    func test_removeAllSystemsSetsNextToNil() {
        let system1 = System()
        engine.add(system: system1, priority: 1)
        let system2 = System()
        engine.add(system: system2, priority: 2)
        XCTAssertTrue(system1.next === system2)
        engine.removeAllSystems()
        XCTAssertNil(system1.next)
    }

    func test_removeSystemAndAddItAgainDontCauseInvalidLinkedList() {
        let systemB: System = System()
        let systemC: System = System()
        engine.add(system: systemB, priority: 0)
        engine.add(system: systemC, priority: 0)
        engine.remove(system: systemB)
        engine.add(system: systemB, priority: 0)
        XCTAssertNil(systemC.previous)
        XCTAssertNil(systemB.next)
    }
}
