/// A Flutter widget that renders horizontally aligned columns based on
/// a Form.io "columns" layout component.
///
/// Each column can contain multiple child components. This is used
/// for creating side-by-side form layouts in a responsive row.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../../models/file_typedefs.dart';
import '../component_factory.dart';

class ColumnsComponent extends StatelessWidget {
  /// The Form.io "columns" component definition.
  final ComponentModel component;

  /// Current value map that contains values of all nested components.
  final Map<String, dynamic> value;

  /// Complete form data for interpolation and logic
  final Map<String, dynamic>? formData;

  /// Callbacks
  final FilePickerCallback? onFilePick;

  final DatePickerCallback? onDatePick;
  final TimePickerCallback? onTimePick;

  /// Callback triggered when any nested component in any column updates its value.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ColumnsComponent({
    super.key,
    required this.component,
    required this.value,
    this.formData,
    this.onFilePick,
    this.onDatePick,
    this.onTimePick,
    required this.onChanged,
  });

  /// Parses the column layout structure from the raw JSON.
  List<List<ComponentModel>> get _columns {
    final cols = component.raw['columns'] as List<dynamic>? ?? [];
    return cols.map((col) {
      final comps = col['components'] as List<dynamic>? ?? [];
      return comps.map((c) => ComponentModel.fromJson(c)).toList();
    }).toList();
  }

  /// Updates a nested component's value using its key.
  void _updateField(String key, dynamic newValue) {
    final updated = Map<String, dynamic>.from(value);
    updated[key] = newValue;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final columns = _columns;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns.map((colComponents) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: colComponents
                  .map(
                    (comp) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ComponentFactory.build(
                        component: comp,
                        value: value[comp.key],
                        onChanged: (val) => _updateField(comp.key, val),
                        formData: formData,
                        onFilePick: onFilePick,
                        onDatePick: onDatePick,
                        onTimePick: onTimePick,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
