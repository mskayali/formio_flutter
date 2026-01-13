/// Entry point for the flutter_formio package.
///
/// Flutter widgets for rendering Form.io forms with full feature parity.
/// This package provides UI components and relies on formio_api for business logic.
///
/// Example usage:
/// ```dart
/// import 'package:flutter_formio/flutter_formio.dart';
///
/// void main() {
///   // Initialize JS evaluator for calculations
///   JavaScriptEvaluator.setEvaluator(FlutterJsEvaluator());
///   
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Scaffold(
///         body: FormRenderer(
///           form: myForm,
///           onSubmit: (data) => print('Submitted: $data'),
///         ),
///       ),
///     );
///   }
/// }
/// ```

library flutter_formio;

// Re-export formio_api for convenience
export 'package:formio_api/formio_api.dart';

// Core Flutter-specific
export 'src/core/flutter_js_evaluator.dart';
export 'src/core/validators.dart';

// Models - Flutter-specific
export 'src/models/file_typedefs.dart';
export 'src/models/formio_localizations.dart';

// Widgets
export 'src/widgets/base_component.dart';
export 'src/widgets/component_factory.dart';
export 'src/widgets/form_renderer.dart';

// Commonly used components
export 'src/widgets/components/button_component.dart';
export 'src/widgets/components/checkbox_component.dart';
export 'src/widgets/components/text_field_component.dart';
export 'src/widgets/components/text_area_component.dart';
export 'src/widgets/components/number_component.dart';
export 'src/widgets/components/email_component.dart';
export 'src/widgets/components/password_component.dart';
export 'src/widgets/components/select_component.dart';
export 'src/widgets/components/radio_component.dart';
export 'src/widgets/components/date_component.dart';
export 'src/widgets/components/datetime_component.dart';

// Note: Other 35+ components are available via ComponentFactory
// Users can import specific components as needed from src/widgets/components/
