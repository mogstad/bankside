func +<K, V>(var left: [K: V], right: [K: V]) -> [K: V] {
  for (key, value) in right {
    left[key] = value
  }
  return left
}

func +=<K, V>(inout left: [K: V], right: [K: V]) {
  left = left + right
}
