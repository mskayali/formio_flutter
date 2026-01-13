/// Custom exception types used across the Form.io Flutter SDK.
///
/// These exceptions help with better error handling during API communication,
/// form parsing, submission processing, and more.
library;

/// Base class for all custom API-related errors.
class ApiException implements Exception {
  /// A human-readable error message.
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

/// Raised when a form schema cannot be parsed or converted properly.
class FormParseException extends ApiException {
  FormParseException(String message) : super('Form parse error: $message');
}

/// Raised when submission fails due to invalid payload or response.
class SubmissionException extends ApiException {
  SubmissionException(String message) : super('Submission error: $message');
}

/// Raised for general authentication/token-related issues.
class AuthException extends ApiException {
  AuthException(String message) : super('Auth error: $message');
}

/// Raised when a specific component is malformed or unsupported.
class ComponentFormatException extends ApiException {
  ComponentFormatException(String message) : super('Component format error: $message');
}
