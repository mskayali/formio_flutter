/// A Flutter widget that renders a phone number input field based on
/// a Form.io "phoneNumber" component.
///
/// Supports label, placeholder, required validation, default value,
/// and numeric keyboard input.
library;

import 'package:flutter/material.dart';

import 'package:formio_api/formio_api.dart';
import '../component_factory.dart';

class PhoneNumberComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current phone number value.
  final String? value;

  /// Callback triggered when the phone number is updated.
  final ValueChanged<String> onChanged;

  const PhoneNumberComponent({super.key, required this.component, required this.value, required this.onChanged});

  /// Whether the field is marked as required.
  bool get _isRequired => component.required;

  /// Regular expression for basic phone number format validation.
  static final _phoneRegex = RegExp(r'^[\d\-\+\s\(\)]+$');

  /// Validates presence and basic format.
  String? _validator(String? input) {
    final text = (input ?? '').trim();

    if (_isRequired && text.isEmpty) {
      return ComponentFactory.locale.getRequiredMessage(component.label);
    }

    if (text.isNotEmpty && !_phoneRegex.hasMatch(text)) {
      return 'Please enter a valid phone number.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          initialValue: value ?? component.defaultValue?.toString(),
          enabled: !component.disabled,
          decoration: InputDecoration(
            labelText: component.hideLabel ? null : component.label,
            hintText: component.placeholder ?? '+1 (555) 123-4567',
            prefixText: component.prefix,
            suffixText: component.suffix,
          ),
          keyboardType: TextInputType.phone,
          onChanged: onChanged,
          validator: _validator,
        ),
        if (component.description != null && component.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              component.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
          ),
      ],
    );
  }
}
