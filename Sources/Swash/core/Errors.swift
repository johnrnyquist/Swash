//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

public enum SwashError: Error {
    case entityNameAlreadyInUse(String)
}

extension SwashError: Equatable {
    public static func == (lhs: SwashError, rhs: SwashError) -> Bool {
        switch (lhs, rhs) {
            case (.entityNameAlreadyInUse(let a), .entityNameAlreadyInUse(let b)):
                return a == b
        }
    }
}
