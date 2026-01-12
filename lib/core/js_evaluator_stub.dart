/// Stub implementation for JavaScript evaluator.
///
/// This file is used when neither dart:html nor dart:io is available.
/// In practice, this should never be used since all Flutter targets
/// support either web or mobile/desktop.

dynamic evaluateJS(
  String code,
  Map<String, dynamic> context, {
  int timeoutMs = 5000,
}) {
  throw UnsupportedError('JavaScript evaluation not supported on this platform');
}
