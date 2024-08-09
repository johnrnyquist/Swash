//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import struct Foundation.TimeInterval

open class System {
    static public var name: SystemClassName {
        "\(Self.self)"
    }

    public init() {}
    
    deinit {
        previous = nil
        next = nil
    }

    /**
    Used internally to manage the list of systems within the engine. The previous system in the list.
    */
    var previous: System?
    /**
    Used internally to manage the list of systems within the engine. The next system in the list.
    */
    var next: System?
    /**
    Used internally to hold the priority of this system within the system list. This is 
    used to order the systems so they are updated in the correct order.
    */
    var priority: Int = 0

    /**
    Called just after the system is added to the engine, before any calls to the update method.
    Override this method to add your own functionality.
    - Parameter engine: The engine the system was added to.
    */
    open func addToEngine(engine: Engine) {
    }

    /**
    Called just after the system is removed from the engine, after all calls to the update method.
    Override this method to add your own functionality.
    - Parameter engine: The engine the system was removed from.
    */
    open func removeFromEngine(engine: Engine) {
    }

    /**
    After the system is added to the engine, this method is called every frame until the system
    is removed from the engine. Override this method to add your own functionality.
    If you need to perform an action outside of the update loop (e.g. you need to change the
    systems in the engine and you don't want to do it while they're updating) add a listener to
    the engine's updateComplete signal to be notified when the update loop completes.
    @param time The duration, in seconds, of the frame.
    */
    open func update(time: TimeInterval) {
    }
}

extension System: Equatable {
    public static func ==(lhs: System, rhs: System) -> Bool {
        lhs === rhs
    }
}
