import 'package:equatable/equatable.dart';

/// Sealed hierarchy of domain-level failures.
///
/// Use cases return these inside a [Result] instead of throwing raw exceptions
/// across the domain↔presentation boundary, so the presentation layer can
/// pattern-match them exhaustively into typed states. The [message] is a
/// developer-facing default, not user copy — the UI should map a [Failure]
/// subtype to localized text rather than displaying it verbatim.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// A local persistence/read error surfaced from the data layer (Isar).
class DataFailure extends Failure {
  const DataFailure([super.message = 'A local data error occurred.']);
}

/// A bundled asset (the city dataset) could not be loaded or parsed.
class AssetFailure extends Failure {
  const AssetFailure([super.message = 'Failed to load city data.']);
}

/// The requested session could not be found.
class SessionNotFoundFailure extends Failure {
  const SessionNotFoundFailure([super.message = 'Session not found.']);
}

/// An operation that requires an active session was attempted without one.
class NoActiveSessionFailure extends Failure {
  const NoActiveSessionFailure([super.message = 'No active session.']);
}

/// An unexpected error that does not fit a more specific [Failure].
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
