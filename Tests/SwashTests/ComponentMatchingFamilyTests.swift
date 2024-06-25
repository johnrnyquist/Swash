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
    private var shipNodeFamily: ComponentMatchingFamily!
    private var alienNodeFamily: ComponentMatchingFamily!

    override func setUpWithError() throws {
        engine = Engine()
        // Families aren't normally created like this, this is for testing.
        shipNodeFamily = ComponentMatchingFamily(nodeClassType: ShipNode.self, engine: engine)
        alienNodeFamily = ComponentMatchingFamily(nodeClassType: AlienNode.self, engine: engine)
        // Families aren't normally added like this, this is for testing.
        engine.families[ShipNode.name] = shipNodeFamily
        engine.families[AlienNode.name] = alienNodeFamily
    }

    override func tearDownWithError() throws {
        shipNodeFamily = nil
        alienNodeFamily = nil
        engine = nil
    }

    func test_NodeListIsInitiallyEmpty() {
        let nodes: NodeList = shipNodeFamily.nodeList
        XCTAssertNil(nodes.head)
    }

    func test_MatchingEntityIsAddedWhenAccessNodeListFirst() {
        let nodes: NodeList = shipNodeFamily.nodeList
        let entity: Entity = Entity()
                .add(component: ShipComponent())
        shipNodeFamily.new(entity: entity)
        XCTAssertTrue(nodes.head?.entity === entity)
    }

    func test_MatchingEntityIsAddedWhenAccessNodeListSecond() {
        let entity: Entity = Entity()
                .add(component: ShipComponent())
        shipNodeFamily.new(entity: entity)
        let nodes: NodeList = shipNodeFamily.nodeList
        XCTAssertTrue(nodes.head?.entity === entity)
    }

    func test_NodeContainsEntityProperties() {
        let entity: Entity = Entity()
        let shipComponent = ShipComponent()
        entity.add(component: shipComponent)
        shipNodeFamily.new(entity: entity)
        let nodes = shipNodeFamily.nodeList
        let component = nodes.head?.components["\(ShipComponent.self)"] ?? nil
        XCTAssertTrue(component === shipComponent)
    }

    func test_MatchingEntityIsAddedWhenComponentAdded() {
        let nodes: NodeList = shipNodeFamily.nodeList
        let entity: Entity = Entity()
                .add(component: ShipComponent())
        shipNodeFamily.componentAddedTo(entity: entity)
        XCTAssertTrue(nodes.head?.entity === entity)
    }

    func test_NonMatchingEntity_IsNotAdded() {
        let entity: Entity = Entity()
        shipNodeFamily.new(entity: entity)
        let nodes: NodeList = shipNodeFamily.nodeList
        XCTAssertNil(nodes.head)
    }

    func test_NonMatchingEntity_IsNotAdded_WhenComponentAdded() {
        let entity: Entity = Entity()
                .add(component: MatrixComponent())
        shipNodeFamily.componentAddedTo(entity: entity)
        let nodes: NodeList = shipNodeFamily.nodeList
        XCTAssertNil(nodes.head)
    }

    func test_EntityIsRemoved_WhenAccessNodeListFirst() {
        let entity: Entity = Entity()
                .add(component: ShipComponent())
        shipNodeFamily.new(entity: entity)
        let nodes: NodeList = shipNodeFamily.nodeList
        shipNodeFamily.remove(entity: entity)
        XCTAssertNil(nodes.head)
    }

    func test_EntityIsRemoved_WhenAccessNodeListSecond() {
        let entity: Entity = Entity()
                .add(component: ShipComponent())
        shipNodeFamily.new(entity: entity)
        shipNodeFamily.remove(entity: entity)
        let nodes: NodeList = shipNodeFamily.nodeList
        XCTAssertNil(nodes.head)
    }

    func test_EntityIsRemoved_WhenComponentRemoved() {
        let entity: Entity = Entity()
                .add(component: ShipComponent())
        shipNodeFamily.new(entity: entity)
        entity.remove(componentClass: ShipComponent.self)
        shipNodeFamily.componentRemovedFrom(entity: entity, componentClassName: "\(ShipComponent.self)")
        let nodes: NodeList = shipNodeFamily.nodeList
        XCTAssertNil(nodes.head)
    }

    func test_NodeListContainsOnlyMatchingEntities() {
        var entities = [Entity]()
        var i = 0
        while i < 5 {
            let entity: Entity = Entity()
                    .add(component: ShipComponent())
            entities.append(entity)
            shipNodeFamily.new(entity: entity)
            shipNodeFamily.new(entity: Entity()) // Not added because it is not matching
            i += 1
        }
        let nodes: NodeList = shipNodeFamily.nodeList
        var node: Node? = nodes.head
        var j = 0
        while let currentNode = node {
            XCTAssertNotNil(currentNode[ShipComponent.self])
            node = currentNode.next
            j += 1
        }
        XCTAssertEqual(i, j)
    }
}

 
