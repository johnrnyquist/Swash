/**
     * An internal class for a linked list of entities. Used inside the framework for
     * managing the entities.
     */
class EntityList {
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
        if head == entity {
            head = head?.next
        }
        if tail == entity {
            tail = tail?.previous
        }
        if let previous = entity.previous {
            previous.next = entity.next
        }
        if let next = entity.next {
            next.previous = entity.previous
        }
        // N.B. Don't set entity.next and entity.previous to nil because that will break the list iteration if node is the current node in the iteration.
    }

    func removeAll() {
        while let entity = head {
            head = entity.next
            entity.previous = nil
            entity.next = nil
        }
        tail = nil
    }
}

