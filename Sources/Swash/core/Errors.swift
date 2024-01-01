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
