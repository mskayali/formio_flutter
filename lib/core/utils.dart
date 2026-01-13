import 'package:intl/intl.dart';

import '../widgets/component_factory.dart';
import 'constants.dart';

/// A set of utility functions used throughout the Form.io Flutter integration.
///
/// These functions handle tasks such as safe JSON parsing, null checks,
/// and simple data transformations.
/// Common utility functions used throughout the Form.io Flutter SDK.
///
/// Includes validators, date/number formatting helpers, and safe JSON helpers.

class FormioUtils {
  /// Checks if a given value is considered "null" or empty.
  ///
  /// Supports `null`, empty `String`, and empty `List` or `Map`.
  static bool isNullOrEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String && value.trim().isEmpty) return true;
    if (value is Iterable && value.isEmpty) return true;
    if (value is Map && value.isEmpty) return true;
    return false;
  }

  /// Attempts to parse a value to a boolean.
  ///
  /// Accepts various formats:
  /// - `"true"` or `"false"`
  /// - `1` or `0`
  /// - `true` or `false`
  ///
  /// Returns `false` if value is unrecognized.
  static bool parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is num) return value == 1;
    return false;
  }

  /// Safely retrieves a nested property from a Map.
  ///
  /// Example:
  /// ```dart
  /// final value = FormioUtils.getNested(json, ['data', 'email']);
  /// ```
  /// Returns `null` if any key is missing along the path.
  static dynamic getNested(Map<String, dynamic> json, List<String> path) {
    dynamic result = json;
    for (final key in path) {
      if (result is Map<String, dynamic> && result.containsKey(key)) {
        result = result[key];
      } else {
        return null;
      }
    }
    return result;
  }

  /// Validates that a required field is not empty or null.
  ///
  /// Returns an error message if the field is empty, otherwise null.
  String? validateRequired(String? input, String fieldName) {
    if (input == null || input.trim().isEmpty) {
      return ComponentFactory.locale.getRequiredMessage(fieldName);
    }
    return null;
  }

  /// Safely parses a date string into [DateTime]. Returns null on failure.
  ///
  /// Expected format: ISO 8601 or `yyyy-MM-dd`.
  DateTime? safeParseDate(String? input) {
    try {
      if (input == null || input.isEmpty) return null;
      return DateTime.parse(input);
    } catch (_) {
      return null;
    }
  }

  /// Formats a [DateTime] object to a readable string.
  ///
  /// Uses `yyyy-MM-dd` format by default.
  String formatDate(DateTime date, {String? pattern}) {
    final formatter = DateFormat(pattern ?? AppConstants.defaultDateFormat);
    return formatter.format(date);
  }

  /// Parses a string into a [num] if valid. Returns null otherwise.
  num? safeParseNumber(String? input) {
    try {
      return num.tryParse(input ?? '');
    } catch (_) {
      return null;
    }
  }

  /// Safely accesses a nested key in a JSON map. Returns null if missing.
  dynamic tryGet(Map<String, dynamic>? json, String key) {
    if (json == null) return null;
    return json.containsKey(key) ? json[key] : null;
  }
}
