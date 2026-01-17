/// A Flutter widget that renders a titled container panel based on a
/// Form.io "panel" component.
///
/// Used to visually group related form fields under a common section with
/// an optional title and collapsible behavior (if configured).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:formio/formio.dart';

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

  /// Check if a child component should be shown based on its conditional logic.
  bool _shouldShowChild(ComponentModel child) {
    final conditional = child.conditional;
    // Merge global formData with panel's local value
    // This allows conditionals to reference sibling components within the panel
    final mergedData = <String, dynamic>{
      ...?formData,
      ...value, // Panel's children values are stored here
    };

    return ConditionalEvaluator.shouldShow(conditional, mergedData);
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
          children: _children.where(_shouldShowChild).map((child) {
            // Layout components (panel, columns, well, fieldset, table, tabs) are containers
            // that don't have their own value. They need the full formData (our 'value' param)
            // so their children can look up their values correctly.
            const layoutComponentTypes = ['panel', 'columns', 'well', 'fieldset', 'table', 'tabs'];
            final isLayoutComponent = layoutComponentTypes.contains(child.type);

            final childValue = isLayoutComponent ? value : value[child.key];

            if (kDebugMode) {
              print('  📦 Panel child "${child.key}" (${child.type}) receiving value: ${isLayoutComponent ? "{...formData...}" : childValue}');
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ComponentFactory.build(
                component: child,
                value: childValue,
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
