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

final class EntityAndFamilyIntegrationTests: XCTestCase {
    var engine: Engine!

    override func setUpWithError() throws {
        engine = Engine()
    }

    override func tearDownWithError() throws {
        engine = nil
    }

    func test_FamilyIsInitiallyEmpty() {
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        XCTAssertNil(nodes.head)
    }

    func test_NodeContainsEntityProperties() {
        let entity = Entity()
        let point = PointComponent()
        let matrix = MatrixComponent()
        entity.add(component: point)
        entity.add(component: matrix)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        engine.add(entity: entity)
        let point2 = nodes.head?.components["\(PointComponent.self)"] ?? nil
        XCTAssertTrue(point2 === point)
        let matrix2 = nodes.head?.components["\(MatrixComponent.self)"] ?? nil
        XCTAssertTrue(matrix2 === matrix)
    }

    func test_CorrectEntityAddedToFamilyWhenAccessFamilyFirst() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        engine.add(entity: entity)
        XCTAssertTrue((nodes.head as? MockPointMatixNode)?.entity === entity)
    }

    func test_CorrectEntityAddedToFamilyWhenAccessFamilySecond() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        engine.add(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        XCTAssertTrue((nodes.head as? MockPointMatixNode)?.entity === entity)
    }

    func test_CorrectEntityAddedToFamilyWhenComponentsAdded() {
        let entity = Entity()
        engine.add(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        XCTAssertTrue((nodes.head as? MockPointMatixNode)?.entity === entity)
    }

    func test_IncorrectEntityNotAddedToFamilyWhenAccessFamilyFirst() {
        let entity = Entity()
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        engine.add(entity: entity)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func test_IncorrectEntityNotAddedToFamilyWhenAccessFamilySecond() {
        let entity = Entity()
        engine.add(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func test_EntityRemovedFromFamilyWhenComponentRemovedAndFamilyAlreadyAccessed() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        engine.add(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        entity.remove(componentClass: PointComponent.self)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func test_EntityRemovedFromFamilyWhenComponentRemovedAndFamilyNotAlreadyAccessed() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        engine.add(entity: entity)
        entity.remove(componentClass: PointComponent.self)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func test_EntityRemovedFromFamilyWhenRemovedFromEngineAndFamilyAlreadyAccessed() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        engine.add(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        engine.remove(entity: entity)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func test_EntityRemovedFromFamilyWhenRemovedFromEngineAndFamilyNotAlreadyAccessed() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        engine.add(entity: entity)
        engine.remove(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func familyContainsOnlyMatchingEntities() {
        var entities = [Entity]()
        for _ in 1...5 {
            let entity = Entity()
            entity.add(component: PointComponent())
            entity.add(component: MatrixComponent())
            entities.append(entity)
            engine.add(entity: entity)
        }
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        var node = nodes.head
        while let currentNode = node {
            let entity = currentNode.entity!
            XCTAssertTrue(entities.contains(entity))
            node = currentNode.next
        }
    }

    func familyContainsAllMatchingEntities() {
        var entities = [Entity]()
        for _ in 1...5 {
            let entity = Entity()
            entity.add(component: PointComponent())
            entity.add(component: MatrixComponent())
            entities.append(entity)
            engine.add(entity: entity)
        }
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        var node = nodes.head
        while let currentNode = node {
            let entity = currentNode.entity!
            if let index = entities.firstIndex(of: entity) {
                entities.remove(at: index)
            }
            node = currentNode.next
        }
        XCTAssertTrue(entities.isEmpty)
    }

    func releaseFamilyEmptiesNodeList() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        engine.add(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        engine.releaseNodeList(nodeClassName: "\(MockPointMatixNode.self)")
        XCTAssertNil(nodes.head)
    }

    func releaseFamilySetsNextNodeToNil() {
        var entities = [Entity]()
        for _ in 1...5 {
            let entity = Entity()
            entity.add(component: PointComponent())
            entity.add(component: MatrixComponent())
            entities.append(entity)
            engine.add(entity: entity)
        }
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        let node = nodes.head?.next
        engine.releaseNodeList(nodeClassName: "\(MockPointMatixNode.self)")
        XCTAssertNil(node?.next)
    }

    func removeAllEntitiesDoesWhatItSays() {
        var entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        engine.add(entity: entity)
        entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        engine.add(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        engine.removeAllEntities()
        XCTAssertNil(nodes.head)
    }
}



