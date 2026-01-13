/// A Flutter widget that renders a group of radio buttons based on a
/// Form.io "radio" component.
///
/// Displays a vertical list of options, supports default value,
/// required validation, and value change handling.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';

class RadioComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The currently selected value.
  final dynamic value;

  /// Callback triggered when the user selects a new option.
  final ValueChanged<dynamic> onChanged;

  const RadioComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
  });

  /// Whether the field is marked as required.
  bool get _isRequired => component.required;

  /// List of values the user can select from.
  List<Map<String, dynamic>> get _values => List<Map<String, dynamic>>.from(component.raw['values'] ?? []);

  /// Validates selection based on requirement.
  String? _validator() {
    if (_isRequired && (value == null || value.toString().isEmpty)) {
      return '${component.label} is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final error = _validator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(component.label, style: Theme.of(context).textTheme.labelSmall),
        ..._values.map((option) {
          final optionLabel = option['label'] ?? '';
          final optionValue = option['value'];

          return RadioGroup(
            groupValue: value,
            onChanged: (value) {
              onChanged(value);
            },
            child: RadioListTile(
              key: ValueKey('${component.key}_$optionValue'), // Ensure rebuild
              value: optionValue,
              title: Text(optionLabel.toString()),
              contentPadding: EdgeInsets.zero,
            ),
          );
        }),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
