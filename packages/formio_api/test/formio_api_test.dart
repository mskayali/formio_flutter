import 'package:test/test.dart';
import 'package:formio_api/formio_api.dart';

void main() {
  group('formio_api Package', () {
    test('should export core models', () {
      expect(ComponentModel, isNotNull);
      expect(FormModel, isNotNull);
      expect(SubmissionModel, isNotNull);
      expect(UserModel, isNotNull);
    });

    test('should export services', () {
      final apiClient = ApiClient();
      expect(FormService(apiClient), isNotNull);
      expect(SubmissionService(apiClient), isNotNull);
      expect(AuthService(apiClient), isNotNull);
    });

    test('should export core utilities', () {
      expect(FormioUtils.isNullOrEmpty(null), isTrue);
      expect(FormioUtils.isNullOrEmpty(''), isTrue);
      expect(FormioUtils.isNullOrEmpty('test'), isFalse);
    });

    test('should provide default locale', () {
      const locale = DefaultFormioLocale();
      expect(locale.submit, equals('Submit'));
      expect(locale.fieldRequired, equals('This field is required'));
    });

    test('should provide JS evaluator interface', () {
      const evaluator = NoOpJsEvaluator();
      expect(evaluator.evaluate('1 + 1', {}), isNull); // NoOp returns null
    });

    test('should allow setting custom JS evaluator', () {
      final customEvaluator = _TestJsEvaluator();
      JavaScriptEvaluator.setEvaluator(customEvaluator);
      
      final result = JavaScriptEvaluator.evaluate('test', {});
      expect(result, equals('custom_result'));
      
      // Reset to no-op
      JavaScriptEvaluator.setEvaluator(const NoOpJsEvaluator());
    });

    test('should create component model from JSON', () {
      final json = {
        'type': 'textfield',
        'key': 'firstName',
        'label': 'First Name',
        'validate': {'required': true},
      };

      final component = ComponentModel.fromJson(json);
      expect(component.type, equals('textfield'));
      expect(component.key, equals('firstName'));
      expect(component.label, equals('First Name'));
      expect(component.required, isTrue);
    });

    test('should evaluate simple conditional logic', () {
      final conditional = {
        'show': 'true',
        'when': 'country',
        'eq': 'USA',
      };
      final formData = {'country': 'USA'};

      expect(ConditionalEvaluator.shouldShow(conditional, formData), isTrue);
    });
  });
}

/// Test JS evaluator for testing dependency injection
class _TestJsEvaluator implements JsEvaluator {
  @override
  dynamic evaluate(String code, Map<String, dynamic> context) {
    return 'custom_result';
  }

  @override
  void validateCode(String code) {
    // No validation
  }

  @override
  void dispose() {
    // Nothing to dispose
  }
}
