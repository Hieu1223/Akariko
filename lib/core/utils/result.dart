import '../errors/failures.dart';

/// Result type: either [Ok] with a value or [Err] with a [Failure].
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T get value {
    return switch (this) {
      Ok<T> ok => ok.value,
      Err<T> err => throw StateError(
          'Tried to read value from Err: ${err.failure.message}',
        ),
    };
  }

  Failure get failure {
    return switch (this) {
      Ok<T> _ => throw StateError('Tried to read failure from Ok'),
      Err<T> err => err.failure,
    };
  }

  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) {
    return switch (this) {
      Ok<T> ok => onOk(ok.value),
      Err<T> err => onErr(err.failure),
    };
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  @override
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  @override
  final Failure failure;
}
