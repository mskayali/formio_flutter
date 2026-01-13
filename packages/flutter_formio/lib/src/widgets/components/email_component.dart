/// A Flutter widget that renders an email input based on a Form.io "email" component.
///
/// Validates email format and supports label, placeholder, required constraint,
/// and a default value.
library;

import 'package:flutter/material.dart';

import 'package:formio_api/formio_api.dart';
import '../component_factory.dart';

class EmailComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current email value.
  final String? value;

  /// Callback triggered when the email is updated.
  final ValueChanged<String> onChanged;

  const EmailComponent({super.key, required this.component, required this.value, required this.onChanged});

  /// Whether the field is marked as required.
  bool get _isRequired => component.required;

  /// Regular expression for basic email validation.
  static final _emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

  /// Validates required and format constraints.
  String? _validator(String? input) {
    final text = (input ?? '').trim();

    if (_isRequired && text.isEmpty) {
      return ComponentFactory.locale.getRequiredMessage(component.label);
    }

    if (text.isNotEmpty && !_emailRegex.hasMatch(text)) {
      return 'Please enter a valid email address.';
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
            hintText: component.placeholder ?? 'example@example.com',
            prefixText: component.prefix,
            suffixText: component.suffix,
          ),
          keyboardType: TextInputType.emailAddress,
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
