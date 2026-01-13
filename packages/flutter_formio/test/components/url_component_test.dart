// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:formio/formio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UrlComponent', () {
    testWidgets('renders URL input field', (WidgetTester tester) async {
      // Arrange
      final component = ComponentModel.fromJson({
        'key': 'website',
        'type': 'url',
        'label': 'Website',
        'input': true,
      });

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: UrlComponent(
            component: component,
            value: null,
            onChanged: (val) {},
          ),
        ),
      ));

      // Assert
      expect(find.text('Website'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.link), findsOneWidget);
    });

    testWidgets('validates URL format', (WidgetTester tester) async {
      // Arrange
      final component = ComponentModel.fromJson({
        'key': 'website',
        'type': 'url',
        'label': 'Website',
        'input': true,
        'validate': {'required': true},
      });

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: UrlComponent(
            component: component,
            value: null,
            onChanged: (_) {},
          ),
        ),
      ));

      final formField = tester.widget<TextFormField>(find.byType(TextFormField));

      // Assert: Invalid URL
      expect(formField.validator!('invalid-url'), isNotNull);
      expect(formField.validator!('notaurl'), isNotNull);

      // Assert: Valid URLs
      expect(formField.validator!('https://example.com'), isNull);
      expect(formField.validator!('http://www.google.com'), isNull);
    });

    testWidgets('updates value on input', (WidgetTester tester) async {
      // Arrange
      final component = ComponentModel.fromJson({
        'key': 'website',
        'type': 'url',
        'label': 'Website',
        'input': true,
      });

      String? capturedValue;

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: UrlComponent(
            component: component,
            value: null,
            onChanged: (val) => capturedValue = val,
          ),
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.pump();

      // Assert
      expect(capturedValue, equals('https://example.com'));
    });
  });
}
