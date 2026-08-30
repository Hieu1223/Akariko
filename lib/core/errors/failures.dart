/// Sealed hierarchy of domain failures.
///
/// Every repository / use-case returns a [Result] that, on failure, carries
/// one of these so the presentation layer can decide how to react without
/// depending on raw exceptions.
sealed class Failure {
  const Failure({this.message, this.error});

  final String? message;
  final Object? error;
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message, super.error});
}

final class StorageFailure extends Failure {
  const StorageFailure({super.message});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message});
}

final class ParseFailure extends Failure {
  const ParseFailure({super.message});
}
