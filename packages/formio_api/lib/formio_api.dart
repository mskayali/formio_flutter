/// Entry point for the formio_api package.
///
/// Pure Dart client library for Form.io REST API integration.
/// This library provides models, services, and network layer for interacting
/// with Form.io backend without any Flutter dependencies.
///
/// Use this package in:
/// - Flutter applications (via flutter_formio package)
/// - Pure Dart applications (CLI tools, backend services, etc.)
/// - Any Dart project that needs Form.io API integration
///
/// Example usage:
/// ```dart
/// import 'package:formio_api/formio_api.dart';
///
/// void main() async {
///   ApiClient.setBaseUrl(Uri.parse('https://examples.form.io'));
///   final formService = FormService(ApiClient());
///   final forms = await formService.fetchForms();
///   print('Loaded ${forms.length} forms');
/// }
/// ```

library formio_api;

// Core
export 'src/core/calculation_evaluator.dart';
export 'src/core/conditional_evaluator.dart';
export 'src/core/constants.dart';
export 'src/core/exceptions.dart';
export 'src/core/interpolation_utils.dart';
export 'src/core/js_evaluator.dart';
export 'src/core/js_evaluator_interface.dart';
export 'src/core/template_parser.dart';
export 'src/core/utils.dart';
// Models
export 'src/models/action.dart';
export 'src/models/component.dart';
export 'src/models/file_data.dart';
export 'src/models/form.dart';
export 'src/models/formio_locale_interface.dart';
export 'src/models/role.dart';
export 'src/models/submission.dart';
export 'src/models/user.dart';
export 'src/models/wizard_config.dart';
// Networking
export 'src/network/api_client.dart';
export 'src/network/endpoints.dart';
// Services
export 'src/services/action_service.dart';
export 'src/services/auth_service.dart';
export 'src/services/datasource_service.dart';
export 'src/services/form_service.dart';
export 'src/services/submission_service.dart';
export 'src/services/user_service.dart';
