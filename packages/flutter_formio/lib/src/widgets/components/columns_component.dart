/// A Flutter widget that renders horizontally aligned columns based on
/// a Form.io "columns" layout component.
///
/// Each column can contain multiple child components. This is used
/// for creating side-by-side form layouts in a responsive row.
library;

import 'package:flutter/material.dart';
import 'package:formio/formio.dart';

import '../form_data_provider.dart';

class ColumnsComponent extends StatefulWidget {
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

  @override
  State<ColumnsComponent> createState() => _ColumnsComponentState();
}

class _ColumnsComponentState extends State<ColumnsComponent> {
  /// Parses the column layout structure from the raw JSON.
  List<List<ComponentModel>> get _columns {
    final cols = widget.component.raw['columns'] as List<dynamic>? ?? [];
    return cols.map((col) {
      final comps = col['components'] as List<dynamic>? ?? [];
      return comps.map((c) => ComponentModel.fromJson(c)).toList();
    }).toList();
  }

  /// Updates a nested component's value using its key.
  void _updateField(String key, dynamic newValue) {
    final updated = Map<String, dynamic>.from(widget.value);
    updated[key] = newValue;
    // This will cause FormRenderer to rebuild with new formData,
    // which will then update the FormDataProvider
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final columns = _columns;
    
    // Get formData from FormDataProvider - this causes rebuild when formData changes!
    final formData = FormDataProvider.of(context);
    
    // Merge widget.value and formData for complete form context
    final completeFormData = {...formData, ...widget.value};

    // print('🔍 ColumnsComponent rebuilding with formData: $completeFormData');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns.map((colComponents) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: colComponents
                  .where((comp) {
                    // Check if component should be shown based on conditional logic
                    final conditional = comp.raw['conditional'] as Map<String, dynamic>?;
                    final shouldShow = ConditionalEvaluator.shouldShow(conditional, completeFormData);
                    
                    // Debug output
                    if (conditional != null) {
                      // print('🔍 Column component "${comp.key}" conditional check:');
                      // print('   Conditional: $conditional');
                      // print('   FormData: $completeFormData');
                      // print('   Should show: $shouldShow');
                    }
                    
                    return shouldShow;
                  })
                  .map(
                    (comp) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ComponentFactory.build(
                        component: comp,
                        value: widget.value[comp.key],
                        onChanged: (val) => _updateField(comp.key, val),
                        formData: completeFormData,
                        onFilePick: widget.onFilePick,
                        onDatePick: widget.onDatePick,
                        onTimePick: widget.onTimePick,
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
