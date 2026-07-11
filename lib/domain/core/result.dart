import 'failure.dart';

/// A functional result: either a [Success] carrying a value, or a
/// [ResultFailure] carrying a [Failure].
///
/// Use cases return this instead of throwing so callers handle errors
/// exhaustively via Dart pattern matching:
///
/// ```dart
/// switch (result) {
///   case Success(:final value): // use value
///   case ResultFailure(:final failure): // handle failure
/// }
/// ```
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;
}

/// The successful branch, carrying the produced [value].
class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

/// The failed branch, carrying the [failure] that occurred.
class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;
}
