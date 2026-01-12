/// Entry point for the formio package.
///
/// This library exports all core modules and widgets needed to render
/// dynamic forms using the Form.io schema format in Flutter.
///
/// You can import this file to access form renderer, models, services,
/// and all widget components from a single location.
///
/// Example usage:
/// ```dart
/// import 'package:formio/formio.dart';
/// ```

library formio;

// NOTE: other component exports can be added here if needed

// Core
export 'core/constants.dart';
export 'core/exceptions.dart';
export 'core/utils.dart';

// Models
export 'models/action.dart';
export 'models/component.dart';
export 'models/form.dart';
export 'models/role.dart';
export 'models/submission.dart';
export 'models/user.dart';

// Networking
export 'network/api_client.dart';
export 'network/endpoints.dart';

// State
export 'providers/form_provider.dart';

// Services
export 'services/action_service.dart';
export 'services/auth_service.dart';
export 'services/form_service.dart';
export 'services/submission_service.dart';
export 'services/user_service.dart';

// UI
export 'widgets/component_factory.dart';
export 'widgets/components/checkbox_component.dart';
export 'widgets/components/text_field_component.dart';

// Renderer
export  'widgets/form_renderer.dart';
