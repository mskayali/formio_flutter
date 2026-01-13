/// A Flutter widget that renders a dropdown menu based on a Form.io "select" component.
///
/// Supports:
/// - Static options from `data.values`
/// - Dynamic options from `dataSrc: "resource"` (fetched from Form.io API)
/// - Template-based option display
/// - Loading states and error handling
library;

import 'package:flutter/material.dart';

import '../../core/template_parser.dart';
import '../../models/component.dart';
import '../../network/api_client.dart';
import '../../services/form_service.dart';
import '../component_factory.dart';

class SelectComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The currently selected value.
  final dynamic value;

  /// Complete form data for interpolation
  final Map<String, dynamic>? formData;

  /// Callback triggered when the user selects an option.
  final ValueChanged<dynamic> onChanged;

  const SelectComponent({
    super.key,
    required this.component,
    required this.value,
    this.formData,
    required this.onChanged,
  });

  @override
  State<SelectComponent> createState() => _SelectComponentState();
}

class _SelectComponentState extends State<SelectComponent> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _dynamicOptions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    
    print('🔍 SelectComponent.initState()');
    print('   Component key: ${widget.component.key}');
    print('   Detected dataSrc: $_dataSrc');
    
    // Fetch options if dataSrc is resource
    if (_dataSrc == 'resource') {
      print('   ✅ Fetching resource options...');
      _fetchResourceOptions();
    } else {
      print('   ❌ NOT fetching (dataSrc = "$_dataSrc")');
    }
  }

  @override
  void didUpdateWidget(SelectComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Skip for static values
    if (_dataSrc == 'values') return;

    // Check if we need to refresh based on refreshOn trigger
    final refreshOn = widget.component.raw['refreshOn']?.toString();
    if (refreshOn != null && refreshOn.isNotEmpty) {
      if (oldWidget.formData?[refreshOn] != widget.formData?[refreshOn]) {
        _fetchResourceOptions();
      }
    }
  }

  String get _dataSrc => widget.component.raw['dataSrc']?.toString() ?? 'values';

  /// Whether the field is marked as required.
  bool get _isRequired => widget.component.required;

  /// Fetch options from a Form.io resource
  Future<void> _fetchResourceOptions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resourceId = widget.component.raw['data']?['resource']?.toString();
      if (resourceId == null || resourceId.isEmpty) {
        throw 'Resource ID not specified';
      }

      final template = widget.component.raw['template']?.toString() ?? '{{ item.data }}';

      print('🌐 Fetching from resource: $resourceId');
      print('🌐 Template: $template');

      // Fetch submissions from resource
      final formService = FormService(ApiClient());
      final submissions = await formService.fetchResourceSubmissions(resourceId);

      print('🌐 Received ${submissions.length} submissions');

      // Convert to dropdown options using template
      final options = submissions.map((submission) {
        // Wrap submission in 'item' context for template evaluation
        final context = {'item': submission};
        final labelHtml = TemplateParser.evaluate(template, context);
        final label = TemplateParser.stripHtml(labelHtml);

        // Use submission _id as value by default
        final value = submission['_id'] ?? submission['id'];

        print('   Option: label="$label", value="$value"');

        return {
          'label': label.isNotEmpty ? label : value.toString(),
          'value': value,
        };
      }).toList();

      setState(() {
        _dynamicOptions = options;
        _isLoading = false;
      });
      
      print('✅ Loaded ${options.length} options');
    } catch (e) {
      setState(() {
        _error = 'Failed to load options';
        _isLoading = false;
      });
      print('❌ Error fetching resource options: $e');
    }
  }

  /// Returns the list of available options.
  List<Map<String, dynamic>> get _values {
    if (_dataSrc == 'values') {
      return List<Map<String, dynamic>>.from(
        widget.component.raw['data']?['values'] ?? [],
      );
    }
    return _dynamicOptions;
  }

  /// Validates if a required selection is made.
  String? _validator() {
    if (_isRequired && (widget.value == null || widget.value.toString().isEmpty)) {
      return ComponentFactory.locale.getRequiredMessage(widget.component.label);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final validationError = _validator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.component.hideLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              widget.component.label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        InputDecorator(
          key: ValueKey(widget.component.key),
          decoration: InputDecoration(
            errorText: validationError ?? _error,
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              isExpanded: true,
              hint: Text(widget.component.placeholder ?? 'Select...'),
              value: widget.value,
              onChanged: widget.component.disabled || _isLoading ? null : widget.onChanged,
              items: _values.map((option) {
                final label = option['label']?.toString() ?? '';
                final val = option['value'];
                return DropdownMenuItem<dynamic>(
                  value: val,
                  child: Text(label),
                );
              }).toList(),
            ),
          ),
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
