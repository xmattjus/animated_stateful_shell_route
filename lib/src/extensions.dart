extension IterableExtension<T> on Iterable<T> {
  /// Maps each element and its index to a new value.
  ///
  /// Source: https://github.com/dart-lang/core/blob/main/pkgs/collection/lib/src/iterable_extensions.dart
  Iterable<R> mapIndexed<R>(R Function(int index, T element) convert) sync* {
    var index = 0;
    for (var element in this) {
      yield convert(index++, element);
    }
  }
}
