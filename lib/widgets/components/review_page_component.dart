/// A Flutter widget that renders a Review Page component.
///
/// Displays all form data in a read-only format for review before submission.
/// Shows field labels and values in an organized layout.
library;

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class ReviewPageComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The form data to display for review.
  final Map<String, dynamic>? value;

  /// Callback for when data changes (not used in review mode).
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ReviewPageComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
  });

  String? get _label => component.raw['label'] as String?;
  String? get _title => component.raw['title'] as String?;

  @override
  Widget build(BuildContext context) {
    final formData = value ?? {};

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (_title != null || _label != null)
              Text(
                _title ?? _label ?? ComponentFactory.locale.review,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            if (_title != null || _label != null) const SizedBox(height: 16),

            // Display all form data
            if (formData.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    ComponentFactory.locale.noDataToReview,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ),
              )
            else
              ...formData.entries.map((entry) {
                return _buildReviewItem(context, entry.key, entry.value);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, String key, dynamic value) {
    // Format the key to be more readable (camelCase -> Title Case)
    final formattedKey = _formatKey(key);
    final formattedValue = _formatValue(value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedKey,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Text(
              formattedValue,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    // Convert camelCase or snake_case to Title Case
    return key
        .replaceAllMapped(
          RegExp(r'([A-Z])|_([a-z])'),
          (match) => ' ${match.group(1) ?? match.group(2)!.toUpperCase()}',
        )
        .trim()
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value == null) return ComponentFactory.locale.empty;
    if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }
    if (value is List) {
      if (value.isEmpty) return ComponentFactory.locale.none;
      return value.join(', ');
    }
    if (value is bool) return value ? ComponentFactory.locale.yes : ComponentFactory.locale.no;
    return value.toString();
  }
}
