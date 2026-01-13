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
export 'src/widgets/components/address_component.dart';
export 'src/widgets/components/alert_component.dart';
export 'src/widgets/components/button_component.dart';
export 'src/widgets/components/captcha_component.dart';
export 'src/widgets/components/checkbox_component.dart';
export 'src/widgets/components/columns_component.dart';
export 'src/widgets/components/container_component.dart';
export 'src/widgets/components/content_component.dart';
export 'src/widgets/components/currency_component.dart';
export 'src/widgets/components/custom_component.dart';
export 'src/widgets/components/data_grid_component.dart';
export 'src/widgets/components/data_map_component.dart';
export 'src/widgets/components/datasource_component.dart';
export 'src/widgets/components/datatable_component.dart';
export 'src/widgets/components/date_component.dart';
export 'src/widgets/components/datetime_component.dart';
export 'src/widgets/components/day_component.dart';
export 'src/widgets/components/dynamic_wizard_component.dart';
export 'src/widgets/components/edit_grid_component.dart';
export 'src/widgets/components/email_component.dart';
export 'src/widgets/components/fieldset_component.dart';
export 'src/widgets/components/file_component.dart';
export 'src/widgets/components/form_component.dart';
export 'src/widgets/components/hidden_component.dart';
export 'src/widgets/components/html_element_component.dart';
export 'src/widgets/components/nested_form_component.dart';
export 'src/widgets/components/number_component.dart';
export 'src/widgets/components/panel_component.dart';
export 'src/widgets/components/password_component.dart';
export 'src/widgets/components/phone_number_component.dart';
export 'src/widgets/components/radio_component.dart';
export 'src/widgets/components/review_page_component.dart';
export 'src/widgets/components/select_boxes_component.dart';
export 'src/widgets/components/select_component.dart';
export 'src/widgets/components/signature_component.dart';
export 'src/widgets/components/sketchpad_component.dart';
export 'src/widgets/components/survey_component.dart';
export 'src/widgets/components/table_component.dart';
export 'src/widgets/components/tabs_component.dart';
export 'src/widgets/components/tagpad_component.dart';
export 'src/widgets/components/tags_component.dart';
export 'src/widgets/components/text_field_component.dart';
export 'src/widgets/components/time_component.dart';
export 'src/widgets/components/unknown_component.dart';
export 'src/widgets/components/url_component.dart';
export 'src/widgets/components/well_component.dart';

// Note: Other 35+ components are available via ComponentFactory
// Users can import specific components as needed from src/widgets/components/
