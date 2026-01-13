/// Represents a generic Form.io component (form field or layout element).
///
/// Each component defines its type (e.g., textfield, checkbox), key,
/// label, validation rules, and other configuration options.
library;

class ComponentModel {
  /// Type of the component (e.g., "textfield", "select", "checkbox").
  final String type;

  /// Key identifier used for mapping form data.
  final String key;

  /// Display label shown on the UI.
  final String label;

  /// Whether this component is required to be filled by the user.
  final bool required;

  /// The default value for the component, if any.
  final dynamic defaultValue;

  /// The original raw JSON structure of the component.
  final Map<String, dynamic> raw;

  ComponentModel({
    required this.type,
    required this.key,
    required this.label,
    required this.required,
    this.defaultValue,
    required this.raw,
  });

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    final validate = json['validate'] as Map<String, dynamic>?;

    // Create a copy of the JSON to avoid mutating the original
    final rawCopy = Map<String, dynamic>.from(json);
    
    return ComponentModel(
      type: json['type']?.toString() ?? 'unknown',
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      required: validate?['required'] == true || validate?['required'] == 'true',
      defaultValue: json['defaultValue'],
      raw: rawCopy,
    );
  }

  Map<String, dynamic> toJson() => raw;

  /// Conditional logic configuration for this component.
  ///
  /// Example:
  /// {
  ///   "show": "true",
  ///   "when": "otherFieldKey",
  ///   "eq": "yes"
  /// }
  Map<String, dynamic>? get conditional {
    final rawValue = raw['conditional'];
    if (rawValue is Map<String, dynamic>) {
      return rawValue;
    }
    return null;
  }

  /// Normalized conditional.show as bool
  bool get shouldShowConditionally {
    final show = conditional?['show'];
    return show == true || show == 'true';
  }

  String? get conditionalField => conditional?['when']?.toString();

  dynamic get conditionalValue => conditional?['eq'];
}
