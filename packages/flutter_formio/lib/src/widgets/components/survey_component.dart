/// A Flutter widget that renders a survey matrix based on a Form.io "survey" component.
///
/// Each row represents a question and each column is a selectable rating option.
/// Internally stores the selected values in a map of { questionValue: selectedOption }.
library;

import 'package:flutter/material.dart';
import 'package:formio_api/formio_api.dart';

class SurveyComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current selected values per row, in the form:
  /// { "question1": "answerA", "question2": "answerB" }
  final Map<String, String> value;

  /// Callback triggered when a survey row is answered.
  final ValueChanged<Map<String, String>> onChanged;

  const SurveyComponent({super.key, required this.component, required this.value, required this.onChanged});

  /// Whether at least one answer is required.
  bool get _isRequired => component.required;

  /// The list of rows/questions in the survey.
  List<Map<String, dynamic>> get _rows => List<Map<String, dynamic>>.from(component.raw['questions'] ?? []);

  /// The list of answer options (columns).
  List<Map<String, dynamic>> get _columns => List<Map<String, dynamic>>.from(component.raw['values'] ?? []);

  /// Returns the current selected value for a given row/question.
  String? _selectedFor(String rowKey) => value[rowKey];

  /// Validates if all required questions are answered.
  String? _validator() {
    if (_isRequired) {
      final answered = value.entries.where((e) => e.value.isNotEmpty).length;
      if (answered < _rows.length) {
        return 'Please complete all survey questions.';
      }
    }
    return null;
  }

  /// Updates the answer for a given question.
  void _update(String questionKey, String answerValue) {
    final updated = Map<String, String>.from(value);
    updated[questionKey] = answerValue;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final error = _validator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(component.label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {0: FlexColumnWidth(2)},
          border: TableBorder.all(color: Theme.of(context).colorScheme.outline),
          children: [
            // Header Row
            TableRow(
              children: [
                const Padding(padding: EdgeInsets.all(8.0), child: Text('')),
                ..._columns.map((col) => Padding(padding: const EdgeInsets.all(8.0), child: Text(col['label'] ?? '', textAlign: TextAlign.center))),
              ],
            ),
            // Question Rows
            ..._rows.map((row) {
              final rowKey = row['value'] ?? '';
              return TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: Text(row['label'] ?? '')),
                  ..._columns.map((col) {
                    final colValue = col['value']?.toString() ?? '';
                    return RadioGroup<String>(
                      groupValue: _selectedFor(rowKey),
                      onChanged: (value) {
                        if (value != null) _update(rowKey, value);
                      },
                      child: Radio<String>(
                        value: colValue,
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
        if (error != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12))),
      ],
    );
  }
}
