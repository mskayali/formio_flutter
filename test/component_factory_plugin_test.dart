import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../formio.dart';

void main() {
  group('ComponentFactory Plugin System', () {
    setUp(() {
      // Clear any registrations before each test
      // Note: In a real scenario, we'd need a clear() method
      // For now, we'll just test on a clean slate
    });

    test('should register a custom component builder', () {
      // Create a simple custom builder
      final builder = FunctionComponentBuilder((context) {
        return const Text('Custom Component');
      });

      // Register it
      ComponentFactory.register('customType', builder);

      // Verify it's registered
      expect(ComponentFactory.isRegistered('customType'), isTrue);
    });

    test('should check if component is not registered', () {
      expect(ComponentFactory.isRegistered('nonExistentType'), isFalse);
    });

    test('should allow bulk initialization', () {
      final builders = {
        'type1': FunctionComponentBuilder((context) => const Text('Type 1')),
        'type2': FunctionComponentBuilder((context) => const Text('Type 2')),
      };

      ComponentFactory.initialize(builders);

      expect(ComponentFactory.isRegistered('type1'), isTrue);
      expect(ComponentFactory.isRegistered('type2'), isTrue);
    });

    test('should unregister a component builder', () {
      final builder = FunctionComponentBuilder((context) {
        return const Text('Custom Component');
      });

      // Register
      ComponentFactory.register('customType', builder);
      expect(ComponentFactory.isRegistered('customType'), isTrue);

      // Unregister
      ComponentFactory.unregister('customType');
      expect(ComponentFactory.isRegistered('customType'), isFalse);
    });

    testWidgets('should use custom component builder when registered', (WidgetTester tester) async {
      // Register a custom textfield that shows a unique identifier
      final customBuilder = FunctionComponentBuilder((context) {
        return const Text('CUSTOM_TEXTFIELD_MARKER');
      });

      ComponentFactory.register('textfield', customBuilder);

      // Create a component model
      final component = ComponentModel(
        type: 'textfield',
        key: 'testField',
        label: 'Test Field',
        required: false,
        raw: {},
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComponentFactory.build(
              component: component,
              value: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Should find our custom marker
      expect(find.text('CUSTOM_TEXTFIELD_MARKER'), findsOneWidget);

      // Clean up
      ComponentFactory.unregister('textfield');
    });

    testWidgets('should fall back to default when no custom builder is registered', (WidgetTester tester) async {
      // Ensure textfield is not custom registered
      ComponentFactory.unregister('textfield');

      // Create a component model
      final component = ComponentModel(
        type: 'textfield',
        key: 'testField',
        label: 'Test Field',
        required: false,
        raw: {},
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComponentFactory.build(
              component: component,
              value: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Should find the default textfield (by checking for TextFormField)
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should pass context parameters to custom builder', (WidgetTester tester) async {
      FormioComponentBuildContext? capturedContext;

      // Create a custom builder that captures the context
      final customBuilder = FunctionComponentBuilder((context) {
        capturedContext = context;
        return const Text('Test');
      });

      ComponentFactory.register('customType', customBuilder);

      final component = ComponentModel(
        type: 'customType',
        key: 'testKey',
        label: 'Test Label',
        required: false,
        raw: {},
      );

      const testValue = 'test value';
      final testFormData = {'field1': 'value1'};

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComponentFactory.build(
              component: component,
              value: testValue,
              onChanged: (_) {},
              formData: testFormData,
            ),
          ),
        ),
      );

      // Verify context was passed correctly
      expect(capturedContext, isNotNull);
      expect(capturedContext!.component.key, equals('testKey'));
      expect(capturedContext!.value, equals(testValue));
      expect(capturedContext!.formData, equals(testFormData));

      // Clean up
      ComponentFactory.unregister('customType');
    });

    testWidgets('should allow overriding default components', (WidgetTester tester) async {
      // Register custom number component
      final customBuilder = FunctionComponentBuilder((context) {
        return Text('CUSTOM_NUMBER_${context.component.label}');
      });

      ComponentFactory.register('number', customBuilder);

      final component = ComponentModel(
        type: 'number',
        key: 'amount',
        label: 'Amount',
        required: false,
        raw: {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComponentFactory.build(
              component: component,
              value: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Should use custom implementation
      expect(find.text('CUSTOM_NUMBER_Amount'), findsOneWidget);

      // Clean up
      ComponentFactory.unregister('number');
    });

    test('should allow multiple registrations (last one wins)', () {
      final builder1 = FunctionComponentBuilder((context) => const Text('V1'));
      final builder2 = FunctionComponentBuilder((context) => const Text('V2'));

      ComponentFactory.register('mytype', builder1);
      ComponentFactory.register('mytype', builder2);

      expect(ComponentFactory.isRegistered('mytype'), isTrue);
      // Note: We can't easily test which one is active without building,
      // but we verify the registration doesn't error out

      ComponentFactory.unregister('mytype');
    });
  });
}
