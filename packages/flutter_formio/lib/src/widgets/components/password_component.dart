/// A Flutter widget that renders a password input based on a Form.io "password" component.
///
/// Supports label, placeholder, required validation, and default value.
/// The input is obscured by default for security.
library;

import 'package:flutter/material.dart';

import 'package:formio_api/formio_api.dart';
import '../component_factory.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          initialValue: widget.value ?? widget.component.defaultValue?.toString() ?? '',
          enabled: !widget.component.disabled,
          decoration: InputDecoration(
            labelText: widget.component.hideLabel ? null : widget.component.label,
            hintText: widget.component.placeholder,
            prefixText: widget.component.prefix,
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
          validator: _isRequired ? (val) => (val == null || val.isEmpty) ? ComponentFactory.locale.getRequiredMessage(widget.component.label) : null : null,
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
