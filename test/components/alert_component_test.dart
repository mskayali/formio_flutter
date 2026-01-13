// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../formio.dart';

void main() {
  group('AlertComponent', () {
    testWidgets('renders error alert', (WidgetTester tester) async {
      // Arrange
      final component = ComponentModel.fromJson({
        'key': 'alert1',
        'type': 'alert',
        'label': '',
        'content': 'This is an error message',
        'alertType': 'error',
      });

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AlertComponent(component: component),
        ),
      ));

      // Assert
      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.textContaining('This is an error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders success alert', (WidgetTester tester) async {
      // Arrange
      final component = ComponentModel.fromJson({
        'key': 'alert2',
        'type': 'alert',
        'label': '',
        'content': 'Operation successful',
        'alertType': 'success',
      });

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AlertComponent(component: component),
        ),
      ));

      // Assert
      expect(find.textContaining('Success'), findsOneWidget);
      expect(find.textContaining('Operation successful'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('renders warning alert', (WidgetTester tester) async {
      // Arrange
      final component = ComponentModel.fromJson({
        'key': 'alert3',
        'type': 'alert',
        'label': '',
        'content': 'Warning message',
        'alertType': 'warning',
      });

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AlertComponent(component: component),
        ),
      ));

      // Assert
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Warning message'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('renders info alert by default', (WidgetTester tester) async {
      // Arrange
      final component = ComponentModel.fromJson({
        'key': 'alert4',
        'type': 'alert',
        'label': '',
        'content': 'Information message',
      });

      // Act
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AlertComponent(component: component),
        ),
      ));

      // Assert
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Information message'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
