/// A Flutter widget that renders a checkbox based on a Form.io "checkbox" component.
///
/// Supports default value, label, and required validation.
library;

import 'package:flutter/material.dart';

import 'package:formio_api/formio_api.dart';
import '../component_factory.dart';

class CheckboxComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the checkbox (true/false).
  final bool value;

  /// Callback called when the user toggles the checkbox.
  final ValueChanged<bool> onChanged;

  const CheckboxComponent({super.key, required this.component, required this.value, required this.onChanged});

  /// Determines whether the checkbox is required.
  bool get _isRequired => component.required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          title: component.hideLabel ? null : Text(component.label),
          value: value,
          onChanged: component.disabled
              ? null
              : (val) {
                  if (val != null) {
                    onChanged(val);
                  }
                },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          subtitle: _isRequired && !value ? Text(ComponentFactory.locale.getRequiredMessage(component.label), style: TextStyle(color: Theme.of(context).colorScheme.error)) : null,
        ),
        if (component.description != null && component.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12),
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
