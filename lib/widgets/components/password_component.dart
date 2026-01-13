/// A Flutter widget that renders a password input based on a Form.io "password" component.
///
/// Supports label, placeholder, required validation, and default value.
/// The input is obscured by default for security.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';

class PasswordComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the password input.
  final String? value;

  /// Callback called when the user updates the password.
  final ValueChanged<String> onChanged;

  const PasswordComponent({super.key, required this.component, required this.value, required this.onChanged});

  @override
  State<PasswordComponent> createState() => _PasswordComponentState();
}

class _PasswordComponentState extends State<PasswordComponent> {
  bool _obscureText = true;

  /// Whether the field is marked as required.
  bool get _isRequired => widget.component.required;

  /// Placeholder text if defined.
  String? get _placeholder => widget.component.raw['placeholder'];

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.value ?? widget.component.defaultValue?.toString() ?? '',
      decoration: InputDecoration(
        labelText: widget.component.label,
        hintText: _placeholder,
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      validator: _isRequired ? (val) => (val == null || val.isEmpty) ? '${widget.component.label} is required.' : null : null,
    );
  }
}
