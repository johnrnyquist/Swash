extension Sequence {
    var count: Int {
        var count = 0
        for _ in self {
            count += 1
        }
        return count
    }
}
