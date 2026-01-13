/// A Flutter widget that renders a placeholder for a developer-defined
/// custom component, based on a Form.io "custom" component.
///
/// Since the behavior of a custom component is not known at compile-time,
/// this widget provides a flexible callback hook for rendering and handling
/// data, or simply displays an unsupported message.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';

typedef CustomComponentBuilder = Widget Function(ComponentModel component, dynamic value, ValueChanged<dynamic> onChanged);

class CustomComponent extends StatelessWidget {
  /// The Form.io component definition (includes custom options/code).
  final ComponentModel component;

  /// Current value stored for this custom field.
  final dynamic value;

  /// Callback triggered when the custom value changes.
  final ValueChanged<dynamic> onChanged;

  /// Optional external builder to render the actual custom component UI.
  final CustomComponentBuilder? customBuilder;

  const CustomComponent({super.key, required this.component, required this.value, required this.onChanged, this.customBuilder});

  /// Optional JavaScript logic defined in Form.io for custom logic.
  String? get _customCode => component.raw['customCode'];

  @override
  Widget build(BuildContext context) {
    if (customBuilder != null) {
      return customBuilder!(component, value, onChanged);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(component.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration:
              BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.outline), borderRadius: BorderRadius.circular(6), color: Theme.of(context).colorScheme.surfaceContainerHighest),
          child: Text(
            'Custom component not implemented.\n'
            'You can handle "${component.key}" manually.\n\n'
            'Custom JS code:\n${_customCode ?? "(none)"}',
            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
