/// Template parser for Form.io template syntax.
///
/// Parses and evaluates templates like "{{ item.data.name }}" against data context.
/// Used for rendering dynamic select options from resource data.
library;

class TemplateParser {
  /// Evaluate a template string against data context.
  ///
  /// Example:
  /// ```dart
  /// TemplateParser.evaluate(
  ///   '<span>{{ item.data.name }}</span>',
  ///   {'item': {'data': {'name': 'Football'}}}
  /// )
  /// // Returns: '<span>Football</span>'
  /// ```
  static String evaluate(String template, Map<String, dynamic> data) {
    if (template.isEmpty) return '';

    // Match {{ variable.path }} patterns
    final regex = RegExp(r'\{\{\s*([^}]+)\s*\}\}');
    
    return template.replaceAllMapped(regex, (match) {
      final path = match.group(1)?.trim() ?? '';
      final value = _getNestedValue(data, path);
      return value?.toString() ?? '';
    });
  }

  /// Get nested value from a map using dot notation path.
  ///
  /// Example: _getNestedValue({'a': {'b': 'c'}}, 'a.b') returns 'c'
  static dynamic _getNestedValue(Map<String, dynamic> data, String path) {
    final parts = path.split('.');
    dynamic current = data;

    for (final part in parts) {
      if (current is Map<String, dynamic>) {
        current = current[part];
      } else {
        return null;
      }
    }

    return current;
  }

  /// Strip HTML tags from template output (basic sanitization).
  ///
  /// Removes <tag> and </tag> patterns, useful for displaying in plain text widgets.
  static String stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
