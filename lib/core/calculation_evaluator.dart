/// Evaluates calculated values for Form.io components.
///
/// Form.io supports auto-calculated fields using JSONLogic or JavaScript expressions.

import 'package:jsonlogic/jsonlogic.dart';

import 'js_evaluator.dart';

class CalculationEvaluator {
  /// Evaluates a calculateValue expression and returns the result.
  ///
  /// Supports:
  /// - JSONLogic expressions (recommended)
  /// - JavaScript expressions (Form.io compatibility)
  ///
  /// Example calculateValue (JSONLogic):
  /// ```json
  /// {
  ///   "calculateValue": {
  ///     "*": [{"var": "data.price"}, {"var": "data.quantity"}]
  ///   }
  /// }
  /// ```
  ///
  /// Example calculateValue (JavaScript):
  /// ```json
  /// {
  ///   "calculateValue": "value = data.price * data.quantity * 1.18"
  /// }
  /// ```
  ///
  /// [calculateConfig] - The calculateValue configuration (JSONLogic or JavaScript string)
  /// [formData] - Current form data to use in calculation
  ///
  /// Returns the calculated value, or null if calculation fails.
  static dynamic evaluate(dynamic calculateConfig, Map<String, dynamic> formData) {
    if (calculateConfig == null) {
      return null;
    }

    // If it's a map, treat as JSONLogic
    if (calculateConfig is Map<String, dynamic>) {
      return _evaluateJSONLogic(calculateConfig, formData);
    }

    // If it's a string starting with 'value', it's JavaScript
    if (calculateConfig is String && calculateConfig.trim().startsWith('value')) {
      return _evaluateJavaScript(calculateConfig, formData);
    }

    // Unknown format
    return null;
  }

  /// Evaluates a JavaScript calculation expression.
  ///
  /// Example: `value = data.price * data.quantity * 1.18`
  static dynamic _evaluateJavaScript(String jsCode, Map<String, dynamic> formData) {
    try {
      // Create JavaScript context with data and value variables
      final context = {
        'data': formData,
        'value': null,
      };
      
      // Validate code safety
      JavaScriptEvaluator.validateCode(jsCode);
      
      // Execute JavaScript
      JavaScriptEvaluator.evaluate(jsCode, context);
      
      // Return the 'value' variable (Form.io convention)
      return context['value'];
    } catch (e) {
      print('Error evaluating JavaScript calculation: $e');
      return null;
    }
  }

  /// Evaluates a JSONLogic calculation expression.
  ///
  /// NOTE: For date calculations, convert dates to Unix timestamps
  /// (milliseconds since epoch) and use basic math operations.
  ///
  /// Example date calculation:
  /// ```json
  /// {
  ///   "calculateValue": {
  ///     "+": [
  ///       {"var": "data.startTimestamp"},
  ///       {"*": [7, 24, 60, 60, 1000]}  // Add 7 days in milliseconds
  ///     ]
  ///   }
  /// }
  /// ```
  static dynamic _evaluateJSONLogic(Map<String, dynamic> logic, Map<String, dynamic> formData) {
    try {
      final jsonLogic = Jsonlogic();
      
      // Wrap formData in a 'data' object to match Form.io convention
      // In Form.io, you access fields as {"var": "data.fieldName"}
      final context = {
        'data': formData,
      };
      
      final result = jsonLogic.apply(logic, context);
      return result;
    } catch (e) {
      print('Error evaluating JSONLogic calculation: $e');
      return null;
    }
  }

  /// Determines if a component has calculated values.
  static bool hasCalculation(Map<String, dynamic>? componentRaw) {
    return componentRaw?.containsKey('calculateValue') == true;
  }

  /// Checks if calculation can be overridden by user input.
  static bool allowsOverride(Map<String, dynamic>? componentRaw) {
    return componentRaw?['allowCalculateOverride'] == true;
  }

  /// Extracts field dependencies from a JSONLogic or JavaScript expression.
  ///
  /// Returns a list of field keys that this calculation depends on.
  /// Used to determine when to recalculate.
  static Set<String> extractDependencies(dynamic calculateConfig) {
    final dependencies = <String>{};

    if (calculateConfig is Map) {
      _extractDependenciesFromMap(calculateConfig, dependencies);
    } else if (calculateConfig is String) {
      // Extract from JavaScript code (simple regex approach)
      final regex = RegExp(r'data\.(\w+)');
      final matches = regex.allMatches(calculateConfig);
      for (final match in matches) {
        dependencies.add(match.group(1)!);
      }
    }

    return dependencies;
  }

  /// Recursively extracts dependencies from JSONLogic map.
  static void _extractDependenciesFromMap(Map<dynamic, dynamic> map, Set<String> dependencies) {
    for (final entry in map.entries) {
      if (entry.key == 'var') {
        // Found a variable reference
        final varPath = entry.value.toString();
        // Extract field name from "data.fieldName" format
        if (varPath.startsWith('data.')) {
          final fieldName = varPath.substring(5); // Remove "data." prefix
          dependencies.add(fieldName);
        }
      } else if (entry.value is Map) {
        _extractDependenciesFromMap(entry.value as Map, dependencies);
      } else if (entry.value is List) {
        for (final item in entry.value) {
          if (item is Map) {
            _extractDependenciesFromMap(item, dependencies);
          }
        }
      }
    }
  }
}
