// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:formio/flutter_formio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnknownComponent', () {
    testWidgets('renders warning for unsupported component type', (WidgetTester tester) async {
      // Arrange
      final component = ComponentModel.fromJson({
        'key': 'custom',
        'type': 'unsupported_type_xyz',
        'label': 'Custom Field',
        'input': true,
      });

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: UnknownComponent(component: component),
        ),
      ));

      // Assert
      expect(find.textContaining('Unsupported Component'), findsOneWidget);
      expect(find.textContaining('unsupported_type_xyz'), findsOneWidget);
      expect(find.textContaining('custom'), findsOneWidget);
    });

    testWidgets('displays component label when available', (WidgetTester tester) async {
      // Arrange
      final component = ComponentModel.fromJson({
        'key': 'test',
        'type': 'unknown_type',
        'label': 'Test Label',
        'input': true,
      });

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: UnknownComponent(component: component),
        ),
      ));

      // Assert
      expect(find.textContaining('Test Label'), findsOneWidget);
    });
  });
}
