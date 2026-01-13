/// A Flutter widget that renders a fallback UI for unrecognized component types.
///
/// This component is used when the ComponentFactory encounters a component type
/// that is not supported. It displays a warning message instead of crashing.
library;

import 'package:flutter/material.dart';

import 'package:formio_api/formio_api.dart';

class UnknownComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Optional: Show debug information (raw JSON).
  final bool showDebugInfo;

  const UnknownComponent({
    super.key,
    required this.component,
    this.showDebugInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unsupported Component Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Type: ${component.type}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          Text(
            'Key: ${component.key}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          if (component.label.isNotEmpty)
            Text(
              'Label: ${component.label}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          if (showDebugInfo) ...[
            const SizedBox(height: 8),
            const Divider(),
            Text(
              'Raw JSON:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 4),
            Text(
              component.raw.toString(),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontFamily: 'monospace'),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
