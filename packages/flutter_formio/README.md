# flutter_formio

Flutter widgets for rendering [Form.io](https://form.io) forms with 98% feature parity.

[![pub package](https://img.shields.io/pub/v/flutter_formio.svg)](https://pub.dev/packages/flutter_formio)

## Features

- 🎨 **46+ Components**: All standard Form.io components
- ✨ **Full Feature Parity**: Wizard forms, nested forms, data grids, edit grids
- 🧮 **Calculations**: JSONLogic and JavaScript-based calculated values
- 🔀 **Conditional Logic**: Show/hide components based on form data
- ✅ **Validation**: Client-side validation with custom rules
- 🌍 **Localization**: Multi-language support with customizable messages
- 🎯 **Plugin System**: Register custom components and override defaults
- 📱 **Responsive**: Works on mobile, tablet, and desktop

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_formio: ^2.0.0
```

Run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize JavaScript Evaluator

```dart
import 'package:formio/flutter_formio.dart';

void main() {
  // Required for JavaScript calculations and validations
  JavaScriptEvaluator.setEvaluator(FlutterJsEvaluator());
  
  runApp(MyApp());
}
```

### 2. Render a Form

```dart
class MyFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form.io Form')),
      body: FormRenderer(
        form: FormModel.fromJson(myFormJson),
        onSubmit: (data) {
          print('Form submitted: $data');
          // Handle submission
        },
      ),
    );
  }
}
```

### 3. API Integration (Optional)

```dart
void main() async {
  // Configure API client
  ApiClient.setBaseUrl(Uri.parse('https://examples.form.io'));
  
  // Fetch forms from server
  final formService = FormService(ApiClient());
  final forms = await formService.fetchForms();
  
  JavaScriptEvaluator.setEvaluator(FlutterJsEvaluator());
  runApp(MyApp());
}
```

## Advanced Usage

### Custom Components

Flutter Formio provides a powerful plugin system for registering custom widgets. You can:
- **Override default components** with custom implementations
- **Add entirely new component types** not in Form.io standard
- **Customize behavior** while maintaining Form.io compatibility

#### Step 1: Create Your Component

Create a StatelessWidget or StatefulWidget that follows Form.io patterns:

```dart
import 'package:flutter/material.dart';
import 'package:formio_api/formio_api.dart';

class CustomRatingComponent extends StatefulWidget {
  final ComponentModel component;  // Form.io component definition
  final int? value;                // Current value
  final ValueChanged<int> onChanged; // Value change callback
  
  const CustomRatingComponent({
    super.key,
    required this.component,
    required this.value,
    required this.onChanged,
  });
  
  @override
  State<CustomRatingComponent> createState() => _CustomRatingComponentState();
}

class _CustomRatingComponentState extends State<CustomRatingComponent> {
  int _currentRating = 0;
  
  @override
  void initState() {
    super.initState();
    _currentRating = widget.value ?? 0;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show label unless hideLabel is true
        if (!widget.component.hideLabel)
          Text(widget.component.label),
        
        // Your custom UI
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return IconButton(
              icon: Icon(
                starValue <= _currentRating ? Icons.star : Icons.star_border,
                color: starValue <= _currentRating ? Colors.amber : Colors.grey,
              ),
              onPressed: widget.component.disabled 
                ? null 
                : () {
                    setState(() => _currentRating = starValue);
                    widget.onChanged(starValue);
                  },
            );
          }),
        ),
        
        // Show description if present
        if (widget.component.description?.isNotEmpty ?? false)
          Text(
            widget.component.description!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
```

#### Step 2: Create a Component Builder

Implement `FormioComponentBuilder` to tell the factory how to build your component:

```dart
import 'package:formio/flutter_formio.dart';

class RatingComponentBuilder implements FormioComponentBuilder {
  const RatingComponentBuilder();
  
  @override
  Widget build(FormioComponentBuildContext context) {
    return CustomRatingComponent(
      component: context.component,
      value: context.value is int ? context.value : null,
      onChanged: (rating) => context.onChanged(rating),
    );
  }
}
```

**Alternative: Use FunctionComponentBuilder for simpler cases**

```dart
FunctionComponentBuilder((context) {
  return CustomRatingComponent(
    component: context.component,
    value: context.value,
    onChanged: context.onChanged,
  );
})
```

#### Step 3: Register Component (Before runApp)

```dart
void main() {
  // Register new custom component type 'rating'
  ComponentFactory.register(
    'rating',
    const RatingComponentBuilder(),
  );
  
  // Override default 'textfield' component
  ComponentFactory.register(
    'textfield',
    const MyCustomTextFieldBuilder(),
  );
  
  // Or register multiple at once:
  ComponentFactory.initialize({
    'rating': const RatingComponentBuilder(),
    'textfield': const CustomTextFieldBuilder(),
    'select': const MyCustomSelectBuilder(),
  });
  
  runApp(MyApp());
}
```

### Using Custom Components in Forms

Once registered, use your custom components in Form.io JSON:

```json
{
  "type": "rating",
  "key": "satisfaction",
  "label": "How satisfied are you?",
  "defaultValue": 0,
  "validate": {
    "required": true
  }
}
```

The renderer will automatically use your `RatingComponentBuilder` when it encounters `type: "rating"`.

### Component Best Practices

1. **Respect component.disabled**: Disable interactions when true
2. **Show label conditionally**: Check `component.hideLabel`
3. **Display description**: Show `component.description` if present
4. **Handle validation**: Consider `component.required` and other validators
5. **Type safety**: Cast/validate `context.value` to expected type

### FormioComponentBuildContext

The context provides everything needed to build a component:

```dart
context.component    // ComponentModel with all Form.io settings
context.value        // Current value (dynamic, cast as needed)
context.onChanged    // Callback to update value: (newValue) => void
context.formData     // Access to entire form state (if needed)
```

### Localization

```dart
class GermanFormioLocalizations implements FormioLocalizations {
  const GermanFormioLocalizations();
  
  @override
  String get submit => 'Absenden';
  
  @override
  String get cancel => 'Abbrechen';
  
  // ... implement all getters
}

// Use in your app
MaterialApp(
  localizationsDelegates: [
    DefaultFormioLocalizations.delegate,
    // Your custom delegate
  ],
  // ...
)
```

### Wizard Forms

```dart
FormRenderer(
  form: wizardForm,
  wizardConfig: WizardConfig(
    showNavigation: true,
    showProgressBar: true,
  ),
  onSubmit: (data) => print('Wizard completed: $data'),
)
```

### File Uploads

```dart
FormRenderer(
  form: formWithFiles,
  onFilePick: (allowMultiple, allowedExtensions) async {
    // Use file_picker or image_picker
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      allowedExtensions: allowedExtensions,
    );
    
    return result?.files.map((file) => FileData(
      name: file.name,
      bytes: file.bytes,
      path: file.path,
    )).toList();
  },
)
```

## Components

### Basic Input
- Text Field
- Text Area  
- Number
- Password
- Email
- URL
- Phone Number

### Selection
- Select / Dropdown
- Radio
- Checkbox
- Select Boxes

### Date & Time
- Date
- Time
- DateTime
- Day

### Advanced Input
- Tags
- Currency
- Signature
- Survey

### Layout
- HTML
- Content
- Columns
- Field Set
- Panel
- Well
- Tabs

### Data
- Data Grid
- Edit Grid
- Data Map
- Container
- Tree

### Special
- Button
- File
- Hidden
- ReCAPTCHA

## Packages

This package depends on [`formio_api`](https://pub.dev/packages/formio_api) for business logic and API integration. You can use `formio_api` independently in pure Dart projects.

## Migration from v1.x

See [MIGRATION.md](MIGRATION.md) for upgrade instructions.

## Examples

Check the `/example` folder for:
- Basic form rendering
- Wizard forms
- Custom components
- API integration
- Localization

## API Documentation

For API integration (forms, submissions, users):
- See [`formio_api` documentation](https://pub.dev/packages/formio_api)
- [Form.io API Reference](https://apidocs.form.io/)

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## License

[Your License]

## Links

- [Form.io Documentation](https://help.form.io/)
- [GitHub Repository](https://github.com/mskayali/formio_flutter)
- [Issue Tracker](https://github.com/mskayali/formio_flutter/issues)
- [formio_api Package](https://pub.dev/packages/formio_api)
