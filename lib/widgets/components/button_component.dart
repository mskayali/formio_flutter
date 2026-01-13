/// A Flutter widget that renders a button based on a Form.io "button" component.
///
/// Supports configurable action types (submit, reset, etc.), label, theme,
/// and disabled state. Button logic is handled externally via the [onPressed] callback.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

/// Defines the type of action the button performs.
enum ButtonAction { submit, reset, custom, unknown }

class ButtonComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  /// Whether the button is currently disabled.
  final bool isDisabled;

  const ButtonComponent({super.key, required this.component, required this.onPressed, this.isDisabled = false});

  /// Extracts the button label from the component definition.
  String get _label => component.label.isNotEmpty ? component.label : (component.raw['label'] ?? ComponentFactory.locale.submit).toString();

  /// Determines the action type of the button.
  // ButtonAction get _action {
  //   final type = component.raw['action'] ?? 'submit';
  //   switch (type) {
  //     case 'submit':
  //       return ButtonAction.submit;
  //     case 'reset':
  //       return ButtonAction.reset;
  //     case 'event':
  //       return ButtonAction.custom;
  //     default:
  //       return ButtonAction.unknown;
  //   }
  // }

  /// Chooses a button style based on the theme specified in the component.
  ButtonStyle _style(BuildContext context) {
    final theme = (component.raw['theme'] ?? 'primary').toString();
    final color = switch (theme) {
      'primary' => Theme.of(context).colorScheme.primary,
      'danger' => Theme.of(context).colorScheme.error,
      'info' => Colors.teal,
      'success' => Colors.green,
      'warning' => Colors.orange,
      _ => Theme.of(context).colorScheme.primary,
    };

    return ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, textStyle: const TextStyle(fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(style: _style(context), onPressed: isDisabled ? null : onPressed, child: Text(_label));
  }
}
