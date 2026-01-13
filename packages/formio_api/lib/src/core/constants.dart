/// Central configuration constants used throughout the Form.io Flutter SDK.
///
/// This includes base API URL, headers, timeouts, and other global definitions
/// needed across services and utilities.
library;

class AppConstants {
  /// Base URL for your Form.io project or instance.
  /// Example: 'https://yourproject.form.io'
  static const String baseUrl = 'https://your-formio-instance.form.io';

  /// Request timeout duration for HTTP calls.
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Default path for fetching a form if not specified.
  static const String defaultFormPath = '/example';

  /// Header used for authenticated requests with JWT tokens.
  static const String authTokenHeader = 'x-jwt-token';

  /// Default content-type for API requests.
  static const String jsonContentType = 'application/json';

  /// Common date format (ISO 8601).
  static const String defaultDateFormat = 'yyyy-MM-dd';

  /// Default currency symbol used for currency components (fallback).
  static const String defaultCurrencySymbol = '\$';

  /// Placeholder used when no label is provided.
  static const String defaultFieldLabel = '(No Label)';
}
