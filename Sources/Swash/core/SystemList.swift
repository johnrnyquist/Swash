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
Used internally, this is an ordered list of Systems for use by the engine update loop.
*/
final class SystemList: Sequence, Collection {
    var head: System?
    var tail: System?

    func add(system: System) {
        guard contains(system) == false 
        else { 
            print("\(System.name) not added to engine as it already exists in the system list.")
            return
        }
        
        if head == nil {
            head = system
            tail = system
            system.next = nil
            system.previous = nil
        } else {
            var node: System? = tail
            while let currentNode = node {
                if currentNode.priority <= system.priority {
                    break
                }
                node = currentNode.previous
            }
            if node === tail {
                tail?.next = system
                system.previous = tail
                system.next = nil
                tail = system
            } else if node == nil {
                system.next = head
                system.previous = nil
                head?.previous = system
                head = system
            } else {
                system.next = node?.next
                system.previous = node
                node?.next?.previous = system
                node?.next = system
            }
        }
    }

    func remove(system: System) {
        if head === system {
            head = head?.next
        }
        if tail === system {
            tail = tail?.previous
        }
        if let previous = system.previous {
            previous.next = system.next
        }
        if let next = system.next {
            next.previous = system.previous
        }
        // N.B. Don't set system.next and system.previous to nil because that will break the list iteration if node is the current node in the iteration.
    }

    func removeAll() {
        while let currentSystem = head {
            head = head?.next
            currentSystem.previous = nil
            currentSystem.next = nil
        }
        tail = nil
    }

    func get(systemClassName: SystemClassName) -> System? {
        var system: System? = head
        while let currentSystem = system {
            if type(of: currentSystem).name == systemClassName {
                return system
            }
            system = currentSystem.next
        }
        return nil
    }

    // Sequence conformance
    public func makeIterator() -> SystemListIterator {
        SystemListIterator(current: head)
    }

    // Collection conformance
    var startIndex: Int { 0 }
    var endIndex: Int { count }
    
    var count: Int {
        var count = 0
        var system = head
        while let current = system {
            count += 1
            system = current.next
        }
        return count
    }

    func index(after i: Int) -> Int { i + 1 }

    subscript(position: Int) -> System {
        var current = head
        for _ in 0..<position {
            current = current?.next
        }
        guard let system = current else {
            fatalError("Index out of bounds")
        }
        return system
    }
}

struct SystemListIterator: IteratorProtocol {
    var current: System?

    mutating func next() -> System? {
        let system = current
        current = current?.next
        return system
    }
}
