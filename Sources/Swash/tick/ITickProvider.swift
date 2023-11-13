/**
	 * The interface for a tick provider. A tick provider dispatches a regular update tick
	 * to act as the heartbeat for the engine. It has methods to start and stop the tick and
	 * to add and remove listeners for the tick.
	 */
public protocol ITickProvider {
    var playing: Bool { get }

    func add(_ listener: Listener)

    func remove(_ listener: Listener)

    func start()

    func stop()
}
