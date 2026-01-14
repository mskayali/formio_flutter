/// Base interface for all Form.io components.
///
/// All Form.io components should implement this interface to ensure
/// a consistent structure and allow for custom component registration.
library;

import 'package:flutter/material.dart';
import 'package:formio/formio.dart';

/// Configuration for building a Form.io component widget.
///
/// This class encapsulates all the parameters needed to build a component,
/// making it easier to pass around and extend in the future.
class FormioComponentBuildContext {
  /// The Form.io component definition
  final ComponentModel component;

  /// The current value of the component
  final dynamic value;

  /// Callback when the value changes
  final ValueChanged<dynamic> onChanged;

  /// The entire form data (for conditional logic, calculations, etc.)
  final Map<String, dynamic>? formData;

  /// Optional file picker callback
  final FilePickerCallback? onFilePick;

  /// Optional date picker callback
  final DatePickerCallback? onDatePick;

  /// Optional time picker callback
  final TimePickerCallback? onTimePick;

  const FormioComponentBuildContext({
    required this.component,
    required this.value,
    required this.onChanged,
    this.formData,
    this.onFilePick,
    this.onDatePick,
    this.onTimePick,
  });
}

/// Base interface for all Form.io component builders.
///
/// Implement this interface to create custom component builders that can
/// be registered with the ComponentFactory.
///
/// Example:
/// ```dart
/// class MyCustomComponentBuilder implements FormioComponentBuilder {
///   @override
///   Widget build(FormioComponentBuildContext context) {
///     return MyCustomWidget(
///       component: context.component,
///       value: context.value,
///       onChanged: context.onChanged,
///     );
///   }
/// }
/// ```
abstract class FormioComponentBuilder {
  /// Builds the widget for this component.
  ///
  /// The [context] parameter contains all the necessary information
  /// to build the component, including the component definition,
  /// current value, and callbacks.
  Widget build(FormioComponentBuildContext context);
}

/// A function-based implementation of FormioComponentBuilder.
///
/// This allows simple function-based component builders without
/// creating a full class.
class FunctionComponentBuilder implements FormioComponentBuilder {
  final Widget Function(FormioComponentBuildContext context) _builder;

  const FunctionComponentBuilder(this._builder);

  @override
  Widget build(FormioComponentBuildContext context) => _builder(context);
}
