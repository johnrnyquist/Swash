//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

/// The priority of a system. Systems with higher priority are executed before systems with lower priority.
/// This is just a convenience, perhaps I should move it out of the framework.
public enum SystemPriorities: Int {
    case preUpdate = 1
    case update = 2
    case move = 3
    case resolveCollisions = 4
    case stateMachines = 5
    case animate = 6
    case render = 7
}
