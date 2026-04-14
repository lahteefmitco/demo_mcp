/// Exceptions used across repositories/cubits for centralized handling.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.cause});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause});
}

class UnexpectedException extends AppException {
  const UnexpectedException(super.message, {super.cause});
}

