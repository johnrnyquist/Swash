//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//
/**
     * An internal class for a linked list of entities. Used inside the framework for
     * managing the entities.
     */
final class EntityList: Sequence, Collection {
    var head: Entity?
    var tail: Entity?

    func add(entity: Entity) {
        if head == nil {
            head = entity
            tail = entity
            entity.next = nil
            entity.previous = nil
        } else {
            tail?.next = entity
            entity.previous = tail
            entity.next = nil
            tail = entity
        }
    }

    func remove(entity: Entity) {
        if head === entity {
            head = entity.next
        }
        if tail === entity {
            tail = entity.previous
        }
        entity.previous?.next = entity.next
        entity.next?.previous = entity.previous
    }

    func removeAll() {
        while let entity = head {
            head = entity.next
            entity.previous = nil
            entity.next = nil
        }
        tail = nil
    }

    // Sequence conformance
    public func makeIterator() -> EntityListIterator {
        EntityListIterator(current: head)
    }

    // Collection conformance
    var startIndex: Int { 0 }
    var endIndex: Int { count }

    public var count: Int {
        var count = 0
        var entity = head
        while let current = entity {
            count += 1
            entity = current.next
        }
        return count
    }

    func index(after i: Int) -> Int { i + 1 }

    subscript(position: Int) -> Entity {
        var current = head
        for _ in 0..<position {
            current = current?.next
        }
        guard let entity = current else {
            fatalError("Index out of bounds")
        }
        return entity
    }
}

struct EntityListIterator: IteratorProtocol {
    var current: Entity?

    mutating func next() -> Entity? {
        let entity = current
        current = current?.next
        return entity
    }
}

