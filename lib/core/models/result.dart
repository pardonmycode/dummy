/// Simple Result type for error handling.
class Result<T, E> {
  final T? value;
  final E? error;

  Result._({this.value, this.error});

  factory Result.success(T value) => Result._(value: value);
  factory Result.error(E error) => Result._(error: error);

  bool get isSuccess => error == null;
  bool get isError => error != null;
}