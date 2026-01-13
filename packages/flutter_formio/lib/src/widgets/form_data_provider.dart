/// Provides form data to all descendant widgets using InheritedWidget.
///
/// This allows layout components like ColumnsComponent to reactively
/// rebuild when form data changes, enabling conditional logic to work correctly.
library;

import 'package:flutter/material.dart';

class FormDataProvider extends InheritedWidget {
  final Map<String, dynamic> formData;

  const FormDataProvider({
    super.key,
    required this.formData,
    required super.child,
  });

  /// Access the current form data from context
  static Map<String, dynamic> of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<FormDataProvider>();
    return provider?.formData ?? {};
  }

  /// Access form data without rebuilding when it changes
  static Map<String, dynamic> read(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<FormDataProvider>();
    return provider?.formData ?? {};
  }

  @override
  bool updateShouldNotify(FormDataProvider oldWidget) {
    // Notify dependents when formData reference changes
    return formData != oldWidget.formData;
  }
}
