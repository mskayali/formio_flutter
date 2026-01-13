/// A Flutter widget that renders an embedded form (child form)
/// based on a Form.io "nestedform" component.
///
/// This widget is useful for nesting a separate form definition inside
/// another parent form. The child form is rendered dynamically.
library;

import 'package:flutter/material.dart';
import 'package:formio/formio.dart';


class NestedFormComponent extends StatefulWidget {
  /// The Form.io nestedform component definition.
  final ComponentModel component;

  /// Current form data of the nested form.
  final Map<String, dynamic> value;

  /// Callback triggered when nested form values change.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const NestedFormComponent({super.key, required this.component, required this.value, required this.onChanged});

  @override
  State<NestedFormComponent> createState() => _NestedFormComponentState();
}

class _NestedFormComponentState extends State<NestedFormComponent> {
  late Future<FormModel> _nestedFormFuture;
  final _client = ApiClient(); // Optionally: Inject from outside
  late final FormService _formService;

  @override
  void initState() {
    super.initState();
    _formService = FormService(_client);

    final path = widget.component.raw['form'];
    _nestedFormFuture = _formService.getFormByPath(path);
  }

  void _onNestedFormChanged(Map<String, dynamic> nestedData) {
    widget.onChanged(nestedData);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FormModel>(
      future: _nestedFormFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(padding: EdgeInsets.all(12), child: LinearProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Failed to load nested form.', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          );
        }

        final nestedForm = snapshot.data!;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: Padding(padding: const EdgeInsets.all(12), child: FormRenderer(form: nestedForm, initialData: widget.value, onChanged: _onNestedFormChanged)),
        );
      },
    );
  }
}
