/**
     * An internal class for a linked list of entities. Used inside the framework for
     * managing the entities.
     */
final class EntityList: Sequence {
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

    public func makeIterator() -> EntityListIterator { 
        EntityListIterator(current: head)
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

