/// A Flutter widget that renders horizontally aligned columns based on
/// a Form.io "columns" layout component.
///
/// Each column can contain multiple child components. This is used
/// for creating side-by-side form layouts in a responsive row.
library;

import 'package:flutter/foundation.dart';
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
  void _updateField(String childKey, dynamic newValue) {
    // Layout components (panel, columns, etc.) return the full formData with changes merged in.
    // We should merge  their changes directly, not nest under childKey.
    // Non-layout components return their value, which should be stored under childKey.
    const layoutComponentTypes = ['panel', 'columns', 'well', 'fieldset', 'table', 'tabs'];

    // Find the child component to check its type
    final columns = widget.component.raw['columns'] as List? ?? [];
    ComponentModel? childComponent;
    for (final col in columns) {
      final components = col['components'] as List? ?? [];
      for (final comp in components) {
        if (comp['key'] == childKey) {
          childComponent = ComponentModel.fromJson(comp);
          break;
        }
      }
      if (childComponent != null) break;
    }

    final isLayoutChild = childComponent != null && layoutComponentTypes.contains(childComponent.type);

    final updated = Map<String, dynamic>.from(widget.value);

    if (isLayoutChild && newValue is Map<String, dynamic>) {
      // Merge the layout component's changes directly into our formData
      updated.addAll(newValue);
    } else {
      // Store non-layout component's value under its key
      updated[childKey] = newValue;
    }

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
              children: colComponents.where((comp) {
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
              }).map(
                (comp) {
                  // Layout components need full formData
                  const layoutComponentTypes = ['panel', 'columns', 'well', 'fieldset', 'table', 'tabs'];
                  final isLayoutComponent = layoutComponentTypes.contains(comp.type);
                  final componentValue = isLayoutComponent ? widget.value : widget.value[comp.key];

                  if (kDebugMode && isLayoutComponent) {
                    print('  📊 Column child "${comp.key}" (${comp.type}) receiving value: {...formData...}');
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ComponentFactory.build(
                      component: comp,
                      value: componentValue,
                      onChanged: (val) => _updateField(comp.key, val),
                      formData: completeFormData,
                      onFilePick: widget.onFilePick,
                      onDatePick: widget.onDatePick,
                      onTimePick: widget.onTimePick,
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
