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

/**
 * Uses the enter frame event to provide a frame tick with a fixed frame duration. This tick ignores the length of
 * the frame and dispatches the same time period for each tick. Use FixedTickProvider when you need consistent and 
 * predictable updates, such as in physics simulations or deterministic simulations.
 */
final public class FixedTickProvider: Signaler1, ITickProvider {
    private var frameTime: TimeInterval
    private var isPlaying: Bool = false
    /**
     * Applies a time adjustment factor to the tick, so you can slow down or speed up the entire engine.
     * The update tick time is multiplied by this value, so a value of 1 will run the engine at the normal rate.
     */
    public var timeAdjustment: Double = 1.0

    public init(frameTime: TimeInterval) {
        self.frameTime = frameTime
        super.init()
    }

    public func start() {
        isPlaying = true
    }

    public func stop() {
        isPlaying = false
    }

    public func dispatchTick() {
        guard isPlaying else { return }
        dispatch(frameTime * timeAdjustment)
    }

    public var playing: Bool {
        isPlaying
    }
}
