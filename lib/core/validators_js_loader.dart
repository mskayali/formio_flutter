///  Helper class to lazy-load JavaScript evaluator.
/// This avoids importing js_evaluator.dart directly which causes issues
/// with conditional imports.
library;

import 'js_evaluator.dart';

// Export as public class
class JavaScriptEvaluatorLoader {
  static dynamic load() {
    return JavaScriptEvaluator;
  }
}
