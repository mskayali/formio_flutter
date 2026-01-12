/// Evaluates calculated values for Form.io components.
///
/// Form.io supports auto-calculated fields using JSONLogic expressions.
/// Custom JavaScript code is not supported in Dart - use JSONLogic instead.

import 'package:jsonlogic/jsonlogic.dart';

class CalculationEvaluator {
  /// Evaluates a calculateValue expression and returns the result.
  ///
  /// Supports JSONLogic-based calculations.
  ///
  /// Example calculateValue:
  /// ```json
  /// {
  ///   "calculateValue": {
  ///     "*": [{"var": "data.price"}, {"var": "data.quantity"}]
  ///   }
  /// }
  /// ```
  ///
  /// [calculateConfig] - The calculateValue configuration (JSONLogic or string)
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

    // If it's a string starting with 'value =', it's JavaScript (not supported)
    if (calculateConfig is String && calculateConfig.trim().startsWith('value')) {
      print('Warning: JavaScript calculateValue expressions are not supported in Dart. '
          'Please use JSONLogic format instead.');
      return null;
    }

    // Unknown format
    return null;
  }

  /// Evaluates a JSONLogic calculation expression.
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

  /// Extracts field dependencies from a JSONLogic expression.
  ///
  /// Returns a list of field keys that this calculation depends on.
  /// Used to determine when to recalculate.
  static Set<String> extractDependencies(dynamic calculateConfig) {
    final dependencies = <String>{};

    if (calculateConfig is Map) {
      _extractDependenciesFromMap(calculateConfig, dependencies);
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
