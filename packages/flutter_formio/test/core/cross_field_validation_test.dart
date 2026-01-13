// ignore_for_file: depend_on_referenced_packages

import 'package:formio/formio.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('Cross-Field Validation', () {
    group('matchField', () {
      test('returns null when values match', () {
        expect(
          FormioValidators.matchField('password123', 'password123', 'Confirm Password', 'Password'),
          isNull,
        );
      });

      test('returns error when values do not match', () {
        final error = FormioValidators.matchField(
          'password123',
          'password456',
          'Confirm Password',
          'Password',
        );
        expect(error, isNotNull);
        expect(error, contains('Confirm Password'));
        expect(error, contains('Password'));
      });

      test('returns null for empty value', () {
        expect(
          FormioValidators.matchField('', 'password123', 'Confirm Password', 'Password'),
          isNull,
        );
      });

      test('returns null for null value', () {
        expect(
          FormioValidators.matchField(null, 'password123', 'Confirm Password', 'Password'),
          isNull,
        );
      });
    });

    group('compareFields', () {
      test('validates greater than operator', () {
        expect(
          FormioValidators.compareFields(10, 5, '>', 'End Value', 'Start Value'),
          isNull,
        );

        expect(
          FormioValidators.compareFields(5, 10, '>', 'End Value', 'Start Value'),
          isNotNull,
        );
      });

      test('validates less than operator', () {
        expect(
          FormioValidators.compareFields(5, 10, '<', 'Start Value', 'End Value'),
          isNull,
        );

        expect(
          FormioValidators.compareFields(10, 5, '<', 'Start Value', 'End Value'),
          isNotNull,
        );
      });

      test('validates greater than or equal operator', () {
        expect(
          FormioValidators.compareFields(10, 10, '>=', 'Value', 'Minimum'),
          isNull,
        );

        expect(
          FormioValidators.compareFields(11, 10, '>=', 'Value', 'Minimum'),
          isNull,
        );

        expect(
          FormioValidators.compareFields(9, 10, '>=', 'Value', 'Minimum'),
          isNotNull,
        );
      });

      test('validates less than or equal operator', () {
        expect(
          FormioValidators.compareFields(10, 10, '<=', 'Value', 'Maximum'),
          isNull,
        );

        expect(
          FormioValidators.compareFields(5, 10, '<=', 'Value', 'Maximum'),
          isNull,
        );

        expect(
          FormioValidators.compareFields(11, 10, '<=', 'Value', 'Maximum'),
          isNotNull,
        );
      });

      test('validates equality operator', () {
        expect(
          FormioValidators.compareFields(10, 10, '==', 'Field 1', 'Field 2'),
          isNull,
        );

        expect(
          FormioValidators.compareFields(10, 5, '==', 'Field 1', 'Field 2'),
          isNotNull,
        );
      });

      test('validates inequality operator', () {
        expect(
          FormioValidators.compareFields(10, 5, '!=', 'Field 1', 'Field 2'),
          isNull,
        );

        expect(
          FormioValidators.compareFields(10, 10, '!=', 'Field 1', 'Field 2'),
          isNotNull,
        );
      });

      test('handles string numeric values', () {
        expect(
          FormioValidators.compareFields('10', '5', '>', 'End', 'Start'),
          isNull,
        );
      });

      test('returns null for non-numeric values', () {
        expect(
          FormioValidators.compareFields('abc', 'def', '>', 'Field 1', 'Field 2'),
          isNull,
        );
      });
    });

    group('fromConfig with matchField', () {
      test('validates matchField from config', () {
        final formData = {
          'password': 'secret123',
          'confirmPassword': 'secret123',
        };

        final validator = FormioValidators.fromConfig(
          {'matchField': 'password'},
          'Confirm Password',
          formData: formData,
        );

        expect(validator!('secret123'), isNull);
        expect(validator('different'), isNotNull);
      });
    });

    group('crossFieldValidator', () {
      test('validates cross-field comparison with custom message', () {
        // This would need proper date parsing in real scenario
        // For now we test the basic structure
        final error = FormioValidators.crossFieldValidator(
          value: 100,
          formData: {'minValue': 50},
          fieldKey: 'value',
          compareFieldKey: 'minValue',
          operator: '>',
          message: 'Value must exceed minimum',
        );

        expect(error, isNull);
      });

      test('uses custom message when provided', () {
        final formData = {'min': 100};

        final error = FormioValidators.crossFieldValidator(
          value: 50,
          formData: formData,
          fieldKey: 'value',
          compareFieldKey: 'min',
          operator: '>',
          message: 'Custom error message',
        );

        expect(error, equals('Custom error message'));
      });
    });
  });
}
