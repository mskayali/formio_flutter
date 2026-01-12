/// A Flutter widget that renders a multi-line text area based on a Form.io "textarea" component.
///
/// Supports placeholder, label, default value, rows configuration, and comprehensive validation.

import 'package:flutter/material.dart';

import '../../core/validators.dart';
import '../../models/component.dart';

class TextAreaComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the text area.
  final String? value;

  /// Callback called when the user modifies the text.
  final ValueChanged<String> onChanged;

  const TextAreaComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  /// Retrieves the placeholder text.
  String? get _placeholder => component.raw['placeholder'];

  /// Retrieves the number of rows for the text area.
  int get _rows => component.raw['rows'] is int ? component.raw['rows'] : 3;

  /// Gets validation config from component.
  Map<String, dynamic>? get _validateConfig => component.raw['validate'];

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(component.key),
      initialValue: value ?? component.defaultValue?.toString(),
      maxLines: _rows,
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
