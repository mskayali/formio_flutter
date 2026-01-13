/// A Flutter widget that renders multiple checkboxes based on a
/// Form.io "selectboxes" component.
///
/// Each checkbox represents a boolean value for a labeled option.
/// The result is stored as a map of `{ optionKey: true/false }`.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';

class SelectBoxesComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current selection state as a map of { key: bool }.
  final Map<String, bool> value;

  /// Callback triggered when any option is toggled.
  final ValueChanged<Map<String, bool>> onChanged;

  const SelectBoxesComponent({super.key, required this.component, required this.value, required this.onChanged});

  /// Whether the component is required (at least one must be selected).
  bool get _isRequired => component.required;

  /// List of available checkbox options.
  List<Map<String, dynamic>> get _values => List<Map<String, dynamic>>.from(component.raw['values'] ?? []);

  /// Returns validation error message if needed.
  String? _validator() {
    if (_isRequired) {
      final hasAnyChecked = value.values.any((v) => v == true);
      if (!hasAnyChecked) {
        return '${component.label} is required.';
      }
    }
    return null;
  }

  /// Updates the selected checkbox state.
  void _toggle(String key, bool isChecked) {
    final newState = Map<String, bool>.from(value);
    newState[key] = isChecked;
    onChanged(newState);
  }

  @override
  Widget build(BuildContext context) {
    final error = _validator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(component.label, style: Theme.of(context).textTheme.labelSmall),
        ..._values.map((option) {
          final key = option['value']?.toString() ?? '';
          final label = option['label']?.toString() ?? '';
          final checked = value[key] ?? false;

          return CheckboxListTile(
            value: checked,
            title: Text(label),
            onChanged: (val) {
              if (val != null) {
                _toggle(key, val);
              }
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}
