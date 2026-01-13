// Example custom textfield: Demonstrates overriding a default component
// This shows how to customize the appearance of the standard textfield

import 'package:flutter/material.dart';
import 'package:formio/formio.dart';

/// A custom styled textfield component.
///
/// This demonstrates how to override the default textfield component
/// with a custom implementation that has different styling.
class CustomStyledTextField extends StatelessWidget {
  final ComponentModel component;
  final String? value;
  final ValueChanged<String> onChanged;

  const CustomStyledTextField({
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
        // Custom styled textfield with gradient border
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(2), // Border width
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              key: ValueKey(component.key),
              initialValue: value ?? component.defaultValue?.toString(),
              enabled: !component.disabled,
              decoration: InputDecoration(
                labelText: component.hideLabel ? null : component.label,
                hintText: component.placeholder,
                prefixText: component.prefix,
                suffixText: component.suffix,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                // Custom icon to indicate this is a custom component
                prefixIcon: const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              onChanged: onChanged,
              validator:
                  FormioValidators.fromConfig(_validateConfig, component.label),
            ),
          ),
        ),
        if (component.description != null &&
            component.description!.isNotEmpty)
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

/// Builder for the custom styled textfield component
class CustomTextFieldBuilder implements FormioComponentBuilder {
  const CustomTextFieldBuilder();

  @override
  Widget build(FormioComponentBuildContext context) {
    return CustomStyledTextField(
      component: context.component,
      value: context.value?.toString(),
      onChanged: (val) => context.onChanged(val),
    );
  }
}
