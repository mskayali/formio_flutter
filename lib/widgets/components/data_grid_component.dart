/// A Flutter widget that renders a repeatable table of input rows
/// based on a Form.io "datagrid" component.
///
/// Each row consists of multiple child components (columns),
/// and users can add or remove rows dynamically. The output is
/// a List<Map<String, dynamic>>.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../../models/file_typedefs.dart';
import '../component_factory.dart';

class DataGridComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Current list of row values (each row is a Map of component values).
  final List<Map<String, dynamic>> value;

  /// Complete form data for interpolation and logic
  final Map<String, dynamic>? formData;

  /// Callbacks
  final FilePickerCallback? onFilePick;

  final DatePickerCallback? onDatePick;
  final TimePickerCallback? onTimePick;

  /// Callback triggered when the grid content changes.
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  const DataGridComponent({
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
  State<DataGridComponent> createState() => _DataGridComponentState();
}

class _DataGridComponentState extends State<DataGridComponent> {
  late List<Map<String, dynamic>> _rows;

  List<ComponentModel> get _columns {
    final rawCols = widget.component.raw['components'] as List? ?? [];
    return rawCols.map((c) => ComponentModel.fromJson(c)).toList();
  }

  bool get _isRequired => widget.component.required;

  @override
  void initState() {
    super.initState();
    _rows = List<Map<String, dynamic>>.from(widget.value);
    if (_rows.isEmpty) {
      // Add initial row without triggering onChanged during build
      final newRow = <String, dynamic>{};
      for (var col in _columns) {
        newRow[col.key] = null;
      }
      _rows.add(newRow);

      // Defer onChanged callback until after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(_rows);
      });
    }
  }

  void _addRow() {
    final newRow = <String, dynamic>{};
    for (var col in _columns) {
      newRow[col.key] = null;
    }
    setState(() {
      _rows.add(newRow);
    });
    widget.onChanged(_rows);
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index);
    });
    widget.onChanged(_rows);
  }

  void _updateCell(int rowIndex, String key, dynamic value) {
    setState(() {
      _rows[rowIndex][key] = value;
    });
    widget.onChanged(_rows);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _isRequired && _rows.isEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    if (_columns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.component.label.isNotEmpty) ...[
          Text(widget.component.label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  ),
                  children: [
                    ..._columns.map(
                      (col) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          col.label,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 50), // Actions column header
                  ],
                ),
                // Data Rows
                ..._rows.asMap().entries.map((entry) {
                  final rowIndex = entry.key;
                  final row = entry.value;
                  return TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                      ),
                    ),
                    children: [
                      ..._columns.map(
                        (col) => Container(
                          constraints: const BoxConstraints(minWidth: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: ComponentFactory.build(
                            component: col,
                            value: row[col.key],
                            onChanged: (val) => _updateCell(rowIndex, col.key, val),
                            formData: widget.formData,
                            onFilePick: widget.onFilePick,
                            onDatePick: widget.onDatePick,
                            onTimePick: widget.onTimePick,
                          ),
                        ),
                      ),
                      // Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: IconButton(
                          onPressed: () => _removeRow(rowIndex),
                          icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                          tooltip: ComponentFactory.locale.removeRow,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add, size: 20),
          label: Text(ComponentFactory.locale.addAnother),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              ComponentFactory.locale.getRequiredMessage(widget.component.label),
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
