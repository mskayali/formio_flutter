/// A Flutter widget that renders an email input based on a Form.io "email" component.
///
/// Validates email format and supports label, placeholder, required constraint,
/// and a default value.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';

class EmailComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current email value.
  final String? value;

  /// Callback triggered when the email is updated.
  final ValueChanged<String> onChanged;

  const EmailComponent({super.key, required this.component, required this.value, required this.onChanged});

  /// Whether the field is marked as required.
  bool get _isRequired => component.required;

  /// Placeholder hint for the input.
  String? get _placeholder => component.raw['placeholder'];

  /// Regular expression for basic email validation.
  static final _emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

  /// Validates required and format constraints.
  String? _validator(String? input) {
    final text = (input ?? '').trim();

    if (_isRequired && text.isEmpty) {
      return '${component.label} is required.';
    }

    if (text.isNotEmpty && !_emailRegex.hasMatch(text)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value ?? component.defaultValue?.toString(),
      decoration: InputDecoration(labelText: component.label, hintText: _placeholder ?? 'example@example.com'),
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      validator: _validator,
    );
  }
}
