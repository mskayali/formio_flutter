/// A Flutter widget that renders a titled container panel based on a
/// Form.io "panel" component.
///
/// Used to visually group related form fields under a common section with
/// an optional title and collapsible behavior (if configured).

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class PanelComponent extends StatelessWidget {
  /// The Form.io panel definition.
  final ComponentModel component;

  /// Nested values passed into the panel's child components.
  final Map<String, dynamic> value;

  /// Callback triggered when any child component inside the panel changes.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const PanelComponent({Key? key, required this.component, required this.value, required this.onChanged}) : super(key: key);

  /// List of components inside the panel.
  List<ComponentModel> get _children {
    final components = component.raw['components'] as List? ?? [];
    return components.map((c) => ComponentModel.fromJson(c)).toList();
  }

  void _updateField(String key, dynamic val) {
    final updated = Map<String, dynamic>.from(value);
    updated[key] = val;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _children.where((child) {
            // Optional pre-check for conditional inside child
            final condition = child.conditional;
            if (condition == null || condition['when'] == null) return true;

            final controllingKey = condition['when'];
            final expectedValue = condition['eq'];
            final actualValue = value[controllingKey];

            final matches = actualValue?.toString() == expectedValue?.toString();
            final shouldShow = condition['show'] == 'true' ? matches : !matches;

            return shouldShow;
          }).map((child) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ComponentFactory.build(
                component: child,
                value: value[child.key],
                onChanged: (val) => _updateField(child.key, val),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
