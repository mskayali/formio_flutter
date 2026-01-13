/// A Flutter widget that renders a text field based on a Form.io "textfield" component.
///
/// Supports placeholder, label, default value, and comprehensive validation including
/// required, pattern, minLength, maxLength, minWords, maxWords.
library;

import 'package:flutter/material.dart';
import 'package:formio/flutter_formio.dart';


class TextFieldComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the field.
  final String? value;

  /// Callback called when the user changes the input value.
  final ValueChanged<String> onChanged;

  const TextFieldComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
  });

  /// Gets validation config from component.
  Map<String, dynamic>? get _validateConfig => component.raw['validate'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          key: ValueKey(component.key),
          initialValue: value ?? component.defaultValue?.toString(),
          enabled: !component.disabled,
          decoration: InputDecoration(
            labelText: component.hideLabel ? null : component.label,
            hintText: component.placeholder,
            prefixText: component.prefix,
            suffixText: component.suffix,
          ),
          onChanged: onChanged,
          validator: FormioValidators.fromConfig(_validateConfig, component.label),
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
