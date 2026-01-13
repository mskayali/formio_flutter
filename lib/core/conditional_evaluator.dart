/// Conditional logic evaluator for Form.io components.
///
/// Form.io supports multiple types of conditional logic:
/// 1. Simple conditionals: Basic field comparisons (when/eq/show)
/// 2. JSONLogic: Advanced JavaScript-style logic expressions
/// 3. JavaScript: Custom JavaScript code (not supported in Dart)
///
/// This evaluator handles both simple and JSONLogic conditions.
library;

import 'package:jsonlogic/jsonlogic.dart';
import 'package:flutter/foundation.dart';

class ConditionalEvaluator {
  /// Evaluates whether a component should be shown based on its conditional logic.
  ///
  /// Supports:
  /// - Simple conditionals: {when: 'field', eq: 'value', show: true/false}
  /// - JSONLogic: {json: {...}} format with standard JSONLogic operations
  ///
  /// Parameters:
  /// - [conditional]: The conditional configuration from component.raw['conditional']
  /// - [formData]: The current form data to evaluate against
  ///
  /// Returns true if the component should be shown, false otherwise.
  static bool shouldShow(Map<String, dynamic>? conditional, Map<String, dynamic> formData) {
    // No conditional means always show
    if (conditional == null || conditional.isEmpty) {
      return true;
    }

    // Check if this is a JSONLogic conditional
    if (conditional.containsKey('json')) {
      return _evaluateJSONLogic(conditional['json'], formData);
    }

    // Check if this is a custom JavaScript conditional (not supported)
    if (conditional.containsKey('custom')) {
      // JavaScript custom code is not supported in Dart
      // Log a warning and default to showing the component
      debugPrint('Warning: JavaScript custom conditionals are not supported. Component will be shown by default.');
      return true;
    }

    // Otherwise, treat as a simple conditional
    return _evaluateSimpleConditional(conditional, formData);
  }

  /// Evaluates a simple conditional (when/eq/show format).
  static bool _evaluateSimpleConditional(Map<String, dynamic> conditional, Map<String, dynamic> formData) {
    final when = conditional['when'];
    final eq = conditional['eq'];
    final show = conditional['show'];

    // If no 'when' field is specified, always show
    if (when == null || when.toString().isEmpty) {
      return true;
    }

    // Get the value of the field specified in 'when'
    final fieldValue = _getNestedValue(formData, when.toString());

    debugPrint('🔍 Conditional: when=$when, eq=$eq, show=$show');
    debugPrint('🔍 Field value: $fieldValue (type: ${fieldValue?.runtimeType})');

    // Check if the field value matches the expected value
    final matches = _valuesMatch(fieldValue, eq);

    debugPrint('🔍 Matches: $matches');

    // Determine whether to show based on the 'show' flag
    // If show is true (default), show when matches
    // If show is false, show when doesn't match
    final shouldShowWhenMatched = show == null || show == true || show == 'true';

    final result = shouldShowWhenMatched ? matches : !matches;
    debugPrint('🔍 Result: $result');

    return result;
  }

  /// Evaluates a JSONLogic conditional.
  static bool _evaluateJSONLogic(dynamic jsonLogicRule, Map<String, dynamic> formData) {
    if (jsonLogicRule == null) {
      return true;
    }

    try {
      // Use the jsonlogic package to evaluate the rule
      final jsonLogic = Jsonlogic();
      final result = jsonLogic.apply(jsonLogicRule, formData);

      // Convert result to boolean
      if (result is bool) {
        return result;
      } else if (result is num) {
        return result != 0;
      } else if (result is String) {
        return result.isNotEmpty && result.toLowerCase() != 'false';
      } else if (result == null) {
        return false;
      }

      // For other types, treat as truthy if not empty
      return true;
    } catch (e) {
      debugPrint('Error evaluating JSONLogic conditional: $e');
      // Default to showing the component if evaluation fails
      return true;
    }
  }

  /// Gets a nested value from an object using dot notation.
  /// For example, 'user.address.city' would access formData['user']['address']['city'].
  static dynamic _getNestedValue(Map<String, dynamic> data, String path) {
    final parts = path.split('.');
    dynamic current = data;

    for (final part in parts) {
      if (current is Map<String, dynamic>) {
        current = current[part];
      } else {
        return null;
      }
    }

    return current;
  }

  /// Checks if two values match, with special handling for different types.
  ///
  /// Special handling for selectboxes:
  /// - selectboxes values are Maps like {"1": false, "5": true}
  /// - When checking eq: "5", we need to see if key "5" is true in the Map
  static bool _valuesMatch(dynamic value1, dynamic value2) {
    // Handle null cases
    if (value1 == null && value2 == null) return true;
    if (value1 == null || value2 == null) return false;

    // Special handling for selectboxes (Map values)
    // selectboxes value is like: {"1": false, "2": true, "5": true}
    // When eq is "5", check if value1["5"] == true
    if (value1 is Map<String, dynamic>) {
      final key = value2.toString();
      final mapValue = value1[key];
      if (mapValue is bool) {
        return mapValue;
      }
      // Also handle string "true"/"false"
      if (mapValue is String) {
        return mapValue.toLowerCase() == 'true';
      }
      return false;
    }

    // Direct equality check
    if (value1 == value2) return true;

    // String comparison (case-insensitive for booleans)
    final str1 = value1.toString().toLowerCase();
    final str2 = value2.toString().toLowerCase();

    return str1 == str2;
  }

  /// Validates if a conditional configuration is valid.
  /// Returns null if valid, error message if invalid.
  static String? validateConditional(Map<String, dynamic>? conditional) {
    if (conditional == null || conditional.isEmpty) {
      return null; // No conditional is valid
    }

    // Check for JSONLogic
    if (conditional.containsKey('json')) {
      if (conditional['json'] is! Map) {
        return 'JSONLogic conditional must have a valid JSON object';
      }
      return null;
    }

    // Check for custom JavaScript
    if (conditional.containsKey('custom')) {
      return 'JavaScript custom conditionals are not supported in Dart';
    }

    // Validate simple conditional
    if (!conditional.containsKey('when')) {
      return 'Simple conditional must have a "when" field';
    }

    return null;
  }
}
