/// A Flutter widget that renders a text field based on a Form.io "textfield" component.
///
/// Supports placeholder, label, default value, and comprehensive validation including
/// required, pattern, minLength, maxLength, minWords, maxWords.

import 'package:flutter/material.dart';

import '../../core/validators.dart';
import '../../models/component.dart';

class TextFieldComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the field.
  final String? value;

  /// Callback called when the user changes the input value.
  final ValueChanged<String> onChanged;

  const TextFieldComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  /// Retrieves a placeholder value if available in the raw JSON.
  String? get _placeholder => component.raw['placeholder'];

  /// Gets validation config from component.
  Map<String, dynamic>? get _validateConfig => component.raw['validate'];

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(component.key),
      initialValue: value ?? component.defaultValue?.toString(),
      decoration: InputDecoration(
        labelText: component.label,
        hintText: _placeholder,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: FormioValidators.fromConfig(_validateConfig, component.label),
    );
  }
}
