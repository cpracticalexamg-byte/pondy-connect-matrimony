/// Strongly-typed hierarchy of domain and application errors.
sealed class AppError {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppError(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Authentication and session failures
class AuthError extends AppError {
  final AuthErrorType type;

  const AuthError(
    super.message, {
    this.type = AuthErrorType.unknown,
    super.cause,
    super.stackTrace,
  });

  factory AuthError.invalidOtp([String message = 'Invalid OTP entered.']) =>
      AuthError(message, type: AuthErrorType.invalidOtp);

  factory AuthError.otpExpired([String message = 'OTP has expired. Please request a new one.']) =>
      AuthError(message, type: AuthErrorType.otpExpired);

  factory AuthError.otpLockedOut([String message = 'Too many failed attempts. Try again in 10 minutes.']) =>
      AuthError(message, type: AuthErrorType.otpLockedOut);

  factory AuthError.rateLimited([String message = 'Too many requests. Please wait before requesting another OTP.']) =>
      AuthError(message, type: AuthErrorType.rateLimited);

  factory AuthError.sessionExpired([String message = 'Session expired. Please sign in again.']) =>
      AuthError(message, type: AuthErrorType.sessionExpired);

  factory AuthError.unauthorized([String message = 'You must be logged in to perform this action.']) =>
      AuthError(message, type: AuthErrorType.unauthorized);
}

enum AuthErrorType {
  invalidOtp,
  otpExpired,
  otpLockedOut,
  rateLimited,
  sessionExpired,
  unauthorized,
  unknown,
}

/// Validation failure on form or input fields
class ValidationError extends AppError {
  final String field;
  final String rule;

  const ValidationError({
    required this.field,
    required String reason,
    this.rule = 'required',
    super.cause,
    super.stackTrace,
  }) : super('Validation failed on $field: $reason');
}

/// CSV database / storage failures
class DatabaseError extends AppError {
  final String table;

  const DatabaseError(
    super.message, {
    required this.table,
    super.cause,
    super.stackTrace,
  });
}

/// Entity not found in store
class NotFoundError extends AppError {
  final String entity;
  final String id;

  const NotFoundError(
    this.entity,
    this.id, {
    super.cause,
    super.stackTrace,
  }) : super('$entity with ID "$id" not found.');
}

/// Network or external service errors
class NetworkError extends AppError {
  final int? statusCode;

  const NetworkError(
    super.message, {
    this.statusCode,
    super.cause,
    super.stackTrace,
  });
}

/// Permission / DPDP consent errors
class PermissionError extends AppError {
  const PermissionError(
    super.message, {
    super.cause,
    super.stackTrace,
  });
}
