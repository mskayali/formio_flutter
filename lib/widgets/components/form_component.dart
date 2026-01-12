/// A Flutter widget that renders a nested Form.io form based on a "form" component.
///
/// This component can load an external form via API or use an inline form definition.
/// It isolates the nested form data under the component's key.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../../models/form.dart';
import '../../services/form_service.dart';
import '../form_renderer.dart';

class FormComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current nested form data.
  final Map<String, dynamic> value;

  /// Callback triggered when nested form data changes.
  final ValueChanged<Map<String, dynamic>> onChanged;

  /// Optional FormService for loading external forms.
  final FormService? formService;

  const FormComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.formService,
  }) : super(key: key);

  @override
  State<FormComponent> createState() => _FormComponentState();
}

class _FormComponentState extends State<FormComponent> {
  FormModel? _nestedForm;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  /// Loads the nested form either from API or inline definition.
  Future<void> _loadForm() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final src = widget.component.raw['src']?.toString();
      final inlineComponents = widget.component.raw['components'] as List<dynamic>?;

      if (src != null && src.isNotEmpty && widget.formService != null) {
        // Load form from API
        final form = await widget.formService!.getFormByPath(src);
        setState(() {
          _nestedForm = form;
          _loading = false;
        });
      } else if (inlineComponents != null && inlineComponents.isNotEmpty) {
        // Use inline form definition
        setState(() {
          _nestedForm = FormModel(
            id: widget.component.key,
            path: widget.component.key,
            title: widget.component.label,
            components: inlineComponents
                .map((c) => ComponentModel.fromJson(c as Map<String, dynamic>))
                .toList(),
          );
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'No form source (src) or inline components defined';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load nested form: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
          ],
        ),
      );
    }

    if (_nestedForm == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.component.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              widget.component.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FormRenderer(
            form: _nestedForm!,
            initialData: widget.value,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
