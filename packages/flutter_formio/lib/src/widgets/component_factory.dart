/// ComponentFactory maps Form.io component types to Flutter widgets.
///
/// Supports all standard, advanced, layout, data, and custom components.
/// Add new component types here as needed.
library;

import 'package:flutter/material.dart';
import 'package:formio/formio.dart';
import 'package:formio/src/widgets/components/text_area_component.dart';

// Complex
// Display
// Custom
// Advanced
// Premium
// Data
// Layout
// Basic

class ComponentFactory {
  /// Global locale configuration for all components
  static FormioLocalizations _locale = const DefaultFormioLocalizations();

  /// Registry of custom component builders
  static final Map<String, FormioComponentBuilder> _customComponents = {};

  /// Get current locale
  static FormioLocalizations get locale => _locale;

  /// Set global locale for all components
  static void setLocale(FormioLocalizations newLocale) {
    _locale = newLocale;
  }

  /// Initializes the ComponentFactory with custom component builders.
  ///
  /// Use this method to register custom component types or override
  /// the default implementation of existing components.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   ComponentFactory.initialize({
  ///     'textfield': FunctionComponentBuilder((context) {
  ///       return MyCustomTextField(
  ///         component: context.component,
  ///         value: context.value,
  ///         onChanged: context.onChanged,
  ///       );
  ///     }),
  ///     'mycustomtype': FunctionComponentBuilder((context) {
  ///       return MyCustomComponent(
  ///         component: context.component,
  ///         value: context.value,
  ///         onChanged: context.onChanged,
  ///       );
  ///     }),
  ///   });
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// [componentBuilders] A map of component type strings to their builders.
  static void initialize(Map<String, FormioComponentBuilder> componentBuilders) {
    _customComponents.addAll(componentBuilders);
  }

  /// Registers a single custom component builder.
  ///
  /// Example:
  /// ```dart
  /// ComponentFactory.register('textfield', MyCustomTextFieldBuilder());
  /// ```
  ///
  /// [type] The component type identifier (e.g., 'textfield', 'number').
  /// [builder] The component builder implementation.
  static void register(String type, FormioComponentBuilder builder) {
    _customComponents[type] = builder;
  }

  /// Removes a custom component builder registration.
  ///
  /// After unregistering, the component will fall back to the default
  /// implementation if available.
  ///
  /// [type] The component type identifier to unregister.
  static void unregister(String type) {
    _customComponents.remove(type);
  }

  /// Checks if a custom component builder is registered for the given type.
  ///
  /// [type] The component type identifier.
  /// Returns true if a custom builder is registered.
  static bool isRegistered(String type) {
    return _customComponents.containsKey(type);
  }

  /// Creates the appropriate widget for a given component.
  static Widget build({
    required ComponentModel component,
    dynamic value,
    required ValueChanged<dynamic> onChanged,
    Map<String, dynamic>? formData,
    void Function()? onSubmit,
    FilePickerCallback? onFilePick,
    DatePickerCallback? onDatePick,
    TimePickerCallback? onTimePick,
    bool enableLinks = true,
  }) {
    // Check if a custom component builder is registered for this type
    final customBuilder = _customComponents[component.type];
    if (customBuilder != null) {
      return customBuilder.build(
        FormioComponentBuildContext(
          component: component,
          value: value,
          onChanged: onChanged,
          formData: formData,
          onSubmit: onSubmit,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        ),
      );
    }

    // Fall back to default component implementations
    switch (component.type) {
      // Basic
      case 'textfield':
        return TextFieldComponent(component: component, value: value, onChanged: onChanged);
      case 'textarea':
        return TextAreaComponent(component: component, value: value, onChanged: onChanged);
      case 'number':
        return NumberComponent(component: component, value: value, onChanged: onChanged);
      case 'password':
        return PasswordComponent(component: component, value: value, onChanged: onChanged);
      case 'email':
        return EmailComponent(component: component, value: value, onChanged: onChanged);
      case 'url':
        return UrlComponent(component: component, value: value, onChanged: onChanged);
      case 'phoneNumber':
        return PhoneNumberComponent(component: component, value: value, onChanged: onChanged);
      case 'checkbox':
        return CheckboxComponent(component: component, value: value == true, onChanged: onChanged);
      case 'radio':
        return RadioComponent(component: component, value: value, onChanged: onChanged);
      case 'select':
        return SelectComponent(
          component: component,
          value: value,
          onChanged: onChanged,
          formData: formData,
        );
      case 'selectboxes':
        return SelectBoxesComponent(component: component, value: value is Map<String, bool> ? value : <String, bool>{}, onChanged: onChanged);
      case 'button':
        return ButtonComponent(component: component, onPressed: () {}, isDisabled: false);

      // Advanced
      case 'date':
        return DateComponent(
          component: component,
          value: value is String ? value : null,
          onChanged: (val) => onChanged(val),
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );
      case 'datetime':
        return DateTimeComponent(
          component: component,
          value: value is String ? value : (value is DateTime ? value.toIso8601String() : null),
          onChanged: (val) => onChanged(val),
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );
      case 'day':
        return DayComponent(component: component, value: value, onChanged: onChanged, formData: formData);
      case 'time':
        return TimeComponent(component: component, value: value, onChanged: onChanged);
      case 'currency':
        return CurrencyComponent(component: component, value: value, onChanged: onChanged);
      case 'address':
        return AddressComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'tags':
        return TagsComponent(component: component, value: value, onChanged: onChanged);
      case 'survey':
        return SurveyComponent(component: component, value: value is Map<String, String> ? value : <String, String>{}, onChanged: onChanged);
      case 'signature':
        return SignatureComponent(component: component, value: value, onChanged: onChanged);

      // Data Components
      case 'hidden':
        return HiddenComponent(component: component, value: value, onChanged: onChanged);
      case 'datasource':
        return DataSourceComponent(
          component: component,
          value: value,
          onChanged: onChanged,
          formData: formData,
        );
      case 'container':
        return ContainerComponent(
          component: component,
          value: value is Map<String, dynamic> ? value : {},
          onChanged: (val) => onChanged(val),
          formData: formData,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );
      case 'datamap':
        return DataMapComponent(component: component, value: value is Map<String, String> ? value : {}, onChanged: onChanged);
      case 'datagrid':
        return DataGridComponent(
          component: component,
          value: value is List ? List<Map<String, dynamic>>.from(value) : [],
          onChanged: (val) => onChanged(val),
          formData: formData,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );
      case 'editgrid':
        return EditGridComponent(
          component: component,
          value: value is List ? List<Map<String, dynamic>>.from(value) : [],
          onChanged: (val) => onChanged(val),
          formData: formData,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );
      case 'dynamicwizard':
        return DynamicWizardComponent(
          component: component,
          value: value is List ? List<Map<String, dynamic>>.from(value) : [],
          onChanged: (val) => onChanged(val),
          formData: formData,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );

      // Layout
      case 'panel':
        return PanelComponent(
          component: component,
          value: value is Map<String, dynamic> ? value : {},
          onChanged: (val) => onChanged(val),
          formData: formData,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );
      case 'columns':
        return ColumnsComponent(
          component: component,
          value: value is Map<String, dynamic> ? value : {},
          onChanged: (val) => onChanged(val),
          formData: formData,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );
      case 'htmlelement':
        return HtmlElementComponent(component: component, formData: formData, enableLinks: enableLinks);
      case 'content':
        return ContentComponent(component: component, formData: formData, enableLinks: enableLinks);
      case 'alert':
        return AlertComponent(component: component, formData: formData);
      case 'fieldset':
        return FieldSetComponent(
          component: component,
          value: value is Map<String, dynamic> ? value : {},
          onChanged: (val) => onChanged(val),
          formData: formData,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );
      case 'table':
        return TableComponent(
          component: component,
          value: value is Map<String, dynamic> ? value : {},
          onChanged: (val) => onChanged(val),
          formData: formData,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );
      case 'tabs':
        return TabsComponent(
          component: component,
          value: value is Map<String, dynamic> ? value : {},
          onChanged: (val) => onChanged(val),
          formData: formData,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );
      case 'well':
        return WellComponent(
          component: component,
          value: value is Map<String, dynamic> ? value : {},
          onChanged: (val) => onChanged(val),
          formData: formData,
          onFilePick: onFilePick,
          onDatePick: onDatePick,
          onTimePick: onTimePick,
        );

      // Premium Components
      case 'file':
        return FileComponent(
          component: component,
          value: value is List ? value.cast<FileData>() : <FileData>[],
          onChanged: (files) => onChanged(files),
          onFilePick: onFilePick,
        );
      case 'nestedform':
        return NestedFormComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'form':
        return FormComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'captcha':
        return CaptchaComponent(component: component, value: value, onChanged: onChanged);
      case 'tagpad':
        return TagpadComponent(component: component, value: value is List ? value.cast<String>() : null, onChanged: onChanged);
      case 'sketchpad':
        return SketchpadComponent(component: component, value: value as String?, onChanged: onChanged);
      case 'reviewpage':
        return ReviewPageComponent(component: component, value: value is Map<String, dynamic> ? value : null, onChanged: onChanged);
      case 'datatable':
        return DataTableComponent(component: component, value: value is List ? value.cast<Map<String, dynamic>>() : null, onChanged: onChanged);

      // Custom
      case 'custom':
        return CustomComponent(component: component, value: value, onChanged: onChanged);

      // Fallback
      default:
        return UnknownComponent(component: component);
    }
  }
}
