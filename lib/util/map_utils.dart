extension ScrubValue<K, V> on Map<K, V> {
  void scrubIfPresent(K key, V Function(V) scrubber) {
    if (containsKey(key)) {
      this[key] = scrubber(this[key] as V);
    }
  }
}
