//
//  EntityAndFamilyIntegrationTests.swift
//  SwashTests
//
//  Created by John Nyquist on 11/13/22.
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
        try! engine.addEntity(entity: entity)
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
        try! engine.addEntity(entity: entity)
        XCTAssertTrue((nodes.head as? MockPointMatixNode)?.entity === entity)
    }

    func test_CorrectEntityAddedToFamilyWhenAccessFamilySecond() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        try! engine.addEntity(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        XCTAssertTrue((nodes.head as? MockPointMatixNode)?.entity === entity)
    }

    func test_CorrectEntityAddedToFamilyWhenComponentsAdded() {
        let entity = Entity()
        try! engine.addEntity(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        XCTAssertTrue((nodes.head as? MockPointMatixNode)?.entity === entity)
    }

    func test_IncorrectEntityNotAddedToFamilyWhenAccessFamilyFirst() {
        let entity = Entity()
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        try! engine.addEntity(entity: entity)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func test_IncorrectEntityNotAddedToFamilyWhenAccessFamilySecond() {
        let entity = Entity()
        try! engine.addEntity(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func test_EntityRemovedFromFamilyWhenComponentRemovedAndFamilyAlreadyAccessed() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        try! engine.addEntity(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        entity.remove(componentClass: PointComponent.self)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func test_EntityRemovedFromFamilyWhenComponentRemovedAndFamilyNotAlreadyAccessed() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        try! engine.addEntity(entity: entity)
        entity.remove(componentClass: PointComponent.self)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func test_EntityRemovedFromFamilyWhenRemovedFromEngineAndFamilyAlreadyAccessed() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        try! engine.addEntity(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        engine.removeEntity(entity: entity)
        XCTAssertNil(nodes.head as? MockPointMatixNode)
    }

    func test_EntityRemovedFromFamilyWhenRemovedFromEngineAndFamilyNotAlreadyAccessed() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        try! engine.addEntity(entity: entity)
        engine.removeEntity(entity: entity)
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
            try! engine.addEntity(entity: entity)
        }
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        var node = nodes.head
        while node != nil {
            let entity = node!.entity!
            XCTAssertTrue(entities.contains(entity))
            node = node!.next
        }
    }

    func familyContainsAllMatchingEntities() {
        var entities = [Entity]()
        for _ in 1...5 {
            let entity = Entity()
            entity.add(component: PointComponent())
            entity.add(component: MatrixComponent())
            entities.append(entity)
            try! engine.addEntity(entity: entity)
        }
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        var node = nodes.head
        while node != nil {
            let entity = node!.entity!
            if let index = entities.firstIndex(of: entity) {
                entities.remove(at: index)
            }
            node = node!.next
        }
        XCTAssertTrue(entities.isEmpty)
    }

    func releaseFamilyEmptiesNodeList() {
        let entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        try! engine.addEntity(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        engine.releaseNodeList(nodeClassName: "\(MockPointMatixNode.self)")
        XCTAssertNil(nodes.head)
    }

    func releaseFamilySetsNextNodeToNull() {
        var entities = [Entity]()
        for _ in 1...5 {
            let entity = Entity()
            entity.add(component: PointComponent())
            entity.add(component: MatrixComponent())
            entities.append(entity)
            try! engine.addEntity(entity: entity)
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
        try! engine.addEntity(entity: entity)
        entity = Entity()
        entity.add(component: PointComponent())
        entity.add(component: MatrixComponent())
        try! engine.addEntity(entity: entity)
        let nodes = engine.getNodeList(nodeClassType: MockPointMatixNode.self)
        engine.removeAllEntities()
        XCTAssertNil(nodes.head)
    }
}



