/// A Flutter widget that renders a phone number input field based on
/// a Form.io "phoneNumber" component.
///
/// Supports label, placeholder, required validation, default value,
/// and numeric keyboard input.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';

class PhoneNumberComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current phone number value.
  final String? value;

  /// Callback triggered when the phone number is updated.
  final ValueChanged<String> onChanged;

  const PhoneNumberComponent({super.key, required this.component, required this.value, required this.onChanged});

  /// Whether the field is marked as required.
  bool get _isRequired => component.required;

  /// Optional placeholder for the input field.
  String? get _placeholder => component.raw['placeholder'];

  /// Regular expression for basic phone number format validation.
  static final _phoneRegex = RegExp(r'^[\d\-\+\s\(\)]+$');

  /// Validates presence and basic format.
  String? _validator(String? input) {
    final text = (input ?? '').trim();

    if (_isRequired && text.isEmpty) {
      return '${component.label} is required.';
    }

    if (text.isNotEmpty && !_phoneRegex.hasMatch(text)) {
      return 'Please enter a valid phone number.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value ?? component.defaultValue?.toString(),
      decoration: InputDecoration(labelText: component.label, hintText: _placeholder ?? '+1 (555) 123-4567'),
      keyboardType: TextInputType.phone,
      onChanged: onChanged,
      validator: _validator,
    );
  }
}
