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
    setState(() {
      _formData = Map<String, dynamic>.from(_formData)..[key] = value;
      _updateCalculatedFields();
    });

    widget.onChanged?.call(_formData);
    if (kDebugMode) {
      print('📝 Form data changed: ${_formData.keys.join(', ')}');
    }
  }

  bool _validateForm() {
    bool isValid = true;
    _errors.clear();

    for (final component in widget.form.components) {
      if (_shouldShowComponent(component) && component.required) {
        final value = _formData[component.key];
        final isEmpty = value == null || (value is String && value.trim().isEmpty) || (value is Map && value.isEmpty) || (value is List && value.isEmpty);

        if (isEmpty) {
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
    if (!isValid) return;

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

    final fieldWidget = ComponentFactory.build(
      component: component,
      value: _formData[component.key],
      onChanged: (value) => _updateField(component.key, value),
      formData: _formData,
      onSubmit: _handleSubmit,
      onFilePick: widget.onFilePick,
      onDatePick: widget.onDatePick,
      onTimePick: widget.onTimePick,
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
