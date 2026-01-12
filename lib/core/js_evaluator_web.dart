/// Web implementation of JavaScript evaluator using dart:js.
///
/// Uses the browser's native JavaScript engine.

import 'dart:js' as js;

dynamic evaluateJS(
  String code,
  Map<String, dynamic> context, {
  int timeoutMs = 5000,
}) {
  try {
    // Create a JavaScript context object
    final jsContext = js.JsObject.jsify(context);
    
    // Create a function that takes the context and returns the result
    final wrappedCode = '''
      (function(context) {
        ${_injectContext(context)}
        ${code};
        return typeof result !== 'undefined' ? result : 
               typeof valid !== 'undefined' ? valid :
               typeof value !== 'undefined' ? value : null;
      })
    ''';
    
    // Evaluate the JavaScript code
    final jsFunction = js.context.callMethod('eval', [wrappedCode]);
    final result = jsFunction.apply([jsContext]);
    
    // Convert JS result to Dart
    return _convertToDart(result);
  } catch (e) {
    print('JavaScript evaluation error (web): $e');
    return null;
  }
}

/// Injects context variables into JavaScript scope.
String _injectContext(Map<String, dynamic> context) {
  final buffer = StringBuffer();
  context.forEach((key, value) {
    buffer.writeln('var $key = context.$key;');
  });
  return buffer.toString();
}

/// Converts JavaScript values to Dart values.
dynamic _convertToDart(dynamic jsValue) {
  if (jsValue == null) return null;
  
  // Handle JS objects
  if (jsValue is js.JsObject) {
    // Check if it's an array
    if (js.context['Array'].callMethod('isArray', [jsValue])) {
      final length = jsValue['length'] as int;
      return List.generate(length, (i) => _convertToDart(jsValue[i]));
    }
    
    // Convert to Map
    final map = <String, dynamic>{};
    final keys = js.context['Object'].callMethod('keys', [jsValue]) as List;
    for (final key in keys) {
      map[key.toString()] = _convertToDart(jsValue[key]);
    }
    return map;
  }
  
  // Primitive types are already converted
  return jsValue;
}
