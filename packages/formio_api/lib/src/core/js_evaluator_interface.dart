/// Abstract interface for JavaScript evaluation in Form.io calculations and validations.
///
/// This interface allows  the formio_api package to remain pure Dart while
/// enabling JavaScript execution through platform-specific implementations.
///
/// Implementations:
/// - For Flutter: Use flutter_js package (in flutter_formio)
/// - For Web: Use dart:js_interop
/// - For Dart VM: Use a JavaScript engine like QuickJS
library;

/// Abstract interface for evaluating JavaScript code.
///
/// Implementations must provide thread-safe JavaScript execution
/// with proper context isolation.
abstract class JsEvaluator {
  /// Evaluates JavaScript code with the given context.
  ///
  /// [code] - The JavaScript code to execute
  /// [context] - Variables/data available to the JavaScript code
  ///
  /// Returns the result of the JavaScript evaluation, or null if evaluation fails.
  ///
  /// Example:
  /// ```dart
  /// final result = evaluator.evaluate(
  ///   'data.price * data.quantity',
  ///   {'data': {'price': 10.0, 'quantity': 5}},
  /// );
  /// print(result); // 50.0
  /// ```
  dynamic evaluate(String code, Map<String, dynamic> context);

  /// Validates that the JavaScript code is safe to execute.
  ///
  /// Should check for potentially dangerous operations like:
  /// - eval()
  /// - Function constructor
  /// - Global object access
  /// - File system operations
  ///
  /// Throws [JsEvaluationException] if code is deemed unsafe.
  void validateCode(String code);

  /// Disposes resources used by this evaluator.
  ///
  /// Should be called when the evaluator is no longer needed.
  void dispose();
}

/// Exception thrown when JavaScript evaluation fails.
class JsEvaluationException implements Exception {
  final String message;
  final dynamic originalError;

  const JsEvaluationException(this.message, [this.originalError]);

  @override
  String toString() => 'JsEvaluationException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// A no-op JavaScript evaluator that always returns null.
///
/// Used as a fallback when no JavaScript engine is available.
/// Useful for testing or when JavaScript features are not needed.
class NoOpJsEvaluator implements JsEvaluator {
  const NoOpJsEvaluator();

  @override
  dynamic evaluate(String code, Map<String, dynamic> context) {
    // No-op implementation - just return null
    return null;
  }

  @override
  void validateCode(String code) {
    // No validation needed for no-op
  }

  @override
  void dispose() {
    // Nothing to dispose
  }
}
