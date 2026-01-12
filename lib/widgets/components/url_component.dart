/// A Flutter widget that renders a URL input field based on a Form.io "url" component.
///
/// Supports URL validation, placeholder, label, and required validation.

import 'package:flutter/material.dart';

import '../../models/component.dart';

class UrlComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the URL field.
  final String? value;

  /// Callback called when the user changes the input value.
  final ValueChanged<String> onChanged;

  const UrlComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  /// Retrieves a placeholder value if available in the raw JSON.
  String? get _placeholder => component.raw['placeholder'];

  /// Returns true if the field is required.
  bool get _isRequired => component.required;

  /// URL validation regex pattern.
  static final RegExp _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    caseSensitive: false,
  );

  /// Validates the URL format.
  String? _validateUrl(String? val) {
    if (val == null || val.isEmpty) {
      return _isRequired ? '${component.label} is required.' : null;
    }
    
    if (!_urlRegex.hasMatch(val)) {
      return 'Please enter a valid URL (e.g., https://example.com)';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey(component.key),
      initialValue: value ?? component.defaultValue?.toString(),
      decoration: InputDecoration(
        labelText: component.label,
        hintText: _placeholder ?? 'https://example.com',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.link),
      ),
      keyboardType: TextInputType.url,
      onChanged: onChanged,
      validator: _validateUrl,
    );
  }
}
