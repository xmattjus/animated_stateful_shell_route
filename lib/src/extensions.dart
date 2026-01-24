/// Iterable helpers that expose index-aware mapping without extra packages.
extension IterableExtension<T> on Iterable<T> {
  /// Maps each element with its index to a new value.
  /// Mirrors collection's `mapIndexed` to avoid another dependency.
  Iterable<R> mapIndexed<R>(R Function(int index, T element) convert) sync* {
    var index = 0;
    for (var element in this) {
      yield convert(index++, element);
    }
  }
}
