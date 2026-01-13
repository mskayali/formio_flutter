/// A Flutter widget that renders a visual container for grouping content
/// based on a Form.io "well" layout component.
///
/// Used to emphasize or separate form sections without borders or titles.
/// The well wraps child components in a subtle gray box.
library;

import 'package:flutter/material.dart';
import 'package:flutter_formio/flutter_formio.dart';


class WellComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Current form values of all nested fields inside the well.
  final Map<String, dynamic> value;

  /// Complete form data for interpolation and logic
  final Map<String, dynamic>? formData;

  /// Callbacks
  final FilePickerCallback? onFilePick;

  final DatePickerCallback? onDatePick;
  final TimePickerCallback? onTimePick;

  /// Callback triggered when a nested field changes.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const WellComponent({
    super.key,
    required this.component,
    required this.value,
    this.formData,
    this.onFilePick,
    this.onDatePick,
    this.onTimePick,
    required this.onChanged,
  });

  /// List of nested child components inside the well.
  List<ComponentModel> get _children {
    final comps = component.raw['components'] as List? ?? [];
    return comps.map((c) => ComponentModel.fromJson(c)).toList();
  }

  /// Updates value of a specific field inside the well.
  void _updateField(String key, dynamic val) {
    final updated = Map<String, dynamic>.from(value);
    updated[key] = val;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: _children.map((child) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ComponentFactory.build(
              component: child,
              value: value[child.key],
              onChanged: (val) => _updateField(child.key, val),
              formData: formData,
              onFilePick: onFilePick,
              onDatePick: onDatePick,
              onTimePick: onTimePick,
            ),
          );
        }).toList(),
      ),
    );
  }
}
