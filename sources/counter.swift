/// Internal data structure for keeping track of sequences. We want sequences to
/// be globally unique, incase of subclasses or overlapping sequences.
struct Counter {

  var sequence: Int = 0
  
  mutating func reset() {
    self.sequence = 0
  }

  mutating func increment() -> Int {
    self.sequence += 1
    return sequence
  }

  static var defaultCounter = Counter()
  
}
