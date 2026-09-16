/// Wraps a value together with information about where it came from, so the
/// UI can show an "offline / cached data" banner instead of silently
/// pretending cached data is fresh.
class DataWithSource<T> {
  final T data;
  final bool isFromCache;

  const DataWithSource({required this.data, required this.isFromCache});
}
