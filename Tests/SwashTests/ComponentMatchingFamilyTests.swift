//
//  ComponentMatchingFamilyTests.swift
//  SwashTests
//
//  Created by John Nyquist on 11/13/22.
//

import XCTest
@testable import Swash

final class ComponentMatchingFamilyTests: XCTestCase {
    private var engine: Engine!
    private var family: ComponentMatchingFamily!

    override func setUpWithError() throws {
        engine = Engine()
        family = ComponentMatchingFamily(nodeClassType: AMockNode.self, engine: engine)
        engine.families[AMockNode.name] = family
    }

    override func tearDownWithError() throws {
        family = nil
        engine = nil
    }

    func test_NodeListIsInitiallyEmpty() {
        let nodes: NodeList = family.nodeList
        XCTAssertNil(nodes.head)
    }

    func test_MatchingEntityIsAddedWhenAccessNodeListFirst() {
        let nodes: NodeList = family.nodeList
        let entity: Entity = Entity()
        entity.add(component: PointComponent())
        family.newEntity(entity: entity)
        XCTAssertTrue(nodes.head?.entity === entity)
    }

    func test_MatchingEntityIsAddedWhenAccessNodeListSecond() {
        let entity: Entity = Entity()
        entity.add(component: PointComponent())
        family.newEntity(entity: entity)
        let nodes: NodeList = family.nodeList
        XCTAssertTrue(nodes.head?.entity === entity)
    }

    func test_NodeContainsEntityProperties() {
        let entity: Entity = Entity()
        let point = PointComponent()
        entity.add(component: point)
        family.newEntity(entity: entity)
        let nodes = family.nodeList
        let component = nodes.head?.components["\(PointComponent.self)"] ?? nil
        XCTAssertTrue(component === point)
    }

    func test_MatchingEntityIsAddedWhenComponentAdded() {
        let nodes: NodeList = family.nodeList
        let entity: Entity = Entity()
        entity.add(component: PointComponent())
        family.componentAddedToEntity(entity: entity)
        XCTAssertTrue(nodes.head?.entity === entity)
    }

    func test_NonMatchingEntityIsNotAdded() {
        let entity: Entity = Entity()
        family.newEntity(entity: entity)
        let nodes: NodeList = family.nodeList
        XCTAssertNil(nodes.head)
    }

    func test_NonMatchingEntityIsNotAddedWhenComponentAdded() {
        let entity: Entity = Entity()
        entity.add(component: MatrixComponent())
        family.componentAddedToEntity(entity: entity)
        let nodes: NodeList = family.nodeList
        XCTAssertNil(nodes.head)
    }

    func test_EntityIsRemovedWhenAccessNodeListFirst() {
        let entity: Entity = Entity()
        entity.add(component: PointComponent())
        family.newEntity(entity: entity)
        let nodes: NodeList = family.nodeList
        family.removeEntity(entity: entity)
        XCTAssertNil(nodes.head)
    }

    func test_EntityIsRemovedWhenAccessNodeListSecond() {
        let entity: Entity = Entity()
        entity.add(component: PointComponent())
        family.newEntity(entity: entity)
        family.removeEntity(entity: entity)
        let nodes: NodeList = family.nodeList
        XCTAssertNil(nodes.head)
    }

    func test_EntityIsRemovedWhenComponentRemoved() {
        let entity: Entity = Entity()
        entity.add(component: PointComponent())
        family.newEntity(entity: entity)
        entity.remove(componentClass: PointComponent.self)
        family.componentRemovedFromEntity(entity: entity, componentClassName: "\(PointComponent.self)")
        let nodes: NodeList = family.nodeList
        XCTAssertNil(nodes.head)
    }

    func test_NodeListContainsOnlyMatchingEntities() {
        var entities = [Entity]()
        var i = 0
        while i < 5 {
            let entity: Entity = Entity()
            entity.add(component: PointComponent())
            entities.append(entity)
            family.newEntity(entity: entity)
            family.newEntity(entity: Entity())

            i += 1
        }
        let nodes: NodeList = family.nodeList
        var node: Node? = nodes.head
        while node != nil {
            XCTAssertTrue(entities.contains(node!.entity!))
            node = node!.next
        }
    }

//    func nodeListContainsAllMatchingEntities() {
//        var entities = [Entity]()
//        var i = 0
//        while i < 5 {
//            var entity: Entity = Entity()
//            entity.add(PointComponent())
//            entities.push(entity)
//            family.newEntity(entity)
//            family.newEntity(Entity())
//
//            i += 1
//        }
//        var nodes: NodeList = family.nodeList
//        var node: Node? = nodes.head
//        while node != nil {
//            var index = entities.indexOf(node.entity)
//            entities.splice(index, 1)
//            node = node?.next
//        }
//        XCTAssertTrue(entities, emptyArray())
//    }

    func cleanUpEmptiesNodeList() {
        let entity: Entity = Entity()
        entity.add(component: PointComponent())
        family.newEntity(entity: entity)
        let nodes: NodeList = family.nodeList
        family.cleanUp()
        XCTAssertNil(nodes.head)
    }

    func cleanUpSetsNextNodeToNull() {
        var entities = [Entity]()
        var i = 0
        while i < 5 {
            let entity: Entity = Entity()
            entity.add(component: PointComponent())
            entities.append(entity)
            family.newEntity(entity: entity)
            i += 1
        }
        let nodes: NodeList = family.nodeList
        let node = nodes.head?.next
        family.cleanUp()
        XCTAssertNil(node?.next)
    }
}

 
