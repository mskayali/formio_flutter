/// Utility for interpolating Form.io style {{data.key}} patterns.
class InterpolationUtils {
  /// Replaces {{data.key}} patterns in [text] with values from [formData].
  /// Supports nested keys using dot notation (e.g., data.user.name).
  static String interpolate(String text, Map<String, dynamic>? formData) {
    if (text.isEmpty || formData == null) return text;

    final regExp = RegExp(r'\{\{\s*data\.([a-zA-Z0-9._]+)\s*\}\}');
    return text.replaceAllMapped(regExp, (match) {
      final key = match.group(1);
      if (key == null) return match.group(0)!;

      final value = getPathValue(formData, key);
      return value?.toString() ?? '';
    });
  }

  /// Traverses a map using a dot-notated [path].
  static dynamic getPathValue(Map<String, dynamic> data, String path) {
    final parts = path.split('.');
    dynamic current = data;

    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }

    return current;
  }
}
