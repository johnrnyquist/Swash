import func Foundation.sqrt
import struct Foundation.CGFloat
import struct Foundation.CGPoint

extension CGPoint {
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        var sum = CGPoint()
        sum = CGPoint(x: (left.x + right.x), y: (left.y + right.y))
        return sum
    }

    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        var sum = CGPoint()
        sum = CGPoint(x: (left.x - right.x), y: (left.y - right.y))
        return sum
    }

    func distance(p: CGPoint) -> CGFloat {
        let dx = x - p.x
        let dy = y - p.y
        return sqrt(dx * dx + dy * dy)
    }
}
