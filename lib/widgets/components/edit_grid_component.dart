/// A Flutter widget that renders a repeatable grid of form entries
/// based on a Form.io "editgrid" component.
///
/// Each row opens as a full form (not inline) and can contain multiple
/// child components. Ideal for collecting structured, nested data.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../../models/file_typedefs.dart';
import '../component_factory.dart';

class EditGridComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// List of form rows; each row is a Map of values for its components.
  final List<Map<String, dynamic>> value;

  /// Complete form data for interpolation and logic
  final Map<String, dynamic>? formData;

  /// Callbacks
  final FilePickerCallback? onFilePick;

  final DatePickerCallback? onDatePick;
  final TimePickerCallback? onTimePick;

  /// Callback triggered when the edit grid changes.
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  const EditGridComponent({
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
  State<EditGridComponent> createState() => _EditGridComponentState();
}

class _EditGridComponentState extends State<EditGridComponent> {
  late List<Map<String, dynamic>> _rows;

  List<ComponentModel> get _childComponents {
    final components = widget.component.raw['components'] ?? [];
    return (components as List).map((c) => ComponentModel.fromJson(c)).toList();
  }

  bool get _isRequired => widget.component.required;

  @override
  void initState() {
    super.initState();
    _rows = List<Map<String, dynamic>>.from(widget.value);
  }

  void _addRow() {
    final newRow = <String, dynamic>{};
    for (var comp in _childComponents) {
      newRow[comp.key] = null;
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

  void _updateField(int rowIndex, String key, dynamic value) {
    setState(() {
      _rows[rowIndex][key] = value;
    });
    widget.onChanged(_rows);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _isRequired && _rows.isEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    if (_childComponents.isEmpty) return const SizedBox.shrink();

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
                    ..._childComponents.map(
                      (comp) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          comp.label,
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
                      ..._childComponents.map(
                        (comp) => Container(
                          constraints: const BoxConstraints(minWidth: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: ComponentFactory.build(
                            component: comp,
                            value: row[comp.key],
                            onChanged: (val) => _updateField(rowIndex, comp.key, val),
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
          label: Text(ComponentFactory.locale.addEntry),
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
