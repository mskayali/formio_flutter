/// A Flutter widget that renders a survey matrix based on a Form.io "survey" component.
///
/// Each row represents a question and each column is a selectable rating option.
/// Internally stores the selected values in a map of { questionValue: selectedOption }.
library;

import 'package:flutter/material.dart';
import 'package:formio_api/formio_api.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SurveyComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current selected values per row, in the form:
  /// { "question1": "answerA", "question2": "answerB" }
  final Map<String, String> value;

  /// Callback triggered when a survey row is answered.
  final ValueChanged<Map<String, String>> onChanged;

  const SurveyComponent({super.key, required this.component, required this.value, required this.onChanged});

  @override
  State<SurveyComponent> createState() => _SurveyComponentState();
}

class _SurveyComponentState extends State<SurveyComponent> {
  late ScrollController _headerScrollController;
  late ScrollController _contentScrollController;

  @override
  void initState() {
    super.initState();
    _headerScrollController = ScrollController();
    _contentScrollController = ScrollController();

    // Synchronize header scroll with content
    _headerScrollController.addListener(() {
      if (_contentScrollController.hasClients && _contentScrollController.offset != _headerScrollController.offset) {
        _contentScrollController.jumpTo(_headerScrollController.offset);
      }
    });

    // Synchronize content scroll with header
    _contentScrollController.addListener(() {
      if (_headerScrollController.hasClients && _headerScrollController.offset != _contentScrollController.offset) {
        _headerScrollController.jumpTo(_contentScrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  /// Whether at least one answer is required.
  bool get _isRequired => widget.component.required;

  /// The list of rows/questions in the survey.
  List<Map<String, dynamic>> get _rows => List<Map<String, dynamic>>.from(widget.component.raw['questions'] ?? []);

  /// The list of answer options (columns).
  List<Map<String, dynamic>> get _columns => List<Map<String, dynamic>>.from(widget.component.raw['values'] ?? []);

  /// Returns the current selected value for a given row/question.
  String? _selectedFor(String rowKey) => widget.value[rowKey];

  /// Validates if all required questions are answered.
  String? _validator() {
    if (_isRequired) {
      final answered = widget.value.entries.where((e) => e.value.isNotEmpty).length;
      if (answered < _rows.length) {
        return 'Please complete all survey questions.';
      }
    }
    return null;
  }

  /// Updates the answer for a given question.
  void _update(String questionKey, String answerValue) {
    final updated = Map<String, String>.from(widget.value);
    updated[questionKey] = answerValue;
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final error = _validator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.component.label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),

        // StickyHeader with synchronized horizontal scrolling
        StickyHeader(
          header: Container(
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
              controller: _headerScrollController,
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Row(
                  children: [
                    // Empty cell for question column
                    Container(
                      width: 200,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                      child: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    // Header cells for each option
                    ..._columns.map((col) => Container(
                          width: 80,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                          ),
                          child: Text(
                            col['label'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
          content: SingleChildScrollView(
            controller: _contentScrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Theme.of(context).colorScheme.outline),
                  right: BorderSide(color: Theme.of(context).colorScheme.outline),
                  bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              child: Column(
                children: _rows.map((row) {
                  final rowKey = row['value'] ?? '';
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Question cell
                        Container(
                          width: 200,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                          ),
                          child: Text(
                            row['label'] ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        // Radio cells for each option
                        ..._columns.map((col) {
                          final colValue = col['value']?.toString() ?? '';
                          return Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Theme.of(context).colorScheme.outline),
                              ),
                            ),
                            child: Center(
                              child: RadioGroup<String>(
                                groupValue: _selectedFor(rowKey),
                                onChanged: (value) {
                                  if (value != null) _update(rowKey, value);
                                },
                                child: Radio<String>(
                                  value: colValue,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              error,
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
