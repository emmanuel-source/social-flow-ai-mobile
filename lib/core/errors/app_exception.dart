sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expirée.']);
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

final class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}
