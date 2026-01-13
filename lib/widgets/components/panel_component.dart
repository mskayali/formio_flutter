/// A Flutter widget that renders a titled container panel based on a
/// Form.io "panel" component.
///
/// Used to visually group related form fields under a common section with
/// an optional title and collapsible behavior (if configured).
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../../models/file_typedefs.dart';
import '../component_factory.dart';

class PanelComponent extends StatelessWidget {
  /// The Form.io panel definition.
  final ComponentModel component;

  /// Nested values passed into the panel's child components.
  final Map<String, dynamic> value;

  /// Complete form data for interpolation and logic
  final Map<String, dynamic>? formData;

  /// Callbacks
  final FilePickerCallback? onFilePick;

  final DatePickerCallback? onDatePick;
  final TimePickerCallback? onTimePick;

  /// Callback triggered when any child component inside the panel changes.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const PanelComponent({
    super.key,
    required this.component,
    required this.value,
    this.formData,
    this.onFilePick,
    this.onDatePick,
    this.onTimePick,
    required this.onChanged,
  });

  /// List of components inside the panel.
  List<ComponentModel> get _children {
    final components = component.raw['components'] as List? ?? [];
    return components.map((c) => ComponentModel.fromJson(c)).toList();
  }

  void _updateField(String key, dynamic val) {
    final updated = Map<String, dynamic>.from(value);
    updated[key] = val;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _children.where((child) {
            // Optional pre-check for conditional inside child
            final condition = child.conditional;
            if (condition == null || condition['when'] == null) return true;

            final controllingKey = condition['when'];
            final expectedValue = condition['eq'];
            final actualValue = value[controllingKey];

            final matches = actualValue?.toString() == expectedValue?.toString();
            final shouldShow = condition['show'] == 'true' ? matches : !matches;

            return shouldShow;
          }).map((child) {
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
      ),
    );
  }
}
