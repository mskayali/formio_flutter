/// Renders a dynamic form in Flutter based on a Form.io form definition.
///
/// This widget receives a [FormModel] and builds a corresponding widget tree
/// based on its list of components. It supports dynamic user input handling,
/// required field validation, and data collection for form submission.
///
/// When a component of type "button" and action "submit" is tapped,
/// the form data is validated and submitted via [onSubmit].
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:formio/formio.dart';

import 'form_data_provider.dart';

typedef OnFormChanged = void Function(Map<String, dynamic> data);
typedef OnFormSubmitted = void Function(Map<String, dynamic> data);
typedef OnFormSubmitFailed = void Function(String error);

class FormRenderer extends StatefulWidget {
  final FormModel form;
  final OnFormChanged? onChanged;
  final OnFormSubmitted? onSubmit;
  final OnFormSubmitFailed? onError;
  final Map<String, dynamic>? initialData;

  // Custom widget callbacks
  final FilePickerCallback? onFilePick;
  final DatePickerCallback? onDatePick;
  final TimePickerCallback? onTimePick;

  /// Whether to enable clicking on links in Content/HTML components.
  final bool enableLinks;

  /// Optional API client to use for submissions.
  /// If null, a default [ApiClient] will be created.
  final ApiClient? apiClient;

  const FormRenderer({
    super.key,
    required this.form,
    this.onChanged,
    this.onSubmit,
    this.onError,
    this.initialData,
    this.onFilePick,
    this.onDatePick,
    this.onTimePick,
    this.enableLinks = true,
    this.apiClient,
  });

  @override
  State<FormRenderer> createState() => _FormRendererState();
}

class _FormRendererState extends State<FormRenderer> {
  late Map<String, dynamic> _formData;
  final Map<String, String?> _errors = {};
  late final SubmissionService? _submissionService;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _submissionService = widget.apiClient != null ? SubmissionService(widget.apiClient!) : null;
    _formData = widget.initialData != null ? Map<String, dynamic>.from(widget.initialData!) : {};

    // Calculate initial values for calculated fields
    _updateCalculatedFields();

    if (kDebugMode) {
      print('🚀 FormRenderer initialized with ${_formData.length} initial values');
      print('🚀 Initial form data keys: ${_formData.keys.join(', ')}');
    }
  }

  /// Updates all calculated fields based on current form data.
  void _updateCalculatedFields() {
    bool changed = true;
    int iterations = 0;
    const maxIterations = 5; // Safety limit for deep dependencies

    // Continue updating as long as something changes, up to a limit
    while (changed && iterations < maxIterations) {
      changed = false;
      iterations++;

      for (final component in widget.form.components) {
        if (CalculationEvaluator.hasCalculation(component.raw)) {
          final calculateConfig = component.raw['calculateValue'];
          final calculatedValue = CalculationEvaluator.evaluate(calculateConfig, _formData);

          if (calculatedValue != null) {
            // Check if the value is different from current value
            final oldValue = _formData[component.key];
            if (oldValue != calculatedValue) {
              // Only update if allowCalculateOverride is false or field is empty
              final allowOverride = CalculationEvaluator.allowsOverride(component.raw);
              final hasUserValue = _formData.containsKey(component.key) && _formData[component.key] != null;

              if (!allowOverride || !hasUserValue) {
                _formData[component.key] = calculatedValue;
                changed = true;
              }
            }
          }
        }
      }
    }
  }

  void _updateField(String key, dynamic value) {
    const layoutComponentTypes = ['panel', 'columns', 'well', 'fieldset', 'table', 'tabs'];
    final component = widget.form.components.firstWhere(
      (c) => c.key == key,
      orElse: () => widget.form.components.first,
    );
    final isLayoutComponent = layoutComponentTypes.contains(component.type);

    setState(() {
      if (isLayoutComponent && value is Map<String, dynamic>) {
        _formData = Map<String, dynamic>.from(_formData)..addAll(value);
      } else {
        _formData = Map<String, dynamic>.from(_formData)..[key] = value;
      }
      _updateCalculatedFields();
    });

    widget.onChanged?.call(_formData);
    if (kDebugMode) {
      print('📝 Form data changed: ${_formData.keys.join(', ')}');
    }
  }

  /// This handles cases where panel/columns components store their values nested
  dynamic _getFieldValue(String key) {
    // First check top-level
    if (_formData.containsKey(key)) {
      return _formData[key];
    }

    // Recursively search in nested maps at any depth
    return _searchInMap(_formData, key);
  }

  /// Helper to recursively search for a key in a nested map structure.
  dynamic _searchInMap(Map<String, dynamic> map, String key) {
    for (final value in map.values) {
      if (value is Map<String, dynamic>) {
        // Check if this map contains the key
        if (value.containsKey(key)) {
          return value[key];
        }
        // Recursively search deeper
        final found = _searchInMap(value, key);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
  }

  /// Recursively collect all components including nested ones from layout components.
  List<ComponentModel> _getAllComponents(List<ComponentModel> components) {
    final result = <ComponentModel>[];
    for (final component in components) {
      result.add(component);

      // Handle layout components with children (panel, fieldset, well, etc.)
      final childComponents = component.raw['components'] as List?;
      if (childComponents != null) {
        final children = childComponents.map((c) => ComponentModel.fromJson(c as Map<String, dynamic>)).toList();
        result.addAll(_getAllComponents(children));
      }

      // Handle columns specifically
      final columns = component.raw['columns'] as List?;
      if (columns != null) {
        for (final col in columns) {
          final colComponents = (col as Map<String, dynamic>)['components'] as List? ?? [];
          final children = colComponents.map((c) => ComponentModel.fromJson(c as Map<String, dynamic>)).toList();
          result.addAll(_getAllComponents(children));
        }
      }

      // Handle tabs specifically
      final tabs = component.raw['tabs'] as List?;
      if (tabs != null) {
        for (final tab in tabs) {
          final tabComponents = (tab as Map<String, dynamic>)['components'] as List? ?? [];
          final children = tabComponents.map((c) => ComponentModel.fromJson(c as Map<String, dynamic>)).toList();
          result.addAll(_getAllComponents(children));
        }
      }

      // Handle table rows
      final rows = component.raw['rows'] as List?;
      if (rows != null) {
        for (final row in rows) {
          for (final cell in (row as List)) {
            final cellComponents = (cell as Map<String, dynamic>)['components'] as List? ?? [];
            final children = cellComponents.map((c) => ComponentModel.fromJson(c as Map<String, dynamic>)).toList();
            result.addAll(_getAllComponents(children));
          }
        }
      }
    }
    return result;
  }

  bool _validateForm() {
    bool isValid = true;
    _errors.clear();

    // Get all components recursively including nested ones
    final allComponents = _getAllComponents(widget.form.components);

    for (final component in allComponents) {
      if (!_shouldShowComponent(component)) continue;

      final value = _getFieldValue(component.key);
      final isEmpty = value == null || (value is String && value.trim().isEmpty) || (value is Map && value.isEmpty) || (value is List && value.isEmpty);

      // Check component.required property
      if (component.required && isEmpty) {
        _errors[component.key] = ComponentFactory.locale.getRequiredMessage(component.label);
        isValid = false;
        continue;
      }

      // Check validate.required from raw JSON (some components use this format)
      final validateConfig = component.raw['validate'] as Map<String, dynamic>?;
      if (validateConfig != null && validateConfig['required'] == true && isEmpty && !_errors.containsKey(component.key)) {
        _errors[component.key] = ComponentFactory.locale.getRequiredMessage(component.label);
        isValid = false;
      }

      // Check fields.required for composite components (e.g., day component with day/month/year)
      final fields = component.raw['fields'] as Map<String, dynamic>?;
      if (fields != null && !_errors.containsKey(component.key)) {
        // Check if any field is required
        bool hasRequiredField = false;
        for (final fieldConfig in fields.values) {
          if (fieldConfig is Map && fieldConfig['required'] == true) {
            hasRequiredField = true;
            break;
          }
        }

        // If fields are required, validate the component value
        if (hasRequiredField && isEmpty) {
          _errors[component.key] = ComponentFactory.locale.getRequiredMessage(component.label);
          isValid = false;
        }
      }
    }

    setState(() {});
    return isValid;
  }

  Future<void> _handleSubmit() async {
    final isValid = _validateForm();
    if (!isValid) {
      // Collect all error messages and call onError callback
      final errorMessages = _errors.values.where((e) => e != null).join(', ');
      widget.onError?.call(errorMessages.isNotEmpty ? errorMessages : 'Validation failed');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (widget.form.path.isNotEmpty && _submissionService != null) {
        await _submissionService!.submit(widget.form.path, _formData);
      }
      widget.onSubmit?.call(_formData);
    } catch (e) {
      final error = e is ApiException ? e.message : 'Unknown error';
      widget.onError?.call(error);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  /// Checks whether a component should be shown based on its conditional logic.
  bool _shouldShowComponent(ComponentModel component) {
    final conditional = component.raw['conditional'] as Map<String, dynamic>?;
    return ConditionalEvaluator.shouldShow(conditional, _formData);
  }

  Widget _buildComponent(ComponentModel component) {
    if (!_shouldShowComponent(component)) {
      return const SizedBox.shrink();
    }

    if (component.type == 'button' && (component.raw['action'] == 'submit' || component.raw['action'] == null)) {
      // If a custom button builder is registered, use it
      if (ComponentFactory.isRegistered('button')) {
        return ComponentFactory.build(
          component: component,
          value: null,
          onChanged: (_) {}, // Custom buttons can use onSubmit trigger
          formData: _formData,
          onSubmit: _handleSubmit,
        );
      }
      // Default submit button
      return ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        child: _isSubmitting ? const CircularProgressIndicator() : Text(component.label.isNotEmpty ? component.label : ComponentFactory.locale.submit),
      );
    }

    // final Widget fieldWidget; // No change needed for this variable decl if it existed, but context shows full replacement block

    // Layout components (panel, columns, well, fieldset, table, tabs) are containers
    // that don't have their own value. They need the full formData so their children
    // can look up their values correctly.
    const layoutComponentTypes = ['panel', 'columns', 'well', 'fieldset', 'table', 'tabs'];
    final isLayoutComponent = layoutComponentTypes.contains(component.type);

    final componentValue = isLayoutComponent ? _formData : _formData[component.key];

    if (kDebugMode) {
      print('🔧 Building component "${component.key}" (${component.type}) with value: ${isLayoutComponent ? "{...full formData...}" : componentValue}');
    }

    final fieldWidget = ComponentFactory.build(
      component: component,
      value: componentValue,
      onChanged: (value) => _updateField(component.key, value),
      formData: _formData,
      onSubmit: _handleSubmit,
      onFilePick: widget.onFilePick,
      onDatePick: widget.onDatePick,
      onTimePick: widget.onTimePick,
      enableLinks: widget.enableLinks,
    );

    final errorText = _errors[component.key];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldWidget,
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormDataProvider(
      formData: _formData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.form.title.isNotEmpty) Text(widget.form.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...widget.form.components.map((component) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildComponent(component),
            );
          }),
        ],
      ),
    );
  }
}
