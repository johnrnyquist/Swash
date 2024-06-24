import struct Foundation.Date
import struct Foundation.TimeInterval

final public class FrameTickProvider: Signaler1, ITickProvider {
    private var previousTime: TimeInterval = 0
    private var maximumFrameTime: TimeInterval
    private var isPlaying: Bool = false
    /**
	 * Applies a time adjustment factor to the tick, so you can slow down or speed up the entire engine.
	 * The update tick time is multiplied by this value, so a value of 1 will run the engine at the normal rate.
	*/
    public var timeAdjustment: Double = 1.0

    public init(maximumFrameTime: TimeInterval = TimeInterval.greatestFiniteMagnitude) {
        self.maximumFrameTime = maximumFrameTime
        super.init()
    }

    public func start() {
        previousTime = getTimer()
        isPlaying = true
    }

    public func stop() {
        isPlaying = false
    }

    public func dispatchTick() {
        guard isPlaying else { return }
        let temp: TimeInterval = previousTime
        previousTime = getTimer()
        var frameTime: TimeInterval = (previousTime - temp) / 1000
        if (frameTime > maximumFrameTime) {
            frameTime = maximumFrameTime
        }
        dispatch(frameTime * timeAdjustment)
    }

    public var playing: Bool {
        isPlaying
    }

    public func getTimer() -> TimeInterval {
        Date().timeIntervalSince1970 * 1000
    }

	public func setPreviousTime(to newValue: TimeInterval) {
		previousTime = newValue
	}
}
