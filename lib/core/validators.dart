/// Centralized validation functions for Form.io components.
///
/// Provides reusable validators that match Form.io's validation rules.
/// Components can use these validators in their TextFormField validator properties.
library;

import 'package:flutter/foundation.dart';
import 'validators_js_loader.dart';

class FormioValidators {
  /// Validates that a field is not empty if required.
  ///
  /// Returns error message if validation fails, null otherwise.
  static String? required(dynamic value, {String? fieldName}) {
    if (value == null) {
      return '${fieldName ?? "This field"} is required.';
    }

    if (value is String && value.trim().isEmpty) {
      return '${fieldName ?? "This field"} is required.';
    }

    if (value is List && value.isEmpty) {
      return '${fieldName ?? "This field"} is required.';
    }

    if (value is Map && value.isEmpty) {
      return '${fieldName ?? "This field"} is required.';
    }

    return null;
  }

  /// Validates that a string matches a regex pattern.
  ///
  /// Example patterns:
  /// - `^[A-Z]{2}\d{4}$` - Two uppercase letters followed by 4 digits
  /// - `^\d{3}-\d{3}-\d{4}$` - Phone format: 123-456-7890
  ///
  /// [pattern] - Regular expression pattern string
  /// [message] - Custom error message (optional)
  static String? pattern(String? value, String pattern, {String? message}) {
    if (value == null || value.isEmpty) {
      return null; // Don't validate empty values, use required() for that
    }

    try {
      final regex = RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return message ?? 'Invalid format. Must match pattern: $pattern';
      }
    } catch (e) {
      return 'Invalid validation pattern';
    }

    return null;
  }

  /// Validates minimum string length.
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Don't validate empty values
    }

    if (value.length < min) {
      return '${fieldName ?? "This field"} must be at least $min characters long.';
    }

    return null;
  }

  /// Validates maximum string length.
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > max) {
      return '${fieldName ?? "This field"} must not exceed $max characters.';
    }

    return null;
  }

  /// Validates minimum word count.
  static String? minWords(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final wordCount = _countWords(value);
    if (wordCount < min) {
      return '${fieldName ?? "This field"} must contain at least $min words.';
    }

    return null;
  }

  /// Validates maximum word count.
  static String? maxWords(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final wordCount = _countWords(value);
    if (wordCount > max) {
      return '${fieldName ?? "This field"} must not exceed $max words.';
    }

    return null;
  }

  /// Validates email format.
  static String? email(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return message ?? 'Please enter a valid email address.';
    }

    return null;
  }

  /// Validates URL format.
  static String? url(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return message ?? 'Please enter a valid URL (e.g., https://example.com)';
    }

    return null;
  }

  /// Validates minimum numeric value.
  static String? min(num? value, num minValue, {String? fieldName}) {
    if (value == null) {
      return null;
    }

    if (value < minValue) {
      return '${fieldName ?? "Value"} must be at least $minValue.';
    }

    return null;
  }

  /// Validates maximum numeric value.
  static String? max(num? value, num maxValue, {String? fieldName}) {
    if (value == null) {
      return null;
    }

    if (value > maxValue) {
      return '${fieldName ?? "Value"} must not exceed $maxValue.';
    }

    return null;
  }

  /// Validates that a string contains only valid JSON.
  static String? json(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      // Try to parse as JSON
      // ignore: unused_local_variable
      final _ = Uri.decodeComponent(value);
      return null;
    } catch (e) {
      return message ?? 'Please enter valid JSON.';
    }
  }

  /// Custom JavaScript validation.
  ///
  /// Executes JavaScript code to validate the input value.
  /// The JavaScript code has access to:
  /// - `input`: the current field value
  /// - `data`: entire form data
  /// - `valid`: boolean or string (error message)
  ///
  /// Example:
  /// ```dart
  /// FormioValidators.customJS(
  ///   'magic',
  ///   "valid = (input === 'magic') ? true : 'Must be magic';",
  ///   {},
  /// )
  /// ```
  ///
  /// Form.io format:
  /// ```json
  /// {
  ///   "validate": {
  ///     "custom": "valid = (input.length > 5) ? true : 'Too short';"
  ///   }
  /// }
  /// ```
  static String? customJS(
    String? value,
    String jsCode,
    Map<String, dynamic> formData, {
    String? fieldName,
  }) {
    try {
      // Import JavaScript evaluator
      // ignore: implementation_imports
      final jsEvaluator = _getJavaScriptEvaluator();

      if (jsEvaluator == null) {
        return 'JavaScript validation not available';
      }

      // Create JavaScript context
      final context = {
        'input': value,
        'data': formData,
        'valid': true,
      };

      // Validate code safety
      jsEvaluator.validateCode(jsCode);

      // Execute JavaScript
      final result = jsEvaluator.evaluate(jsCode, context);

      // Form.io validation result format:
      // - true or 'true' means valid
      // - string means error message
      // - false or anything else means generic error
      if (result == true || result == 'true' || result == 'True') {
        return null; // Valid
      } else if (result is String && result.isNotEmpty) {
        return result; // Custom error message
      } else {
        return '${fieldName ?? "This field"} is invalid.';
      }
    } catch (e) {
      debugPrint('Custom validation error for ${fieldName ?? "field"}: $e');
      return 'Validation failed: ${e.toString()}';
    }
  }

  /// Helper to lazily load JavaScript evaluator.
  static dynamic _getJavaScriptEvaluator() {
    try {
      // Import at runtime to avoid issues when JS not available
      return JavaScriptEvaluatorLoader.load();
    } catch (e) {
      return null;
    }
  }

  /// Combines multiple validators into one.
  ///
  /// Returns the first error message encountered, or null if all pass.
  ///
  /// Example:
  /// ```dart
  /// validator: (val) => FormioValidators.combine([
  ///   () => FormioValidators.required(val, fieldName: 'Email'),
  ///   () => FormioValidators.email(val),
  ///   () => FormioValidators.maxLength(val, 100),
  /// ]),
  /// ```
  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final error = validator();
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Helper to count words in a string.
  static int _countWords(String text) {
    // Remove extra whitespace and split by whitespace
    final words = text.trim().split(RegExp(r'\s+'));
    // Filter out empty strings
    return words.where((word) => word.isNotEmpty).length;
  }

  /// Validates that a field matches another field (e.g., password confirmation).
  ///
  /// [value] - Current field value
  /// [otherFieldValue] - Value of the field to match against
  /// [fieldName] - Name of current field for error message
  /// [otherFieldName] - Name of other field for error message
  static String? matchField(
    String? value,
    dynamic otherFieldValue,
    String fieldName,
    String otherFieldName,
  ) {
    if (value == null || value.isEmpty) {
      return null; // Don't validate empty values
    }

    if (value != otherFieldValue?.toString()) {
      return '$fieldName must match $otherFieldName.';
    }

    return null;
  }

  /// Cross-field validation - compare two fields with a comparison operator.
  ///
  /// [value] - Current field value
  /// [otherFieldValue] - Value to compare against
  /// [operator] - Comparison operator ('>', '<', '>=', '<=', '==', '!=')
  /// [fieldName] - Name of current field
  /// [otherFieldName] - Name of other field
  static String? compareFields(
    dynamic value,
    dynamic otherFieldValue,
    String operator,
    String fieldName,
    String otherFieldName,
  ) {
    if (value == null) return null;

    // Try to parse as numbers for numeric comparison
    final numValue = num.tryParse(value.toString());
    final numOther = num.tryParse(otherFieldValue?.toString() ?? '');

    if (numValue != null && numOther != null) {
      switch (operator) {
        case '>':
          if (!(numValue > numOther)) {
            return '$fieldName must be greater than $otherFieldName.';
          }
          break;
        case '<':
          if (!(numValue < numOther)) {
            return '$fieldName must be less than $otherFieldName.';
          }
          break;
        case '>=':
          if (!(numValue >= numOther)) {
            return '$fieldName must be greater than or equal to $otherFieldName.';
          }
          break;
        case '<=':
          if (!(numValue <= numOther)) {
            return '$fieldName must be less than or equal to $otherFieldName.';
          }
          break;
        case '==':
          if (numValue != numOther) {
            return '$fieldName must equal $otherFieldName.';
          }
          break;
        case '!=':
          if (numValue == numOther) {
            return '$fieldName must not equal $otherFieldName.';
          }
          break;
      }
    }

    return null;
  }

  /// Creates a validator function from Form.io validation config.
  ///
  /// Parses the component's validate object and returns a combined validator.
  /// For cross-field validation, pass the form data context.
  ///
  /// Example validate config:
  /// ```json
  /// {
  ///   "required": true,
  ///   "minLength": 3,
  ///   "maxLength": 50,
  ///   "pattern": "^[A-Za-z]+$"
  /// }
  /// ```
  static String? Function(String?)? fromConfig(
    Map<String, dynamic>? validateConfig,
    String fieldName, {
    Map<String, dynamic>? formData,
  }) {
    if (validateConfig == null || validateConfig.isEmpty) {
      return null;
    }

    return (String? value) {
      final validators = <String? Function()>[];

      // Required
      if (validateConfig['required'] == true || validateConfig['required'] == 'true') {
        validators.add(() => required(value, fieldName: fieldName));
      }

      // String length
      if (validateConfig['minLength'] != null) {
        final min = validateConfig['minLength'] is int ? validateConfig['minLength'] as int : int.tryParse(validateConfig['minLength'].toString()) ?? 0;
        if (min > 0) {
          validators.add(() => minLength(value, min, fieldName: fieldName));
        }
      }

      if (validateConfig['maxLength'] != null) {
        final max = validateConfig['maxLength'] is int ? validateConfig['maxLength'] as int : int.tryParse(validateConfig['maxLength'].toString()) ?? 0;
        if (max > 0) {
          validators.add(() => maxLength(value, max, fieldName: fieldName));
        }
      }

      // Word count
      if (validateConfig['minWords'] != null) {
        final min = validateConfig['minWords'] is int ? validateConfig['minWords'] as int : int.tryParse(validateConfig['minWords'].toString()) ?? 0;
        if (min > 0) {
          validators.add(() => minWords(value, min, fieldName: fieldName));
        }
      }

      if (validateConfig['maxWords'] != null) {
        final max = validateConfig['maxWords'] is int ? validateConfig['maxWords'] as int : int.tryParse(validateConfig['maxWords'].toString()) ?? 0;
        if (max > 0) {
          validators.add(() => maxWords(value, max, fieldName: fieldName));
        }
      }

      // Pattern
      if (validateConfig['pattern'] != null) {
        final patternStr = validateConfig['pattern'].toString();
        if (patternStr.isNotEmpty) {
          validators.add(() => pattern(value, patternStr));
        }
      }

      // Cross-field validation - matchField
      if (validateConfig['matchField'] != null && formData != null) {
        final matchFieldKey = validateConfig['matchField'].toString();
        validators.add(() => matchField(
              value,
              formData[matchFieldKey],
              fieldName,
              matchFieldKey,
            ));
      }

      return combine(validators);
    };
  }

  /// Validates minimum date.
  static String? minDate(DateTime? value, DateTime minDate, {String? fieldName}) {
    if (value == null) return null;

    if (value.isBefore(minDate)) {
      return '${fieldName ?? "Date"} must be on or after ${_formatDate(minDate)}.';
    }

    return null;
  }

  /// Validates maximum date.
  static String? maxDate(DateTime? value, DateTime maxDate, {String? fieldName}) {
    if (value == null) return null;

    if (value.isAfter(maxDate)) {
      return '${fieldName ?? "Date"} must be on or before ${_formatDate(maxDate)}.';
    }

    return null;
  }

  /// Validates date range.
  static String? dateRange(DateTime? value, DateTime? minDate, DateTime? maxDate, {String? fieldName}) {
    if (value == null) return null;

    if (minDate != null) {
      final error = FormioValidators.minDate(value, minDate, fieldName: fieldName);
      if (error != null) return error;
    }

    if (maxDate != null) {
      final error = FormioValidators.maxDate(value, maxDate, fieldName: fieldName);
      if (error != null) return error;
    }

    return null;
  }

  /// Validates minimum year.
  static String? minYear(DateTime? value, int minYear, {String? fieldName}) {
    if (value == null) return null;

    if (value.year < minYear) {
      return '${fieldName ?? "Year"} must be $minYear or later.';
    }

    return null;
  }

  /// Validates maximum year.
  static String? maxYear(DateTime? value, int maxYear, {String? fieldName}) {
    if (value == null) return null;

    if (value.year > maxYear) {
      return '${fieldName ?? "Year"} must be $maxYear or earlier.';
    }

    return null;
  }

  /// Validates file size (in bytes).
  static String? fileSize(int? sizeBytes, {int? minSize, int? maxSize, String? fieldName}) {
    if (sizeBytes == null) return null;

    if (minSize != null && sizeBytes < minSize) {
      return '${fieldName ?? "File"} must be at least ${_formatFileSize(minSize)}.';
    }

    if (maxSize != null && sizeBytes > maxSize) {
      return '${fieldName ?? "File"} must not exceed ${_formatFileSize(maxSize)}.';
    }

    return null;
  }

  /// Validates file type/pattern.
  static String? filePattern(String? fileName, String pattern, {String? message}) {
    if (fileName == null || fileName.isEmpty) return null;

    // Pattern can be comma-separated extensions: ".pdf,.doc,.docx"
    // or mime types: "application/pdf,application/msword"
    final patterns = pattern.split(',').map((p) => p.trim()).toList();

    final extension = fileName.contains('.') ? '.${fileName.split('.').last.toLowerCase()}' : '';

    // Check if any pattern matches
    final matches = patterns.any((p) {
      if (p.startsWith('.')) {
        // Extension match
        return extension == p.toLowerCase();
      } else if (p.contains('/')) {
        // MIME type match (would need actual file MIME type)
        // For now, just check common extensions
        return _matchesMimeType(extension, p);
      }
      return false;
    });

    if (!matches) {
      return message ?? 'File type not allowed. Allowed types: $pattern';
    }

    return null;
  }

  /// Helper to format date for error messages.
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Helper to format file size for error messages.
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Helper to match file extension to MIME type.
  static bool _matchesMimeType(String extension, String mimeType) {
    final mimeMap = {
      '.pdf': 'application/pdf',
      '.doc': 'application/msword',
      '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      '.xls': 'application/vnd.ms-excel',
      '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      '.ppt': 'application/vnd.ms-powerpoint',
      '.pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.txt': 'text/plain',
      '.csv': 'text/csv',
    };

    return mimeMap[extension] == mimeType;
  }

  /// Creates a cross-field validator that compares two fields.
  ///
  /// Example usage:
  /// ```dart
  /// validator: (val) => FormioValidators.crossFieldValidator(
  ///   value: val,
  ///   formData: _formData,
  ///   fieldKey: 'endDate',
  ///   compareFieldKey: 'startDate',
  ///   operator: '>',
  ///   message: 'End date must be after start date',
  /// ),
  /// ```
  static String? crossFieldValidator({
    required dynamic value,
    required Map<String, dynamic> formData,
    required String fieldKey,
    required String compareFieldKey,
    required String operator,
    String? message,
  }) {
    final error = compareFields(
      value,
      formData[compareFieldKey],
      operator,
      fieldKey,
      compareFieldKey,
    );

    return error != null && message != null ? message : error;
  }
}
