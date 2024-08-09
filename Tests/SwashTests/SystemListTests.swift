//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

@testable import Swash
import XCTest


final class SystemListTests: XCTestCase {
    func testAdd() {
        let list = SystemList()
        let system1 = System()
        let system2 = System()
        let system3 = System()
        let system4 = System()
        let system5 = System()

        system1.priority = 1
        system2.priority = 2
        system3.priority = 3
        system4.priority = 4
        system5.priority = 3

        list.add(system: system1)
        list.add(system: system2)
        list.add(system: system3)
        list.add(system: system4)
        list.add(system: system5)

        let expectedPriorities = [1, 2, 3, 3, 4]
        let actual = Array(list).map(\.priority)
        XCTAssertEqual(actual, expectedPriorities)
    }

    func testAddSystemToEmptyList() {
        let list = SystemList()
        let system = System()
        system.priority = 1
        list.add(system: system)

        XCTAssertEqual(list.head, system)
        XCTAssertEqual(list.tail, system)
        XCTAssertNil(system.next)
        XCTAssertNil(system.previous)
    }

    func testAddSystemWithHighestPriority() {
        let list = SystemList()
        let system1 = System()
        let system2 = System()
        system1.priority = 1
        system2.priority = 2
        list.add(system: system2)
        list.add(system: system1)

        let expectedPriorities = [1, 2]
        let actual = Array(list).map(\.priority)
        XCTAssertEqual(actual, expectedPriorities)
    }

    func testAddSystemWithLowestPriority() {
        let list = SystemList()
        let system1 = System()
        let system2 = System()
        system1.priority = 1
        system2.priority = 2
        list.add(system: system1)
        list.add(system: system2)

        let expectedPriorities = [1, 2]
        let actual = Array(list).map(\.priority)
        XCTAssertEqual(actual, expectedPriorities)
    }

    func testAddSystemWithMiddlePriority() {
        let list = SystemList()
        let system1 = System()
        let system2 = System()
        let system3 = System()
        system1.priority = 1
        system2.priority = 2
        system3.priority = 3
        list.add(system: system1)
        list.add(system: system3)
        list.add(system: system2)

        let expectedPriorities = [1, 2, 3]
        let actual = Array(list).map(\.priority)
        XCTAssertEqual(actual, expectedPriorities)
    }
}




