import class Foundation.Bundle
import func Foundation.NSClassFromString

func classFromString(className: String) -> AnyClass {
    if let `class` = NSClassFromString(className) {
        return `class`
    } else if let namespace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String,
              let `class` = NSClassFromString("\(namespace).\(className)") {
        return `class`
    } else if let `class` = NSClassFromString("SwashTests.\(className)") { //HACK cannot dynamically get tests module name
        return `class`
    } else {
        fatalError("Class \(className) not found!")
    }
}
