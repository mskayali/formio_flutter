# Form.io Flutter - Example App

This example demonstrates the complete usage of the `formio_flutter` package with all its features.

## Features Demonstrated

### 1. **Live API Integration**
- Connects to `https://examples.form.io`
- Fetches and displays real forms
- Renders all form components dynamically

### 2. **Internationalization (i18n)**
The app shows how to configure global locale:

```dart
void main() {
  // Configure Turkish locale
  ComponentFactory.setLocale(FormioLocale.tr());
  
  runApp(const MyApp());
}
```

**Supported Locales:**
- English (default): `FormioLocale()` or `ComponentFactory.setLocale(FormioLocale())`
- Turkish: `ComponentFactory.setLocale(FormioLocale.tr())`
- Custom: `ComponentFactory.setLocale(FormioLocale(submit: 'Custom', ...))`

### 3. **Live Theme Switcher** 🎨

The example app includes an **interactive theme demo** showing full Flutter theme integration:

**How to use:**
1. Run the example app
2. Click the **palette icon (🎨)** in the AppBar
3. Toggle between two preset themes:
   - 🔴 **Red Rounded**: BorderRadius 16px, red color scheme
   - 🟣 **Purple Square**: BorderRadius 4px, purple color scheme

**What it demonstrates:**
- All form components instantly adapt to the new theme
- Input borders, buttons, colors all update automatically
- No component-level configuration needed
- Shows how `ThemeData.colorScheme` and `inputDecorationTheme` work

```dart
// Implementation in main.dart
MaterialApp(
  theme: _isRedTheme ? _redRoundedTheme : _purpleSquareTheme,
  home: FormListPage(...),
)

// All components use Theme.of(context) automatically!
```

This proves that formio_flutter **fully respects Flutter's theming system**.

### 4. **Custom Widget Callbacks** (Optional)

You can provide custom implementations for pickers and data fetchers:

#### Custom File Picker
```dart
FormRenderer(
  form: myForm,
  onFilePick: ({required allowMultiple, allowedExtensions}) async {
    // Use your preferred file picker
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      allowedExtensions: allowedExtensions,
    );
    return result?.files.map((f) => FileData(...)).toList();
  },
)
```

#### Custom Date Picker
```dart
FormRenderer(
  form: myForm,
  onDatePick: ({required initialDate, required firstDate, required lastDate}) async {
    // Use Cupertino, Material, or custom picker
    return await showCupertinoDatePicker(...);
  },
)
```

#### Custom Time Picker
```dart
FormRenderer(
  form: myForm,
  onTimePick: ({required initialTime}) async {
    return await showCustomTimePicker(...);
  },
)
```

## Running the Example

```bash
# Get dependencies
flutter pub get

# Run on your preferred platform
flutter run

# Or specific platform
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d ios       # iOS (requires macOS)
flutter run -d android   # Android
```

## Example Structure

```
example/
├── lib/
│   └── main.dart          # Main app with all features
├── test/
│   ├── widget_test.dart   # Basic widget tests
│   ├── widget_integration_test.dart  # Integration tests
│   └── api_integration_test.dart     # API tests
└── README.md              # This file
```

## What's Included

### Form List Page
- Fetches forms from live API
- Displays form count and components
- Error handling with retry
- Loading states

### Form Detail Page
- Full form rendering with all components
- Real-time form data display
- JSON view toggle
- Form submission handling
- Success/error feedback

### Supported Components (70+)
All Form.io components are rendered:
- **Basic**: TextField, TextArea, Number, Password, Email, URL, PhoneNumber, Tags, Address, DateTime, Day, Time, Currency, Survey
- **Advanced**: Email, URL, PhoneNumber, Tags, Address, DateTime, Day, Time, Currency, Survey  
- **Layout**: HtmlElement, Content, Columns, FieldSet, Panel, Table, Tabs, Well
- **Data**: DataGrid, EditGrid, DataMap, Container, DataTable, DynamicWizard
- **Premium**: Signature, File, Sketchpad, ReviewPage, DataSource
- **Special**: Button, Checkbox, Select, Radio, SelectBoxes, Hidden, Custom

## i18n in Action

When you set a locale, all UI strings change:

**English** (Default):
- Submit, Cancel, Clear, Add Another, Remove Row, etc.

**Turkish** (FormioLocale.tr()):
- Gönder, İptal, Temizle, Başka Ekle, Satırı Kaldır, etc.

## Troubleshooting

### API Connection Issues
The example uses `https://examples.form.io` which requires internet connection. If forms don't load:
1. Check your internet connection
2. Check if the API is accessible
3. Review console logs for detailed errors

### Platform-Specific Issues
- **Web**: Enable CORS if testing locally
- **iOS**: Requires code signing for device testing  
- **Android**: Requires SDK setup

## Learn More

- [Form.io Documentation](https://help.form.io/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Package README](../README.md)
