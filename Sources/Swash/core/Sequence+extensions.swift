//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

extension Sequence {
    var count: Int {
        var count = 0
        for _ in self {
            count += 1
        }
        return count
    }
}
