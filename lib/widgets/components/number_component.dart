/// A Flutter widget that renders a number input based on a Form.io "number" component.
///
/// Supports label, placeholder, default value, required validation,
/// and basic numeric constraints (min, max).
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';

class NumberComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current numeric value entered by the user.
  final num? value;

  /// Callback called when the user updates the number.
  final ValueChanged<num?> onChanged;

  const NumberComponent({super.key, required this.component, required this.value, required this.onChanged});

  /// Returns true if the field is marked as required.
  bool get _isRequired => component.required;

  /// The minimum allowed value (if defined).
  num? get _min => component.raw['validate']?['min'];

  /// The maximum allowed value (if defined).
  num? get _max => component.raw['validate']?['max'];

  /// Returns placeholder text, if available.
  String? get _placeholder => component.raw['placeholder'];

  /// Parses a string to a numeric value, handling empty or invalid input.
  num? _parse(String input) {
    if (input.trim().isEmpty) return null;
    final parsed = num.tryParse(input);
    return parsed;
  }

  /// Validates the input against min/max and required constraints.
  String? _validator(String? input) {
    final parsed = _parse(input ?? '');

    if (_isRequired && parsed == null) {
      return '${component.label} is required.';
    }

    if (parsed != null) {
      if (_min != null && parsed < _min!) {
        return '${component.label} must be at least $_min.';
      }
      if (_max != null && parsed > _max!) {
        return '${component.label} must be at most $_max.';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? component.defaultValue?.toString(),
      decoration: InputDecoration(labelText: component.label, hintText: _placeholder),
      keyboardType: TextInputType.number,
      onChanged: (input) => onChanged(_parse(input)),
      validator: _validator,
    );
  }
}
