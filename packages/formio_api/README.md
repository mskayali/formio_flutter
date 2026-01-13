# formio_api

Pure Dart client library for [Form.io](https://form.io) REST API integration.

## Features

- 🎯 **Pure Dart**: No Flutter dependencies - works in any Dart environment
- 📡 **Complete API Coverage**: Forms, submissions, users, roles, actions
- 🔐 **Authentication**: JWT-based auth with token management
- 🌐 **Network Layer**: Built on Dio with interceptors and logging
- 📦 **Type-Safe Models**: Full Dart models for all Form.io entities
- ⚙️ **Business Logic**: Conditional evaluation, calculations, interpolation

## Installation

```yaml
dependencies:
  formio_api: ^2.0.0
```

## Usage

### Basic Example

```dart
import 'package:formio_api/formio_api.dart';

void main() async {
  // Configure API client
  ApiClient.setBaseUrl(Uri.parse('https://examples.form.io'));
  
  // Fetch forms
  final formService = FormService(ApiClient());
  final forms = await formService.fetchForms();
  
  print('Loaded ${forms.length} forms');
  
  // Get a specific form
  final form = await formService.fetchForm('user');
  print('Form: ${form.title}');
  
  // Submit data
  final submissionService = SubmissionService(ApiClient());
  await submissionService.submit('user', {
    'firstName': 'John',
    'lastName': 'Doe',
    'email': 'john@example.com',
  });
}
```

### Authentication

```dart
final authService = AuthService(ApiClient());

// Login
final user = await authService.login('user@example.com', 'password');
print('Logged in as: ${user.email}');

// The token is automatically stored and used for subsequent requests
```

### Working with Forms

```dart
final formService = FormService(ApiClient());

// List all forms
final forms = await formService.fetchForms();

// Get specific form
final form = await formService.fetchForm('formPath');

// Access form components
for (final component in form.components) {
  print('${component.label}: ${component.type}');
}
```

### Submissions

```dart
final service = SubmissionService(ApiClient());

// Create submission
await service.submit('formPath', {'field': 'value'});

// List submissions
final submissions = await service.fetchSubmissions('formPath');

// Update submission
await service.updateSubmission('formPath', 'submissionId', {'field': 'newValue'});

// Delete submission
await service.deleteSubmission('formPath', 'submissionId');
```

## Advanced Features

### Conditional Logic Evaluation

```dart
import 'package:formio_api/formio_api.dart';

final conditional = {
  'show': 'true',
  'when': 'country',
  'eq': 'USA'
};

final formData = {'country': 'USA'};

final shouldShow = ConditionalEvaluator.shouldShow(conditional, formData);
print('Show component: $shouldShow'); // true
```

### Calculated Values

```dart
final calculateValue = 'value = data.price * data.quantity';
final formData = {'price': 10.0, 'quantity': 5};

final result = CalculationEvaluator.evaluate(calculateValue, formData);
print('Total: $result'); // 50.0
```

## API Reference

### Services

- **`FormService`**: Manage forms (list, get, create, update, delete)
- **`SubmissionService`**: Handle form submissions (CRUD operations)
- **`AuthService`**: User authentication (login, logout, register)
- **`UserService`**: User management
- **`ActionService`**: Form actions and webhooks

### Models

- **`FormModel`**: Form definition with components
- **`ComponentModel`**: Individual form components
- **`SubmissionModel`**: Form submission data
- **`UserModel`**: User accounts
- **`ActionModel`**: Form actions
- **`RoleModel`**: User roles

### Core Utilities

- **`ConditionalEvaluator`**: Evaluate component conditional logic
- **`CalculationEvaluator`**: Calculate field values
- **`InterpolationUtils`**: String interpolation with form data

## For Flutter Apps

If you're building a Flutter application, use the [`flutter_formio`](https://pub.dev/packages/flutter_formio) package instead, which includes:
- All formio_api functionality
- Pre-built Flutter widgets for rendering forms
- Material Design components
- Form validation UI
- Custom component system

## License

[License information]

## Contributing

Contributions welcome! Please read our contributing guidelines.
