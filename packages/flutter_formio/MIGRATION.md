# Migration Guide: v1.x → v2.0

## Overview

The `formio` package has been split into two packages for better modularity:

- **`formio_api`** - Pure Dart API client (no Flutter dependencies)
- **`flutter_formio`** - Flutter widgets for rendering forms

## For Flutter Applications

### Before (v1.x)

```yaml
# pubspec.yaml
dependencies:
  formio: ^1.1.0
```

```dart
// main.dart
import 'package:flutter_formio/flutter_formio.dart';

void main() {
  runApp(MyApp());
}
```

### After (v2.0)

```yaml
# pubspec.yaml
dependencies:
  flutter_formio: ^2.0.0
  # formio_api is automatically included as a transitive dependency
```

```dart
// main.dart
import 'package:flutter_formio/flutter_formio.dart';

void main() {
  // NEW: Initialize JavaScript evaluator
  JavaScriptEvaluator.setEvaluator(FlutterJsEvaluator());
  
  runApp(MyApp());
}
```

## Breaking Changes

### 1. Package Name Change

**Old**: `import 'package:flutter_formio/flutter_formio.dart';`  
**New**: `import 'package:flutter_formio/flutter_formio.dart';`

**Action**: Update all imports in your project

```bash
# Find and replace in all Dart files
find lib -name "*.dart" -exec sed -i '' 's/package:formio/package:flutter_formio/g' {} +
```

### 2. JavaScript Evaluator Initialization

**Old**: Automatic initialization  
**New**: Must explicitly initialize

```dart
void main() {
  // Add this line BEFORE runApp()
  JavaScriptEvaluator.setEvaluator(FlutterJsEvaluator());
  
  runApp(MyApp());
}
```

**Why**: Allows using custom JS engines or no-op for testing

### 3. Package Exports

**Old**: All types exported from single `formio.dart`  
**New**: Split between `flutter_formio` and `formio_api`

Most types are re-exported from `flutter_formio` for convenience, but if you need direct access to API types:

```dart
// For API-only types
import 'package:formio_api/formio_api.dart';

// For widgets and UI
import 'package:flutter_formio/flutter_formio.dart';
```

## New Features in v2.0

### Pure Dart API Client

You can now use Form.io API in non-Flutter Dart projects:

```yaml
# For CLI tools, backend services, etc.
dependencies:
  formio_api: ^2.0.0  # No Flutter!
```

```dart
import 'package:formio_api/formio_api.dart';

void main() async {
  ApiClient.setBaseUrl(Uri.parse('https://examples.form.io'));
  
  final formService = FormService(ApiClient());
  final forms = await formService.fetchForms();
  
  print('Loaded ${forms.length} forms');
}
```

### Custom JavaScript Engines

```dart
class MyCustomJsEngine implements JsEvaluator {
  @override
  dynamic evaluate(String code, Map<String, dynamic> context) {
    // Your implementation
  }
  
  // ... other methods
}

void main() {
  JavaScriptEvaluator.setEvaluator(MyCustomJsEngine());
  runApp(MyApp());
}
```

### No-Op Mode for Testing

```dart
void main() {
  // Disable JS evaluation for faster unit tests
  JavaScriptEvaluator.setEvaluator(const NoOpJsEvaluator());
  
  runApp(MyApp());
}
```

## Step-by-Step Migration

### 1. Update Dependencies

```yaml
# pubspec.yaml
dependencies:
  # Remove this:
  # formio: ^1.1.0
  
  # Add this:
  flutter_formio: ^2.0.0
```

### 2. Update Imports

```bash
# Automated replace (macOS/Linux)
find lib test -name "*.dart" -exec sed -i '' 's/package:formio/package:flutter_formio/g' {} +

# Or manually in each file:
# OLD: import 'package:flutter_formio/flutter_formio.dart';
# NEW: import 'package:flutter_formio/flutter_formio.dart';
```

### 3. Initialize JS Evaluator

```dart
// lib/main.dart
import 'package:flutter_formio/flutter_formio.dart';

void main() {
  // Add this line
  JavaScriptEvaluator.setEvaluator(FlutterJsEvaluator());
  
  runApp(MyApp());
}
```

### 4. Run and Test

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Common Migration Issues

### Issue 1: "Undefined class 'FormioComponentBuilder'"

**Cause**: Custom components using old typedef  
**Solution**: Update to use abstract class

```dart
// OLD
class MyBuilder extends FormioComponentBuilder {
  // ...
}

// NEW
class MyBuilder implements FormioComponentBuilder {
  @override
  Widget build(FormioComponentBuildContext context) {
    // ...
  }
}
```

### Issue 2: "Can't find package formio_api"

**Cause**: Direct import of API types  
**Solution**: Import from flutter_formio (re-exports formio_api)

```dart
// Instead of:
// import 'package:formio_api/formio_api.dart';

// Use:
import 'package:flutter_formio/flutter_formio.dart';
```

### Issue 3: JavaScript Calculations Not Working

**Cause**: Missing JS evaluator initialization  
**Solution**: Add to main()

```dart
void main() {
  JavaScriptEvaluator.setEvaluator(FlutterJsEvaluator());
  runApp(MyApp());
}
```

## Deprecation Timeline

- **v1.2.0**: Last v1.x release (deprecated, points to v2.0)
- **v2.0.0**: New package structure
- **v1.x support**: Ends 6 months after v2.0 release

## Need Help?

- [GitHub Issues](https://github.com/mskayali/formio_flutter/issues)
- [Discussions](https://github.com/mskayali/formio_flutter/discussions)
- [Example App](https://github.com/mskayali/formio_flutter/tree/main/packages/flutter_formio/example)

## Rollback (if needed)

If you encounter issues and need to rollback:

```yaml
dependencies:
  formio: ^1.1.0  # Revert to v1.x
```

Then revert your code changes:
```bash
git revert <migration-commit>
```
