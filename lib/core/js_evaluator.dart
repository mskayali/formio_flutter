/// JavaScript evaluator service for custom validation and calculated values.
///
/// Provides cross-platform JavaScript execution:
/// - Web: Uses dart:js (native browser JavaScript)
/// - Mobile/Desktop: Uses flutter_js (QuickJS engine)
library;

import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional imports for platform-specific JS evaluation
import 'js_evaluator_stub.dart' if (dart.library.html) 'js_evaluator_web.dart' if (dart.library.io) 'js_evaluator_mobile.dart';

class JavaScriptEvaluator {
  /// Evaluates JavaScript code with the given context.
  ///
  /// [code] - JavaScript code to execute
  /// [context] - Variables to expose to JavaScript
  /// [timeoutMs] - Maximum execution time in milliseconds (default: 5000)
  ///
  /// Returns the result of the JavaScript evaluation, or null on error.
  ///
  /// Example:
  /// ```dart
  /// final result = JavaScriptEvaluator.evaluate(
  ///   "input === 'magic'",
  ///   {'input': 'magic'},
  /// );
  /// print(result); // true
  /// ```
  static dynamic evaluate(
    String code,
    Map<String, dynamic> context, {
    int timeoutMs = 5000,
  }) {
    return evaluateJS(code, context, timeoutMs: timeoutMs);
  }

  /// Validates that JavaScript code is safe to execute.
  ///
  /// Checks for dangerous patterns like:
  /// - Direct eval usage
  /// - Function constructor
  /// - setTimeout/setInterval
  ///
  /// Throws [SecurityException] if dangerous code is detected.
  static void validateCode(String code) {
    final dangerous = [
      'eval(',
      'Function(',
      'setTimeout(',
      'setInterval(',
      'import(',
      'require(',
    ];

    for (final keyword in dangerous) {
      if (code.contains(keyword)) {
        throw SecurityException('Dangerous code pattern detected: $keyword');
      }
    }
  }

  /// Returns true if JavaScript evaluation is supported on this platform.
  static bool get isSupported {
    return true; // Supported on all platforms (web + flutter_js)
  }

  /// Returns the platform type being used.
  /// Disposes the persistent JavaScript runtime (for non-web platforms).
  static void dispose() {
    if (!kIsWeb) {
      disposeRuntime();
    }
  }
}

/// Exception thrown when dangerous JavaScript code is detected.
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
