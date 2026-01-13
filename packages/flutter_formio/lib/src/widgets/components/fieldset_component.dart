/// A Flutter widget that renders a group of components within a bordered fieldset
/// based on a Form.io "fieldset" component.
///
/// Displays child form fields inside a visual group with an optional legend/title.
library;

import 'package:flutter/material.dart';
import 'package:flutter_formio/flutter_formio.dart';

class FieldSetComponent extends StatelessWidget {
  /// The Form.io fieldset component.
  final ComponentModel component;

  /// Current form values inside the fieldset.
  final Map<String, dynamic> value;

  /// Complete form data for interpolation and logic
  final Map<String, dynamic>? formData;

  /// Callbacks
  final FilePickerCallback? onFilePick;

  final DatePickerCallback? onDatePick;
  final TimePickerCallback? onTimePick;

  /// Callback triggered when a nested field updates its value.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const FieldSetComponent({
    super.key,
    required this.component,
    required this.value,
    this.formData,
    this.onFilePick,
    this.onDatePick,
    this.onTimePick,
    required this.onChanged,
  });

  /// List of child components inside the fieldset.
  List<ComponentModel> get _children {
    final components = component.raw['components'] ?? [];
    return (components as List).map((c) => ComponentModel.fromJson(c)).toList();
  }

  /// Optional legend/title text for the fieldset.
  String get _legend => component.label;

  void _updateChild(String key, dynamic fieldValue) {
    final updated = Map<String, dynamic>.from(value);
    updated[key] = fieldValue;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outline), borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_legend.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_legend, style: Theme.of(context).textTheme.labelLarge)),
          ..._children.map(
            (child) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ComponentFactory.build(
                component: child,
                value: value[child.key],
                onChanged: (val) => _updateChild(child.key, val),
                formData: formData,
                onFilePick: onFilePick,
                onDatePick: onDatePick,
                onTimePick: onTimePick,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
