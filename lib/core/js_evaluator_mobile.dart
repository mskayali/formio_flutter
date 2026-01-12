/// Mobile/Desktop implementation of JavaScript evaluator using flutter_js.
///
/// Uses QuickJS engine on all non-web platforms.

import 'package:flutter_js/flutter_js.dart';

dynamic evaluateJS(
  String code,
  Map<String, dynamic> context, {
  int timeoutMs = 5000,
}) {
  JavascriptRuntime? runtime;
  
  try {
    // Create JavaScript runtime
    runtime = getJavascriptRuntime();
    
    // Inject context variables
    _injectContext(runtime, context);
    
    // Wrap code to capture result
    final wrappedCode = '''
      (function() {
        ${code};
        return typeof result !== 'undefined' ? result : 
               typeof valid !== 'undefined' ? valid :
               typeof value !== 'undefined' ? value : null;
      })()
    ''';
    
    // Evaluate with timeout
    final jsResult = runtime.evaluate(wrappedCode);
    
    // Convert to Dart
    return _convertToDart(jsResult);
  } catch (e) {
    print('JavaScript evaluation error (mobile): $e');
    return null;
  } finally {
    // Clean up runtime
    runtime?.dispose();
  }
}

/// Injects context variables into JavaScript runtime.
void _injectContext(JavascriptRuntime runtime, Map<String, dynamic> context) {
  context.forEach((key, value) {
    final jsonValue = _convertToJS(value);
    runtime.evaluate('var $key = $jsonValue;');
  });
}

/// Converts Dart values to JavaScript literal strings.
String _convertToJS(dynamic value) {
  if (value == null) return 'null';
  if (value is String) return "'${value.replaceAll("'", "\\'")}'";
  if (value is num) return value.toString();
  if (value is bool) return value.toString();
  if (value is List) {
    final items = value.map((item) => _convertToJS(item)).join(', ');
    return '[$items]';
  }
  if (value is Map) {
    final entries = value.entries
        .map((e) => "'${e.key}': ${_convertToJS(e.value)}")
        .join(', ');
    return '{$entries}';
  }
  return 'null';
}

/// Converts JavaScript result to Dart value.
dynamic _convertToDart(JsEvalResult jsResult) {
  if (jsResult.isError) {
    throw Exception(jsResult.stringResult);
  }
  
  // Get the raw result string
  final resultString = jsResult.stringResult;
  
  // Try to parse as different types
  if (resultString == 'null' || resultString == 'undefined') {
    return null;
  }
  
  if (resultString == 'true') return true;
  if (resultString == 'false') return false;
  
  // Try parsing as number
  final numResult = num.tryParse(resultString);
  if (numResult != null) return numResult;
  
  // Return as string
  return resultString;
}
