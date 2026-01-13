import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../formio.dart';

void main() {
  group('FormRenderer', () {
    testWidgets('renders a textfield and triggers onChanged', (WidgetTester tester) async {
      // Arrange: Sample form with one textfield component
      final form = FormModel(
        id: 'form123',
        path: 'testform',
        title: 'Test Form',
        components: [
          ComponentModel.fromJson({'key': 'name', 'type': 'textfield', 'label': 'Full Name', 'input': true}),
        ],
      );

      Map<String, dynamic>? updatedData;

      // Act: Render the form in a test widget
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: FormRenderer(form: form, onChanged: (data) => updatedData = data))));

      // Expect: TextField appears with the given label
      expect(find.text('Full Name'), findsOneWidget);

      // Interact: Enter some text into the field
      await tester.enterText(find.byType(TextField), 'John Doe');
      await tester.pump(); // Re-render

      // Verify: onChanged callback receives updated value
      expect(updatedData, isNotNull);
      expect(updatedData!['name'], equals('John Doe'));
    });
  });
}
