/// ComponentFactory maps Form.io component types to Flutter widgets.
///
/// Supports all standard, advanced, layout, data, and custom components.
/// Add new component types here as needed.

import 'package:flutter/material.dart';

import '../core/conditional_evaluator.dart';
import '../models/component.dart';
// Complex
import 'components/address_component.dart';
// Display
import 'components/alert_component.dart';
import 'components/button_component.dart';
import 'components/captcha_component.dart';
import 'components/checkbox_component.dart';
import 'components/columns_component.dart';
import 'components/container_component.dart';
import 'components/content_component.dart';
import 'components/currency_component.dart';
// Custom
import 'components/custom_component.dart';
import 'components/data_grid_component.dart';
import 'components/data_map_component.dart';
// Advanced
import 'components/datetime_component.dart';
import 'components/day_component.dart';
import 'components/edit_grid_component.dart';
import 'components/email_component.dart';
import 'components/fieldset_component.dart';
// Premium
import 'components/file_component.dart';
import 'components/form_component.dart';
// Data
import 'components/hidden_component.dart';
import 'components/html_element_component.dart';
import 'components/nested_form_component.dart';
import 'components/number_component.dart';
// Layout
import 'components/panel_component.dart';
import 'components/password_component.dart';
import 'components/phone_number_component.dart';
import 'components/radio_component.dart';
import 'components/select_boxes_component.dart';
import 'components/select_component.dart';
import 'components/signature_component.dart';
import 'components/survey_component.dart';
import 'components/table_component.dart';
import 'components/tabs_component.dart';
import 'components/tags_component.dart';
import 'components/text_area_component.dart';
// Basic
import 'components/text_field_component.dart';
import 'components/time_component.dart';
import 'components/unknown_component.dart';
import 'components/url_component.dart';
import 'components/well_component.dart';

typedef OnComponentChanged = void Function(dynamic value);

class ComponentFactory {
  /// Creates the appropriate widget for a given component.
  /// 
  /// [formData] should be the complete form data to support conditional logic evaluation.
  static Widget build({
    required ComponentModel component,
    dynamic value,
    required OnComponentChanged onChanged,
    Map<String, dynamic>? formData,
  }) {
    // Check conditional logic using the new ConditionalEvaluator
    if (formData != null) {
      final conditional = component.raw['conditional'] as Map<String, dynamic>?;
      if (!ConditionalEvaluator.shouldShow(conditional, formData)) {
        return const SizedBox.shrink();
      }
    }
    
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
        return SelectComponent(component: component, value: value, onChanged: onChanged);
      case 'selectboxes':
        return SelectBoxesComponent(component: component, value: value is Map<String, bool> ? value : <String, bool>{}, onChanged: onChanged);
      case 'button':
        return ButtonComponent(component: component, onPressed: () {}, isDisabled: false);

      // Advanced
      case 'date':
      case 'datetime':
        return DateTimeComponent(component: component, value: value, onChanged: onChanged);
      case 'day':
        return DayComponent(component: component, value: value, onChanged: onChanged);
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

      // Data
      case 'hidden':
        return HiddenComponent(component: component, value: value, onChanged: onChanged);
      case 'container':
        return ContainerComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'datamap':
        return DataMapComponent(component: component, value: value is Map<String, String> ? value : {}, onChanged: onChanged);
      case 'datagrid':
        return DataGridComponent(component: component, value: value is List<Map<String, dynamic>> ? value : [], onChanged: onChanged);
      case 'editgrid':
        return EditGridComponent(component: component, value: value is List<Map<String, dynamic>> ? value : [], onChanged: onChanged);

      // Layout
      case 'panel':
        return PanelComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'columns':
        return ColumnsComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'htmlelement':
        return HtmlElementComponent(component: component);
      case 'content':
        return ContentComponent(component: component);
      case 'alert':
        return AlertComponent(component: component);
      case 'fieldset':
        return FieldSetComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'table':
        return TableComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'tabs':
        return TabsComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'well':
        return WellComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);

      // Premium
      case 'file':
        return FileComponent(component: component, value: value is List<String> ? value : [], onChanged: onChanged);
      case 'nestedform':
        return NestedFormComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'form':
        return FormComponent(component: component, value: value is Map<String, dynamic> ? value : {}, onChanged: onChanged);
      case 'captcha':
        return CaptchaComponent(component: component, value: value, onChanged: onChanged);

      // Custom
      case 'custom':
        return CustomComponent(component: component, value: value, onChanged: onChanged);

      // Fallback
      default:
        return UnknownComponent(component: component);
    }
  }
}
