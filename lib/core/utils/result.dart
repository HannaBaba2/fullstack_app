import 'package:fullstack_app/core/error/failures.dart';

/// Minimal Either-like wrapper so repositories can return either a
/// [Failure] or a value of type [T] without throwing across layers.
class Result<T> {
  final Failure? failure;
  final T? data;

  const Result._({this.failure, this.data});

  factory Result.success(T data) => Result._(data: data);
  factory Result.error(Failure failure) => Result._(failure: failure);

  bool get isSuccess => failure == null;
  bool get isError => failure != null;

  R fold<R>(R Function(Failure failure) onError, R Function(T data) onSuccess) {
    if (isError) return onError(failure as Failure);
    return onSuccess(data as T);
  }
}
