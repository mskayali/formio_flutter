/// A Flutter widget that renders a Data Table component.
///
/// Advanced select component that displays data in table format with:
/// - Column headers from data fields
/// - Selectable rows
/// - Pagination support
/// - Multiple column display from external data
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class DataTableComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Currently selected values (list of selected row data).
  final List<Map<String, dynamic>>? value;

  /// Callback triggered when selection changes.
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  const DataTableComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
  });

  @override
  State<DataTableComponent> createState() => _DataTableComponentState();
}

class _DataTableComponentState extends State<DataTableComponent> {
  late Set<int> _selectedRows;
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _selectedRows = {};
  }

  bool get _isRequired => widget.component.required;

  // Get static data values
  List<Map<String, dynamic>> get _dataValues {
    final data = widget.component.raw['data'];
    if (data is Map && data['values'] is List) {
      return (data['values'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Get column definitions
  List<String> get _columns {
    final cols = widget.component.raw['columns'] as List?;
    if (cols != null && cols.isNotEmpty) {
      return cols.cast<String>();
    }
    // Auto-detect columns from first data row
    if (_dataValues.isNotEmpty) {
      return _dataValues.first.keys.toList();
    }
    return [];
  }

  // Get column labels
  Map<String, String> get _columnLabels {
    final labels = widget.component.raw['columnLabels'] as Map?;
    if (labels != null) {
      return labels.cast<String, String>();
    }
    return {};
  }

  String _getColumnLabel(String key) {
    return _columnLabels[key] ?? _formatKey(key);
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'([A-Z])|_([a-z])'),
          (match) => ' ${match.group(1) ?? match.group(2)!.toUpperCase()}',
        )
        .trim()
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _toggleRow(int index) {
    setState(() {
      if (_selectedRows.contains(index)) {
        _selectedRows.remove(index);
      } else {
        _selectedRows.add(index);
      }
    });
    _updateSelection();
  }

  void _updateSelection() {
    final selected = _selectedRows.map((idx) => _dataValues[idx]).toList();
    widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    if (_dataValues.isEmpty || _columns.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            ComponentFactory.locale.noDataAvailable,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ),
      );
    }

    final hasError = _isRequired && _selectedRows.isEmpty;
    final totalPages = (_dataValues.length / _rowsPerPage).ceil();
    final startIdx = _currentPage * _rowsPerPage;
    final endIdx = (startIdx + _rowsPerPage).clamp(0, _dataValues.length);
    final visibleData = _dataValues.sublist(startIdx, endIdx);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.component.label.isNotEmpty)
          Text(
            widget.component.label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        const SizedBox(height: 8),

        // Data Table
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: true,
              columns: _columns.map((col) {
                return DataColumn(
                  label: Text(
                    _getColumnLabel(col),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              rows: visibleData.asMap().entries.map((entry) {
                final actualIndex = startIdx + entry.key;
                final row = entry.value;
                return DataRow(
                  selected: _selectedRows.contains(actualIndex),
                  onSelectChanged: (_) => _toggleRow(actualIndex),
                  cells: _columns.map((col) {
                    final value = row[col];
                    return DataCell(Text(value?.toString() ?? ''));
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),

        // Pagination controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${ComponentFactory.locale.showing} ${startIdx + 1}-$endIdx ${ComponentFactory.locale.of} ${_dataValues.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Row(
              children: [
                Text('${ComponentFactory.locale.rowsPerPage}:', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  items: [5, 10, 25, 50].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _rowsPerPage = value;
                        _currentPage = 0;
                      });
                    }
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                ),
                Text('${_currentPage + 1} / $totalPages'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                ),
              ],
            ),
          ],
        ),

        // Selection info
        if (_selectedRows.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              ComponentFactory.locale.getSelectedRowsMessage(_selectedRows.length),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

        // Error
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${widget.component.label} ${ComponentFactory.locale.isRequired}.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
