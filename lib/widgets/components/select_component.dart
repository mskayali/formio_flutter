/// A Flutter widget that renders a dropdown menu based on a Form.io "select" component.
///
/// Supports label, placeholder, required validation, default value,
/// and dynamic value lists from static JSON.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class SelectComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The currently selected value.
  final dynamic value;

  /// Complete form data for interpolation
  final Map<String, dynamic>? formData;

  /// Callback triggered when the user selects an option.
  final ValueChanged<dynamic> onChanged;

  const SelectComponent({
    super.key,
    required this.component,
    required this.value,
    this.formData,
    required this.onChanged,
  });

  @override
  State<SelectComponent> createState() => _SelectComponentState();
}

class _SelectComponentState extends State<SelectComponent> {
  final bool _isLoading = false;
  final List<Map<String, dynamic>> _dynamicOptions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(SelectComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_dataSrc == 'values') return;

    // 1. Check refreshOn trigger
    final refreshOn = widget.component.raw['refreshOn']?.toString();
    if (refreshOn != null && refreshOn.isNotEmpty) {
      if (oldWidget.formData?[refreshOn] != widget.formData?[refreshOn]) {
        return;
      }
    }
  }

  String get _dataSrc => widget.component.raw['dataSrc']?.toString() ?? 'values';

  /// Whether the field is marked as required.
  bool get _isRequired => widget.component.required;

  /// Returns the list of available options.
  List<Map<String, dynamic>> get _values {
    if (_dataSrc == 'values') {
      return List<Map<String, dynamic>>.from(widget.component.raw['data']?['values'] ?? []);
    }
    return _dynamicOptions;
  }

  /// Validates if a required selection is made.
  String? _validator() {
    if (_isRequired && (widget.value == null || widget.value.toString().isEmpty)) {
      return ComponentFactory.locale.getRequiredMessage(widget.component.label);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final validationError = _validator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.component.hideLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.component.label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        InputDecorator(
          key: ValueKey(widget.component.key),
          decoration: InputDecoration(
            errorText: validationError ?? _error,
            suffixIcon: _isLoading ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))) : null,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              isExpanded: true,
              hint: Text(widget.component.placeholder ?? 'Select...'),
              value: widget.value,
              onChanged: widget.component.disabled ? null : widget.onChanged,
              items: _values.map((option) {
                final label = option['label']?.toString() ?? '';
                final val = option['value'];
                return DropdownMenuItem<dynamic>(
                  value: val,
                  child: Text(label),
                );
              }).toList(),
            ),
          ),
        ),
        if (widget.component.description != null && widget.component.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              widget.component.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
          ),
      ],
    );
  }
}
