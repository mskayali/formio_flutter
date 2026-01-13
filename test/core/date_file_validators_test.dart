// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';

import '../../formio.dart';

void main() {
  group('Date/Time Validators', () {
    test('minDate - valid date', () {
      final date = DateTime(2024, 6, 15);
      final minDate = DateTime(2024, 1, 1);

      expect(FormioValidators.minDate(date, minDate), isNull);
    });

    test('minDate - invalid date (too early)', () {
      final date = DateTime(2023, 12, 31);
      final minDate = DateTime(2024, 1, 1);

      expect(
        FormioValidators.minDate(date, minDate, fieldName: 'Start Date'),
        contains('must be on or after'),
      );
    });

    test('maxDate - valid date', () {
      final date = DateTime(2024, 6, 15);
      final maxDate = DateTime(2024, 12, 31);

      expect(FormioValidators.maxDate(date, maxDate), isNull);
    });

    test('maxDate - invalid date (too late)', () {
      final date = DateTime(2025, 1, 1);
      final maxDate = DateTime(2024, 12, 31);

      expect(
        FormioValidators.maxDate(date, maxDate, fieldName: 'End Date'),
        contains('must be on or before'),
      );
    });

    test('dateRange - valid date in range', () {
      final date = DateTime(2024, 6, 15);
      final minDate = DateTime(2024, 1, 1);
      final maxDate = DateTime(2024, 12, 31);

      expect(FormioValidators.dateRange(date, minDate, maxDate), isNull);
    });

    test('dateRange - invalid date (before min)', () {
      final date = DateTime(2023, 12, 31);
      final minDate = DateTime(2024, 1, 1);
      final maxDate = DateTime(2024, 12, 31);

      expect(
        FormioValidators.dateRange(date, minDate, maxDate),
        isNotNull,
      );
    });

    test('minYear - valid year', () {
      final date = DateTime(2024, 1, 1);
      expect(FormioValidators.minYear(date, 2020), isNull);
    });

    test('minYear - invalid year (too early)', () {
      final date = DateTime(2019, 1, 1);
      expect(
        FormioValidators.minYear(date, 2020),
        contains('must be 2020 or later'),
      );
    });

    test('maxYear - valid year', () {
      final date = DateTime(2024, 1, 1);
      expect(FormioValidators.maxYear(date, 2030), isNull);
    });

    test('maxYear - invalid year (too late)', () {
      final date = DateTime(2031, 1, 1);
      expect(
        FormioValidators.maxYear(date, 2030),
        contains('must be 2030 or earlier'),
      );
    });

    test('null dates should pass validation', () {
      final minDate = DateTime(2024, 1, 1);
      final maxDate = DateTime(2024, 12, 31);

      expect(FormioValidators.minDate(null, minDate), isNull);
      expect(FormioValidators.maxDate(null, maxDate), isNull);
      expect(FormioValidators.minYear(null, 2020), isNull);
      expect(FormioValidators.maxYear(null, 2030), isNull);
    });
  });

  group('File Validators', () {
    test('fileSize - valid size within range', () {
      const size = 500 * 1024; // 500 KB
      const minSize = 100 * 1024; // 100 KB
      const maxSize = 1024 * 1024; // 1 MB

      expect(
        FormioValidators.fileSize(size, minSize: minSize, maxSize: maxSize),
        isNull,
      );
    });

    test('fileSize - too small', () {
      const size = 50 * 1024; // 50 KB
      const minSize = 100 * 1024; // 100 KB

      expect(
        FormioValidators.fileSize(size, minSize: minSize),
        contains('must be at least'),
      );
    });

    test('fileSize - too large', () {
      const size = 2 * 1024 * 1024; // 2 MB
      const maxSize = 1024 * 1024; // 1 MB

      expect(
        FormioValidators.fileSize(size, maxSize: maxSize),
        contains('must not exceed'),
      );
    });

    test('fileSize - formats correctly', () {
      expect(
        FormioValidators.fileSize(100, minSize: 1024),
        contains('1.0 KB'),
      );

      expect(
        FormioValidators.fileSize(100, maxSize: 1024 * 1024),
        isNull, // Size is below max
      );
    });

    test('filePattern - valid extension', () {
      expect(
        FormioValidators.filePattern('document.pdf', '.pdf,.doc,.docx'),
        isNull,
      );

      expect(
        FormioValidators.filePattern('image.PNG', '.jpg,.png,.gif'),
        isNull, // Case insensitive
      );
    });

    test('filePattern - invalid extension', () {
      expect(
        FormioValidators.filePattern('script.exe', '.pdf,.doc,.docx'),
        contains('File type not allowed'),
      );
    });

    test('filePattern - MIME type matching', () {
      expect(
        FormioValidators.filePattern('document.pdf', 'application/pdf'),
        isNull,
      );

      expect(
        FormioValidators.filePattern('image.jpg', 'image/jpeg'),
        isNull,
      );
    });

    test('filePattern - multiple patterns', () {
      expect(
        FormioValidators.filePattern(
          'document.docx',
          '.pdf,.doc,.docx,application/pdf',
        ),
        isNull,
      );
    });

    test('null files should pass validation', () {
      expect(FormioValidators.fileSize(null, minSize: 100), isNull);
      expect(FormioValidators.filePattern(null, '.pdf'), isNull);
      expect(FormioValidators.filePattern('', '.pdf'), isNull);
    });
  });

  group('Helper Methods', () {
    test('fileSize formatting - bytes', () {
      final result = FormioValidators.fileSize(512, minSize: 1024);
      expect(result, contains('1.0 KB')); // Min size is formatted
    });

    test('fileSize formatting - kilobytes', () {
      final result = FormioValidators.fileSize(512 * 1024, minSize: 1024 * 1024);
      expect(result, contains('1.0 MB')); // Min size is formatted
    });

    test('fileSize formatting - megabytes', () {
      final result = FormioValidators.fileSize(512 * 1024 * 1024, maxSize: 256 * 1024 * 1024);
      expect(result, contains('256.0 MB')); // Max size is formatted
    });
  });
}
