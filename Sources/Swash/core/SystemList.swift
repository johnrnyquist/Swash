/**
Used internally, this is an ordered list of Systems for use by the engine update loop.
*/
class SystemList {
    var head: System?
    var tail: System?

    func add(system: System?) {
        if head == nil {
            head = system
            tail = system
            system?.next = nil
            system?.previous = nil
        } else {
            var node: System? = tail
            while node != nil {
                if (node!.priority <= system!.priority) {
                    break
                }
                node = node?.previous //end
            }
            if node == tail {
                tail?.next = system
                system?.previous = tail
                system?.next = nil
                tail = system
            } else if node == nil {
                system?.next = head
                system?.previous = nil
                head?.previous = system
                head = system
            } else {
                system?.next = node?.next
                system?.previous = node
                node?.next?.previous = system
                node?.next = system
            }
        }
    }

    func remove(system: System?) {
        if head == system {
            head = head?.next
        }
        if tail == system {
            tail = tail?.previous
        }
        if system?.previous != nil {
            system?.previous?.next = system?.next
        }
        if system?.next != nil {
            system?.next?.previous = system?.previous
        }
        // N.B. Don't set system.next and system.previous to nil because that will break the list iteration if node is the current node in the iteration.
    }

    func removeAll() {
        while head != nil {
            let system: System? = head
            head = head?.next
            system?.previous = nil
            system?.next = nil
        }
        tail = nil
    }

    func get(systemClassName: SystemClassName) -> System? {
        guard let head else { return nil }
        var system: System? = head
        while system != nil {
            if type(of: system!).name == systemClassName {
                return system
            }
            system = system?.next //end
        }
        return nil
    }
}
