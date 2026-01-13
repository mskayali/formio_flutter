/// Flutter-specific JavaScript evaluator using flutter_js package.
///
/// Provides JavaScript execution on mobile and desktop platforms.
library;

import 'package:flutter_js/flutter_js.dart';
import 'package:formio_api/formio_api.dart';

/// Flutter implementation of JsEvaluator using flutter_js package.
///
/// Uses QuickJS engine for JavaScript execution on mobile/desktop platforms.
class FlutterJsEvaluator implements JsEvaluator {
  JavascriptRuntime? _runtime;

  /// Gets or creates the JavaScript runtime.
  JavascriptRuntime get runtime {
    _runtime ??= getJavascriptRuntime();
    return _runtime!;
  }

  @override
  dynamic evaluate(String code, Map<String, dynamic> context) {
    try {
      // Set context variables
      for (final entry in context.entries) {
        runtime.evaluate('var ${entry.key} = ${_encodeValue(entry.value)};');
      }

      // Execute code
      final result = runtime.evaluate(code);
      
      if (result.isError) {
        throw JsEvaluationException(
          'JavaScript execution error',
          result.stringResult,
        );
      }

      return _decodeValue(result.rawResult);
    } catch (e) {
      throw JsEvaluationException('Failed to evaluate JavaScript', e);
    }
  }

  @override
  void validateCode(String code) {
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
        throw JsEvaluationException('Dangerous code pattern detected: $keyword');
      }
    }
  }

  @override
  void dispose() {
    _runtime?.dispose();
    _runtime = null;
  }

  /// Encodes a Dart value to JavaScript-compatible string.
  String _encodeValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"${_escapeString(value)}"';
    if (value is num || value is bool) return value.toString();
    if (value is Map) {
      final entries = value.entries
          .map((e) => '"${_escapeString(e.key.toString())}": ${_encodeValue(e.value)}')
          .join(', ');
      return '{$entries}';
    }
    if (value is List) {
      final items = value.map(_encodeValue).join(', ');
      return '[$items]';
    }
    return 'null';
  }

  /// Decodes JavaScript result to Dart value.
  dynamic _decodeValue(dynamic value) {
    // flutter_js already handles basic type conversion
    return value;
  }

  /// Escapes special characters in strings for JavaScript.
  String _escapeString(String str) {
    return str
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
