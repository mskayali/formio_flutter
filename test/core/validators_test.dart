import 'package:flutter_test/flutter_test.dart';
import '../../formio.dart';

void main() {
  group('FormioValidators', () {
    group('required', () {
      test('returns error for null value', () {
        expect(FormioValidators.required(null), isNotNull);
        expect(FormioValidators.required(null, fieldName: 'Email'), contains('Email'));
      });

      test('returns error for empty string', () {
        expect(FormioValidators.required(''), isNotNull);
        expect(FormioValidators.required('   '), isNotNull);
      });

      test('returns error for empty list', () {
        expect(FormioValidators.required([]), isNotNull);
      });

      test('returns null for valid value', () {
        expect(FormioValidators.required('test'), isNull);
        expect(FormioValidators.required(123), isNull);
      });
    });

    group('pattern', () {
      test('validates regex pattern correctly', () {
        // Valid pattern matches
        expect(FormioValidators.pattern('ABC1234', r'^[A-Z]{3}\d{4}$'), isNull);
        expect(FormioValidators.pattern('test@example.com', r'^[\w.]+@[\w.]+$'), isNull);

        // Invalid pattern matches
        expect(FormioValidators.pattern('abc1234', r'^[A-Z]{3}\d{4}$'), isNotNull);
        expect(FormioValidators.pattern('invalid', r'^\d+$'), isNotNull);
      });

      test('returns null for empty value', () {
        expect(FormioValidators.pattern('', r'^\d+$'), isNull);
        expect(FormioValidators.pattern(null, r'^\d+$'), isNull);
      });

      test('uses custom error message', () {
        final error = FormioValidators.pattern('abc', r'^\d+$', message: 'Must be numeric');
        expect(error, equals('Must be numeric'));
      });
    });

    group('minLength', () {
      test('validates minimum length correctly', () {
        expect(FormioValidators.minLength('ab', 3), isNotNull);
        expect(FormioValidators.minLength('abc', 3), isNull);
        expect(FormioValidators.minLength('abcd', 3), isNull);
      });

      test('returns null for empty value', () {
        expect(FormioValidators.minLength('', 5), isNull);
        expect(FormioValidators.minLength(null, 5), isNull);
      });

      test('includes field name in error', () {
        final error = FormioValidators.minLength('ab', 5, fieldName: 'Username');
        expect(error, contains('Username'));
        expect(error, contains('5'));
      });
    });

    group('maxLength', () {
      test('validates maximum length correctly', () {
        expect(FormioValidators.maxLength('abcdef', 5), isNotNull);
        expect(FormioValidators.maxLength('abcde', 5), isNull);
        expect(FormioValidators.maxLength('abc', 5), isNull);
      });

      test('returns null for empty value', () {
        expect(FormioValidators.maxLength('', 5), isNull);
      });
    });

    group('minWords', () {
      test('counts words correctly', () {
        expect(FormioValidators.minWords('one', 2), isNotNull);
        expect(FormioValidators.minWords('one two', 2), isNull);
        expect(FormioValidators.minWords('one two three', 2), isNull);
      });

      test('handles extra whitespace', () {
        expect(FormioValidators.minWords('  one   two  ', 2), isNull);
        expect(FormioValidators.minWords('one', 2), isNotNull);
      });

      test('returns null for empty value', () {
        expect(FormioValidators.minWords('', 5), isNull);
      });
    });

    group('maxWords', () {
      test('validates word count correctly', () {
        expect(FormioValidators.maxWords('one two three', 2), isNotNull);
        expect(FormioValidators.maxWords('one two', 2), isNull);
        expect(FormioValidators.maxWords('one', 2), isNull);
      });
    });

    group('email', () {
      test('validates email format correctly', () {
        // Valid emails
        expect(FormioValidators.email('test@example.com'), isNull);
        expect(FormioValidators.email('user.name+tag@example.co.uk'), isNull);

        // Invalid emails
        expect(FormioValidators.email('invalid'), isNotNull);
        expect(FormioValidators.email('test@'), isNotNull);
        expect(FormioValidators.email('@example.com'), isNotNull);
      });

      test('returns null for empty value', () {
        expect(FormioValidators.email(''), isNull);
      });
    });

    group('url', () {
      test('validates URL format correctly', () {
        // Valid URLs
        expect(FormioValidators.url('https://example.com'), isNull);
        expect(FormioValidators.url('http://www.google.com/path?query=1'), isNull);

        // Invalid URLs
        expect(FormioValidators.url('not-a-url'), isNotNull);
        expect(FormioValidators.url('ftp://example.com'), isNotNull);
      });
    });

    group('min', () {
      test('validates minimum numeric value', () {
        expect(FormioValidators.min(5, 10), isNotNull);
        expect(FormioValidators.min(10, 10), isNull);
        expect(FormioValidators.min(15, 10), isNull);
      });

      test('works with decimals', () {
        expect(FormioValidators.min(9.5, 10.0), isNotNull);
        expect(FormioValidators.min(10.5, 10.0), isNull);
      });
    });

    group('max', () {
      test('validates maximum numeric value', () {
        expect(FormioValidators.max(15, 10), isNotNull);
        expect(FormioValidators.max(10, 10), isNull);
        expect(FormioValidators.max(5, 10), isNull);
      });
    });

    group('combine', () {
      test('returns first error encountered', () {
        final error = FormioValidators.combine([
          () => null,
          () => 'Second error',
          () => 'Third error',
        ]);
        expect(error, equals('Second error'));
      });

      test('returns null if all validators pass', () {
        final error = FormioValidators.combine([
          () => null,
          () => null,
          () => null,
        ]);
        expect(error, isNull);
      });
    });

    group('fromConfig', () {
      test('creates validator from config', () {
        final validator = FormioValidators.fromConfig({
          'required': true,
          'minLength': 3,
          'maxLength': 10,
        }, 'Username');

        expect(validator, isNotNull);
        expect(validator!(''), contains('required'));
        expect(validator('ab'), contains('3 characters'));
        expect(validator('12345678901'), contains('10 characters'));
        expect(validator('valid'), isNull);
      });

      test('handles pattern validation', () {
        final validator = FormioValidators.fromConfig({
          'pattern': r'^\d{3}-\d{3}-\d{4}$',
        }, 'Phone');

        expect(validator!('123-456-7890'), isNull);
        expect(validator('invalid'), isNotNull);
      });

      test('handles word count validation', () {
        final validator = FormioValidators.fromConfig({
          'minWords': 2,
          'maxWords': 5,
        }, 'Description');

        expect(validator!('one'), isNotNull); // Too few words
        expect(validator('one two'), isNull);
        expect(validator('one two three four five six'), isNotNull); // Too many words
      });

      test('returns null for empty config', () {
        final validator = FormioValidators.fromConfig({}, 'Field');
        expect(validator, isNull);

        final validator2 = FormioValidators.fromConfig(null, 'Field');
        expect(validator2, isNull);
      });
    });
  });
}
