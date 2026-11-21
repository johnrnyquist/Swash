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

    func testRemovingStaleNamesakeLeavesReplacementAndOtherEntitiesInOrder() {
        let first = Entity()
        let old = Entity(named: "ship").add(component: ShipComponent())
        let last = Entity()
        let replacement = Entity(named: "ship").add(component: ShipComponent())
        let ships = engine.getNodeList(nodeClassType: ShipNode.self)
        for entity in [first, old, last, replacement] {
            engine.add(entity: entity)
        }
        var removals = 0
        ships.nodeRemoved.add(Listener { (_: Node) in removals += 1 })

        engine.remove(entity: old)
        engine.remove(entity: Entity(named: "ship"))

        XCTAssertEqual(removals, 0)
        XCTAssertTrue(engine.findEntity(named: "ship") === replacement)
        XCTAssertEqual(engine.entities, [first, last, replacement])
        XCTAssertEqual(ships.compactMap { $0.entity }, [replacement])
        replacement.remove(componentClass: ShipComponent.self)
        XCTAssertTrue(ships.empty)
        replacement.add(component: ShipComponent())
        XCTAssertTrue(ships.head?.entity === replacement)
    }

    func testRemovalCallbackCanInstallNamesakeOrReaddSameInstanceAcrossFamilies() {
        for readdSameInstance in [false, true] {
            let engine = Engine()
            let old = Entity(named: "ship").add(component: ShipComponent()).add(component: AlienComponent())
            let replacement = readdSameInstance ? old :
                Entity(named: "ship").add(component: ShipComponent()).add(component: AlienComponent())
            let ships = engine.getNodeList(nodeClassType: ShipNode.self)
            let aliens = engine.getNodeList(nodeClassType: AlienNode.self)
            let other = Entity()
            engine.add(entity: old)
            engine.add(entity: other)
            var removedEntities: [Entity] = []
            let replace = Listener { (node: Node) in
                guard let removed = node.entity else { return XCTFail("Missing removed entity") }
                removedEntities.append(removed)
                guard removedEntities.count == 1 else { return }
                XCTAssertTrue(engine.findEntity(named: "ship") === old)
                XCTAssertEqual(engine.entities, [old, other])
                engine.add(entity: replacement)
                XCTAssertTrue(engine.findEntity(named: "ship") === replacement)
            }
            ships.nodeRemoved.add(replace)
            aliens.nodeRemoved.add(replace)

            engine.remove(entity: old)

            XCTAssertEqual(removedEntities, [old, old])
            XCTAssertTrue(engine.findEntity(named: "ship") === replacement)
            XCTAssertEqual(engine.entities, [other, replacement])
            XCTAssertEqual(ships.compactMap { $0.entity }, [replacement])
            XCTAssertEqual(aliens.compactMap { $0.entity }, [replacement])
            ships.nodeRemoved.remove(replace)
            aliens.nodeRemoved.remove(replace)
            replacement.remove(componentClass: ShipComponent.self)
            XCTAssertTrue(ships.empty)
            replacement.add(component: ShipComponent())
            XCTAssertTrue(ships.head?.entity === replacement)
        }
    }

    func testQueryCreatedDuringRemovalOmitsDepartingEntity() {
        let old = Entity().add(component: ShipComponent()).add(component: AlienComponent())
        let remaining = Entity().add(component: AlienComponent())
        engine.add(entity: old)
        engine.add(entity: remaining)
        let ships = engine.getNodeList(nodeClassType: ShipNode.self)
        var aliens: NodeList?
        ships.nodeRemoved.add(Listener { [engine] (_: Node) in
            aliens = engine?.getNodeList(nodeClassType: AlienNode.self)
        })

        engine.remove(entity: old)

        XCTAssertEqual(aliens?.compactMap { $0.entity }, [remaining])
    }

    func testNestedAddDuringNamesakeReplacementWins() {
        let old = Entity(named: "ship").add(component: ShipComponent())
        let outer = Entity(named: "ship").add(component: ShipComponent())
        let inner = Entity(named: "ship").add(component: ShipComponent())
        let ships = engine.getNodeList(nodeClassType: ShipNode.self)
        engine.add(entity: old)
        ships.nodeRemoved.add(Listener { [engine] (node: Node) in
            if node.entity === old { engine?.add(entity: inner) }
        })

        engine.add(entity: outer)

        XCTAssertTrue(engine.findEntity(named: "ship") === inner)
        XCTAssertEqual(engine.entities, [inner])
        XCTAssertEqual(ships.compactMap { $0.entity }, [inner])
    }

    func testReplacementDuringComponentChangeStopsDeliveryForOldEntity() {
        for addingComponent in [false, true] {
            let engine = Engine()
            let old = Entity(named: "ship")
            let replacement = Entity(named: "ship")
            if !addingComponent {
                old.add(component: ShipComponent())
                replacement.add(component: ShipComponent())
            }
            engine.add(entity: old)
            let lists = [ShipNode.self, SecondShipNode.self].map { engine.getNodeList(nodeClassType: $0) }
            var didReplace = false
            let replace = Listener { (node: Node) in
                guard node.entity === old, !didReplace else { return }
                didReplace = true
                engine.add(entity: replacement)
            }
            for list in lists {
                (addingComponent ? list.nodeAdded : list.nodeRemoved).add(replace)
            }

            if addingComponent { old.add(component: ShipComponent()) }
            else { old.remove(componentClass: ShipComponent.self) }

            XCTAssertEqual(engine.entities, [replacement])
            for list in lists {
                XCTAssertEqual(list.compactMap { $0.entity }, addingComponent ? [] : [replacement])
            }
        }
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
        let point2 = nodes.head?.components[String(reflecting: PointComponent.self)] ?? nil
        XCTAssertTrue(point2 === point)
        let matrix2 = nodes.head?.components[String(reflecting: MatrixComponent.self)] ?? nil
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

private final class SecondShipNode: ShipNode {}
