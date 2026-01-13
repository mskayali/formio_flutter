/// A Flutter widget that renders a date and/or time picker based on a Form.io "datetime" component.
///
/// Supports label, placeholder, required validation, default value, and configuration for date, time, or both.
library;

import 'package:flutter/material.dart';
import 'package:formio/formio.dart';
import 'package:intl/intl.dart';

class DateTimeComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current selected ISO-8601 DateTime string.
  final String? value;

  /// Callback triggered when the user selects a new date/time.
  final ValueChanged<String?> onChanged;

  /// Optional custom date picker callback
  final DatePickerCallback? onDatePick;

  /// Optional custom time picker callback
  final TimePickerCallback? onTimePick;

  const DateTimeComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.onDatePick,
    this.onTimePick,
  });

  @override
  State<DateTimeComponent> createState() => _DateTimeComponentState();
}

class _DateTimeComponentState extends State<DateTimeComponent> {
  late TextEditingController _controller;

  /// Whether the field is marked as required.
  bool get _isRequired => widget.component.required;

  /// Placeholder text for the input field.
  String? get _placeholder => widget.component.raw['placeholder'];

  /// Determines if the picker should include time selection.
  bool get _enableTime => widget.component.raw['enableTime'] ?? false;

  /// Determines if the picker should include date selection.
  bool get _enableDate => widget.component.raw['enableDate'] ?? true;

  /// The display format for the date/time.
  // String get _format => widget.component.raw['format'] ?? 'yyyy-MM-dd';

  @override
  void initState() {
    super.initState();
    final initialDateTime = widget.value != null ? DateTime.tryParse(widget.value!) : null;
    _controller = TextEditingController(text: initialDateTime != null ? _formatDateTime(initialDateTime) : '');
  }

  @override
  void didUpdateWidget(covariant DateTimeComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      final currentDateTime = widget.value != null ? DateTime.tryParse(widget.value!) : null;
      _controller.text = currentDateTime != null ? _formatDateTime(currentDateTime) : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Formats the DateTime object into a string based on the specified format.
  String _formatDateTime(DateTime dateTime) {
    if (_enableDate && _enableTime) {
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } else if (_enableTime) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  /// Parses a string into a DateTime object.
  // DateTime? _parseDateTime(String input) {
  //   try {
  //     return DateTime.parse(input);
  //   } catch (_) {
  //     return null;
  //   }
  // }

  /// Validates the input based on requirement.
  String? _validator(String? input) {
    if (_isRequired && (input == null || input.isEmpty)) {
      return ComponentFactory.locale.getRequiredMessage(widget.component.label);
    }
    return null;
  }

  /// Handles the date/time picker dialog.
  Future<void> _handlePick() async {
    DateTime? selectedDate = (widget.value != null ? DateTime.tryParse(widget.value!) : null) ?? DateTime.now();

    if (_enableDate) {
      DateTime? date;
      if (widget.onDatePick != null) {
        date = await widget.onDatePick!(
          initialDate: selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
      } else {
        date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
      }
      if (date != null) {
        selectedDate = DateTime(date.year, date.month, date.day, selectedDate.hour, selectedDate.minute);
      } else {
        return;
      }
    }

    if (!mounted) return;

    if (_enableTime) {
      TimeOfDay? time;
      if (widget.onTimePick != null) {
        time = await widget.onTimePick!(
          initialTime: TimeOfDay.fromDateTime(selectedDate),
        );
      } else {
        time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDate),
        );
      }
      if (!mounted) return;
      if (time != null) {
        selectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, time.hour, time.minute);
      } else {
        return;
      }
    }

    widget.onChanged(selectedDate.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.component.label,
        hintText: _placeholder,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: _validator,
      onTap: _handlePick,
    );
  }
}
