/// A Flutter widget that renders a grid-style layout of form components
/// based on a Form.io "table" component.
///
/// Each cell can contain zero or more form components. This layout
/// is ideal for creating structured forms with rows and columns.
library;

import 'package:flutter/material.dart';
import 'package:formio/formio.dart';


class TableComponent extends StatelessWidget {
  /// The Form.io table component definition.
  final ComponentModel component;

  /// Current value map of all child components.
  final Map<String, dynamic> value;

  /// Complete form data for interpolation and logic
  final Map<String, dynamic>? formData;

  /// Callbacks
  final FilePickerCallback? onFilePick;

  final DatePickerCallback? onDatePick;
  final TimePickerCallback? onTimePick;

  /// Callback triggered when any child component's value changes.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const TableComponent({
    super.key,
    required this.component,
    required this.value,
    this.formData,
    this.onFilePick,
    this.onDatePick,
    this.onTimePick,
    required this.onChanged,
  });

  /// Returns a list of rows, where each row is a list of components.
  // List<List<ComponentModel>> get _rows {
  //   final rows = component.raw['rows'] as List? ?? [];

  //   return rows.map<List<ComponentModel>>((row) {
  //     final cells = row as List;
  //     return cells.expand<ComponentModel>((cell) {
  //       final components = cell['components'] as List? ?? [];
  //       return components.map((c) => ComponentModel.fromJson(c));
  //     }).toList();
  //   }).toList();
  // }

  /// Helper to build a single cell's widget content.
  Widget _buildCell(ComponentModel component) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ComponentFactory.build(
        component: component,
        value: value[component.key],
        onChanged: (val) {
          final updated = Map<String, dynamic>.from(value);
          updated[component.key] = val;
          onChanged(updated);
        },
        formData: formData,
        onFilePick: onFilePick,
        onDatePick: onDatePick,
        onTimePick: onTimePick,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tableRows = component.raw['rows'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (component.label.isNotEmpty) Text(component.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Theme.of(context).colorScheme.outline),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: tableRows.map<TableRow>((row) {
            final rowCells = row as List<dynamic>;
            return TableRow(
              children: rowCells.map((cell) {
                final components = cell['components'] as List? ?? [];
                if (components.isEmpty) {
                  return const SizedBox(height: 48); // empty cell
                }
                return Column(children: components.map<ComponentModel>((json) => ComponentModel.fromJson(json)).map(_buildCell).toList());
              }).toList(),
            );
          }).toList(),
        ),
      ],
    );
  }
}
