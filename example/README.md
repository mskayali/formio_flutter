# Form.io Flutter - Example App

A live demonstration of the Form.io Flutter package with real API integration.

## Features

This example app demonstrates:

✅ **Live API Integration** - Fetches real forms from Form.io server  
✅ **Form List View** - Browse all available forms  
✅ **Form Rendering** - Full FormRenderer with all components  
✅ **JSON View** - Toggle to see form structure and data  
✅ **Submission Handling** - Submit forms and see results  
✅ **Error Handling** - Graceful error states and retry  

## Running the Example

### Prerequisites

- Flutter SDK 3.0+
- Access to a Form.io server (default: `https://examples.form.io`)

### Steps

1. **Navigate to example directory:**
   ```bash
   cd example
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # macOS
   flutter run -d macos
   
   # Web
   flutter run -d chrome
   
   # iOS (requires Xcode)
   flutter run -d ios
   
   # Android (requires Android Studio)
   flutter run -d android
   ```

### Configuration

To use your own Form.io server, edit `lib/main.dart`:

```dart
ApiClient.setBaseUrl(Uri.parse('https://your-server.form.io'));
```

## App Structure

```
example/
└── lib/
    └── main.dart       # Main app with two pages:
                        # - FormListPage: Lists all forms
                        # - FormDetailPage: Displays form
```

### FormListPage

- Fetches all forms from API on startup
- Shows loading indicator while fetching
- Displays error state with retry button
- Lists forms with title, path, and component count
- Tap any form to open it

### FormDetailPage

- Renders the full form with FormRenderer
- Toggle JSON view to see:
  - Form definition (structure)
  - Current form data (values)
- Submit button with visual feedback
- Success/error snackbars

## Testing Features

### 1. All Components
Navigate through forms to test all 41 component types:
- Text inputs (TextField, TextArea, Email, URL)
- Numbers (Number, Currency, PhoneNumber)
- Dates (DateTime, Day, Time)
- Selections (Select, Radio, Checkbox, SelectBoxes)
- Layout (Panel, Tabs, Columns, Table)
- Special (File, Signature, Tags, Address, Alert)

### 2. Validation
Test validation by:
- Leaving required fields empty
- Entering invalid formats (email, URL, phone)
- Testing min/max length constraints
- Testing word count limits

### 3. Conditional Logic
- Fill in forms with conditional fields
- Watch components show/hide based on values

### 4. Calculated Values
- Forms with auto-calculated fields (e.g., totals)
- Values update automatically as you type

### 5. Multi-Page Wizards
- Forms with `display: 'wizard'`
- Navigate between pages
- Validation before proceeding

## Debugging

### View Console Output

The app logs helpful information:
- `✅ Loaded X forms from API` - Successful form fetch
- `📝 Form data changed: ...` - Form values updated
- `✅ Form submitted!` - Form submission
- `📦 Submission data: {...}` - Full submission payload

### Common Issues

**No forms showing:**
- Check internet connection
- Verify server URL is correct
- Check server is accessible

**Components not rendering:**
- Check browser/terminal console for errors
- Verify component type is supported
- Check JSON structure is valid

**Validation not working:**
- Check `validate` object in component JSON
- Verify validator configuration

## Live Testing Checklist

- [ ] Form list loads successfully
- [ ] Can open individual forms
- [ ] All components render correctly
- [ ] Validation works as expected
- [ ] Conditional logic shows/hides fields
- [ ] Calculated values auto-update
- [ ] Can submit forms
- [ ] JSON view shows correct data
- [ ] Error states display properly
- [ ] Can retry after errors

## Example Forms

The demo connects to a test server with sample forms including:
- Contact forms
- Registration wizards  
- Survey forms
- Data collection forms
- Shopping cart calculators

## Next Steps

Explore the main package documentation for:
- Creating custom forms
- Advanced validation
- API integration
- Production deployment

## Support

Found a bug? [Open an issue](https://github.com/mskayali/formio_flutter/issues)
