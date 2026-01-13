/// A Flutter widget representing a hidden input field based on a Form.io "hidden" component.
///
/// This widget is not visible in the UI but still participates in the form's data.
/// The value is stored and passed along with the form submission.
library;

import 'package:flutter/widgets.dart';

import '../../models/component.dart';

class HiddenComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current hidden value to include in the submission.
  final dynamic value;

  /// Callback triggered to set or update the value (if necessary).
  final ValueChanged<dynamic> onChanged;

  const HiddenComponent({super.key, required this.component, required this.value, required this.onChanged});

  /// Determines the value to use: current value, defaultValue, or a fixed value.

  @override
  Widget build(BuildContext context) {
    // No visible widget is returned
    return const SizedBox.shrink();
  }
}
