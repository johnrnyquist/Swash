//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

/// Diagnostic logging for Swash.
///
/// The engine emits a few informational notices (e.g. removing an entity or component
/// that isn't present). These are useful while developing a game but are just noise in a
/// shipping app, so they are gated behind a configurable threshold:
///
/// - Under `DEBUG` the default level is `.warning`, which silences the chatty `.info`
///   notices while still surfacing genuine `.warning`s.
/// - In release builds the default is `.none`, so a linked app stays silent unless it
///   opts in with `SwashLog.level = .debug`.
///
/// Consumers can also redirect output by replacing `SwashLog.handler` (for example to
/// route through `os.Logger` or to capture messages in a test).
public enum SwashLog {
    public enum Level: Int, Comparable {
        case none = 0
        case error
        case warning
        case info
        case debug

        public static func < (lhs: Level, rhs: Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    #if DEBUG
    public static var level: Level = .warning
    #else
    public static var level: Level = .none
    #endif

    /// Where emitted messages go. Defaults to `print`.
    public static var handler: (Level, String) -> Void = { _, message in print(message) }

    /// Emits `message` if `messageLevel` is at or below the current `level`.
    /// The message is `@autoclosure` so it isn't constructed when below the threshold.
    static func log(_ messageLevel: Level, _ message: @autoclosure () -> String) {
        guard messageLevel <= level else { return }
        handler(messageLevel, message())
    }
}
