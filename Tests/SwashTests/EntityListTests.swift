import XCTest
@testable import Swash

final class EntityListTests: XCTestCase {
    var entityList: EntityList!
    var entity: Entity!

    override func setUpWithError() throws {
        entityList = EntityList()
        entity = Entity()
    }

    override func tearDownWithError() throws {
        entityList = nil
    }

    func test_add() throws {
        entityList.add(entity: entity)
        XCTAssertEqual(entityList.head, entity)
        XCTAssertEqual(entityList.tail, entity)
    }

    func test_remove() throws {
        entityList.add(entity: entity)
        entityList.remove(entity: entity)
        XCTAssertNil(entityList.head)
        XCTAssertNil(entityList.tail)
    }

    func test_removeAll() throws {
        entityList.add(entity: entity)
        entityList.removeAll()
        XCTAssertNil(entityList.head)
        XCTAssertNil(entityList.tail)
    }
}
