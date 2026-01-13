/// A Flutter widget that renders an alert/notification message based on a Form.io "alert" component.
///
/// This is a display-only component that shows messages with type-based styling.
/// Supports types: error, success, info, warning.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../../core/interpolation_utils.dart';

class AlertComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Complete form data for interpolation
  final Map<String, dynamic>? formData;

  const AlertComponent({
    super.key,
    required this.component,
    this.formData,
  });

  /// Gets the alert type from component definition.
  String get _alertType => component.raw['alertType']?.toString().toLowerCase() ?? 'info';

  /// Gets the alert content/message with interpolation support.
  String get _content => InterpolationUtils.interpolate(
        component.raw['content']?.toString() ?? component.label,
        formData,
      );

  /// Returns the appropriate color for the alert type.
  Color _getColor() {
    switch (_alertType) {
      case 'error':
      case 'danger':
        return Colors.red;
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  /// Returns the appropriate icon for the alert type.
  IconData _getIcon() {
    switch (_alertType) {
      case 'error':
      case 'danger':
        return Icons.error_outline;
      case 'success':
        return Icons.check_circle_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  /// Returns the display title for the alert type.
  String _getTitle() {
    switch (_alertType) {
      case 'error':
      case 'danger':
        return 'Error';
      case 'success':
        return 'Success';
      case 'warning':
        return 'Warning';
      case 'info':
      default:
        return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getIcon(), color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTitle(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                if (_content.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _content,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
