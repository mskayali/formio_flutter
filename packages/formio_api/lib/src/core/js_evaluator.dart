/// JavaScript evaluator adapter for formio_api package.
///
/// This file provides a static wrapper around a JsEvaluator instance
/// for backward compatibility with existing code.
library;

import 'js_evaluator_interface.dart';

/// Global JavaScript evaluator singleton.
///
/// Must be initialized before use. Defaults to NoOpJsEvaluator.
class JavaScriptEvaluator {
  static JsEvaluator _instance = const NoOpJsEvaluator();

  /// Sets the JavaScript evaluator implementation.
  ///
  /// This should be called once during application initialization.
  ///
  /// Example (Flutter):
  /// ```dart
  /// void main() {
  ///   JavaScriptEvaluator.setEvaluator(FlutterJsEvaluator());
  ///   runApp(MyApp());
  /// }
  /// ```
  static void setEvaluator(JsEvaluator evaluator) {
    _instance = evaluator;
  }

  /// Gets the current JavaScript evaluator instance.
  static JsEvaluator get instance => _instance;

  /// Evaluates JavaScript code with the given context.
  ///
  /// [code] - JavaScript code to execute
  /// [context] - Variables to expose to JavaScript
  ///
  /// Returns the result of the JavaScript evaluation, or null on error.
  ///
  /// Example:
  /// ```dart
  /// final result = JavaScriptEvaluator.evaluate(
  ///   "data.price * data.quantity",
  ///   {'data': {'price': 10.0, 'quantity': 5}},
  /// );
  /// print(result); // 50.0
  /// ```
  static dynamic evaluate(
    String code,
    Map<String, dynamic> context,
  ) {
    return _instance.evaluate(code, context);
  }

  /// Validates that JavaScript code is safe to execute.
  ///
  /// Checks for dangerous patterns like:
  /// - Direct eval usage
  /// - Function constructor
  /// - setTimeout/setInterval
  ///
  /// Throws [JsEvaluationException] if dangerous code is detected.
  static void validateCode(String code) {
    _instance.validateCode(code);
  }

  /// Disposes the JavaScript evaluator resources.
  static void dispose() {
    _instance.dispose();
  }

  /// Returns true if a JavaScript evaluator has been set.
  static bool get isConfigured => _instance is! NoOpJsEvaluator;
}
