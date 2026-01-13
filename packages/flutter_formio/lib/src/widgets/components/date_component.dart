/// A Flutter widget that renders a date/time picker based on a Form.io "datetime" component.
///
/// Supports picking date, time, or both depending on the `enableTime` and `enableDate` flags.
/// Handles required validation and provides a formatted string as the selected value.
library;

import 'package:flutter/material.dart';
import 'package:formio/flutter_formio.dart';
import 'package:intl/intl.dart';

class DateComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The currently selected ISO-8601 datetime string.
  final String? value;

  /// Callback triggered when the datetime value changes.
  final ValueChanged<String?> onChanged;

  /// Optional custom date picker callback
  final DatePickerCallback? onDatePick;

  /// Optional custom time picker callback
  final TimePickerCallback? onTimePick;

  const DateComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.onDatePick,
    this.onTimePick,
  });

  @override
  State<DateComponent> createState() => _DateComponentState();
}

class _DateComponentState extends State<DateComponent> {
  DateTime? _selectedDateTime;

  bool get _isRequired => widget.component.required;

  bool get _enableDate => widget.component.raw['enableDate'] != false;
  bool get _enableTime => widget.component.raw['enableTime'] == true;

  String? get _placeholder => widget.component.raw['placeholder'];

  String _formatDateTime(DateTime dateTime) {
    if (_enableDate && _enableTime) {
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } else if (_enableTime) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? date;
    TimeOfDay? time;

    if (_enableDate) {
      // Use custom date picker if provided, otherwise use default
      if (widget.onDatePick != null) {
        date = await widget.onDatePick!(
          initialDate: _selectedDateTime ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
      } else {
        date = await showDatePicker(
          context: context,
          initialDate: _selectedDateTime ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
      }
      if (!mounted) return;
      if (date == null) return;
    }

    if (_enableTime) {
      // Use custom time picker if provided, otherwise use default
      if (widget.onTimePick != null) {
        time = await widget.onTimePick!(
          initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
        );
      } else {
        time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
        );
      }
      if (!mounted) return;
      if (time == null && !_enableDate) return;
    }

    DateTime finalDateTime;
    if (_enableDate && _enableTime) {
      finalDateTime = DateTime(date!.year, date.month, date.day, time!.hour, time.minute);
    } else if (_enableDate) {
      finalDateTime = date!;
    } else {
      final now = DateTime.now();
      finalDateTime = DateTime(now.year, now.month, now.day, time!.hour, time.minute);
    }

    setState(() {
      _selectedDateTime = finalDateTime;
    });
    widget.onChanged(finalDateTime.toIso8601String());
  }

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _selectedDateTime = DateTime.tryParse(widget.value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format display value to show both date and time when available
    String displayValue;
    if (_selectedDateTime != null) {
      displayValue = _formatDateTime(_selectedDateTime!);
    } else {
      displayValue = _placeholder ?? 'Select...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.component.label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickDateTime,
          child: InputDecorator(
            decoration: InputDecoration(hintText: _placeholder ?? 'Select...'),
            child: Text(displayValue.isEmpty ? ' ' : displayValue),
          ),
        ),
        if (_isRequired && _selectedDateTime == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(ComponentFactory.locale.getRequiredMessage(widget.component.label), style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}
