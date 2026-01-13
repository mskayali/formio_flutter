/// A Flutter widget that renders a Dynamic Wizard component.
///
/// Collects array of object values through a step-by-step wizard interface.
/// - Each field is a separate step
/// - Progress through fields sequentially
/// - Completed data shown in table view
/// - Add/remove array entries
library;

import 'package:flutter/material.dart';
import 'package:formio/formio.dart';


class DynamicWizardComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Array of collected values.
  final List<Map<String, dynamic>>? value;

  /// Complete form data for interpolation and logic
  final Map<String, dynamic>? formData;

  /// Callbacks
  final FilePickerCallback? onFilePick;

  final DatePickerCallback? onDatePick;
  final TimePickerCallback? onTimePick;

  /// Callback when values change.
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  const DynamicWizardComponent({
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
  State<DynamicWizardComponent> createState() => _DynamicWizardComponentState();
}

class _DynamicWizardComponentState extends State<DynamicWizardComponent> {
  late List<Map<String, dynamic>> _entries;
  Map<String, dynamic> _currentEntry = {};
  int _currentStep = 0;
  bool _isAddingEntry = false;

  @override
  void initState() {
    super.initState();
    _entries = List.from(widget.value ?? []);
  }

  List<ComponentModel> get _wizardSteps {
    final components = widget.component.raw['components'] as List?;
    if (components == null) return [];
    return components.map((c) => ComponentModel.fromJson(c as Map<String, dynamic>)).toList();
  }

  void _startAddEntry() {
    setState(() {
      _isAddingEntry = true;
      _currentStep = 0;
      _currentEntry = {};
    });
  }

  void _nextStep() {
    if (_currentStep < _wizardSteps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _completeEntry();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _completeEntry() {
    setState(() {
      _entries.add(Map.from(_currentEntry));
      _isAddingEntry = false;
      _currentEntry = {};
      _currentStep = 0;
    });
    widget.onChanged(_entries);
  }

  void _cancelEntry() {
    setState(() {
      _isAddingEntry = false;
      _currentEntry = {};
      _currentStep = 0;
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
    widget.onChanged(_entries);
  }

  @override
  Widget build(BuildContext context) {
    if (_wizardSteps.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No wizard steps configured'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.component.label.isNotEmpty)
          Text(
            widget.component.label,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        const SizedBox(height: 16),

        // Wizard interface (when adding entry)
        if (_isAddingEntry) ...[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  Row(
                    children: List.generate(_wizardSteps.length, (index) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _currentStep ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Step info
                  Text(
                    'Step ${_currentStep + 1} of ${_wizardSteps.length}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 16),

                  // Current step component
                  ComponentFactory.build(
                    component: _wizardSteps[_currentStep],
                    value: _currentEntry[_wizardSteps[_currentStep].key],
                    onChanged: (value) {
                      setState(() {
                        _currentEntry[_wizardSteps[_currentStep].key] = value;
                      });
                    },
                    formData: widget.formData,
                    onFilePick: widget.onFilePick,
                    onDatePick: widget.onDatePick,
                    onTimePick: widget.onTimePick,
                  ),
                  const SizedBox(height: 16),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _cancelEntry,
                        child: Text(ComponentFactory.locale.cancel),
                      ),
                      Row(
                        children: [
                          if (_currentStep > 0)
                            TextButton.icon(
                              onPressed: _previousStep,
                              icon: const Icon(Icons.arrow_back),
                              label: Text(ComponentFactory.locale.previous),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _nextStep,
                            icon: Icon(_currentStep < _wizardSteps.length - 1 ? Icons.arrow_forward : Icons.check),
                            label: Text(_currentStep < _wizardSteps.length - 1 ? ComponentFactory.locale.next : ComponentFactory.locale.complete),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],

        // Table view of completed entries
        if (!_isAddingEntry) ...[
          if (_entries.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    ComponentFactory.locale.noEntriesAdded,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
              ),
            )
          else
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: _wizardSteps.map((comp) {
                    return DataColumn(
                      label: Text(
                        comp.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList()
                    ..add(const DataColumn(label: Text('Actions'))),
                  rows: _entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final row = entry.value;
                    return DataRow(
                      cells: [
                        ..._wizardSteps.map((comp) {
                          final value = row[comp.key];
                          return DataCell(Text(value?.toString() ?? ''));
                        }),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _removeEntry(index),
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Add entry button
          ElevatedButton.icon(
            onPressed: _startAddEntry,
            icon: const Icon(Icons.add),
            label: Text(ComponentFactory.locale.addEntry),
          ),
        ],
      ],
    );
  }
}
