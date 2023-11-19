import class Foundation.Bundle
import func Foundation.NSClassFromString

func classFromString(className: String) -> AnyClass! {
    let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
    var cls: AnyClass? = NSClassFromString("\(namespace).\(className)")
    if cls == nil {
        cls = NSClassFromString("SwashTests.\(className)") //HACK
    }
    guard let cls else { fatalError("Class \(className) not found in Bundle \(namespace)!") }
    return cls
}
