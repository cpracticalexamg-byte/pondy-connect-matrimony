import '../errors/app_error.dart';

/// Functional Result type representing either a [Success] or [Failure].
sealed class Result<T, E extends AppError> {
  const Result();

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  E? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  T getOrThrow() => switch (this) {
        Success(:final value) => value,
        Failure(:final error) => throw error,
      };

  T getOrDefault(T defaultValue) => switch (this) {
        Success(:final value) => value,
        Failure() => defaultValue,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(E error) failure,
  }) =>
      switch (this) {
        Success(:final value) => success(value),
        Failure(:final error) => failure(error),
      };

  Result<R, E> map<R>(R Function(T value) transform) => switch (this) {
        Success(:final value) => Success(transform(value)),
        Failure(:final error) => Failure(error),
      };

  Result<T, R> mapError<R extends AppError>(R Function(E error) transform) =>
      switch (this) {
        Success(:final value) => Success(value),
        Failure(:final error) => Failure(transform(error)),
      };
}

/// Represents successful operation with value [value].
final class Success<T, E extends AppError> extends Result<T, E> {
  final T value;
  const Success(this.value);

  @override
  String toString() => 'Success($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T, E> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Represents failed operation with error [error].
final class Failure<T, E extends AppError> extends Result<T, E> {
  final E error;
  const Failure(this.error);

  @override
  String toString() => 'Failure($error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Failure<T, E> && other.error == error);

  @override
  int get hashCode => error.hashCode;
}
