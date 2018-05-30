func +<K, V>(left: [K: V], right: [K: V]) -> [K: V] {
  var left = left
  for (key, value) in right {
    left[key] = value
  }
  return left
}

func +=<K, V>(left: inout [K: V], right: [K: V]) {
  left = left + right
}
