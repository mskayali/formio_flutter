// ignore_for_file: depend_on_referenced_packages

import 'package:formio/formio.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('CalculationEvaluator', () {
    group('evaluate', () {
      test('evaluates simple JSONLogic calculation', () {
        final calculateConfig = {
          '+': [
            {'var': 'data.a'},
            {'var': 'data.b'}
          ]
        };

        final formData = {'a': 5, 'b': 3};
        final result = CalculationEvaluator.evaluate(calculateConfig, formData);

        expect(result, equals(8));
      });

      test('evaluates multiplication', () {
        final calculateConfig = {
          '*': [
            {'var': 'data.price'},
            {'var': 'data.quantity'}
          ]
        };

        final formData = {'price': 10.5, 'quantity': 3};
        final result = CalculationEvaluator.evaluate(calculateConfig, formData);

        expect(result, equals(31.5));
      });

      test('evaluates complex JSONLogic expression', () {
        // Calculate total with tax: (price * quantity) * 1.08
        final calculateConfig = {
          '*': [
            {
              '*': [
                {'var': 'data.price'},
                {'var': 'data.quantity'}
              ]
            },
            1.08
          ]
        };

        final formData = {'price': 100, 'quantity': 2};
        final result = CalculationEvaluator.evaluate(calculateConfig, formData);

        expect(result, equals(216.0));
      });

      test('returns null for JavaScript expressions', () {
        const calculateConfig = 'value = data.price * data.quantity';
        final formData = {'price': 10, 'quantity': 2};
        final result = CalculationEvaluator.evaluate(calculateConfig, formData);

        expect(result, isNull);
      });

      test('returns null for null config', () {
        final result = CalculationEvaluator.evaluate(null, {});
        expect(result, isNull);
      });
    });

    group('hasCalculation', () {
      test('returns true when calculateValue exists', () {
        final componentRaw = {
          'calculateValue': {
            '+': [1, 2]
          }
        };

        expect(CalculationEvaluator.hasCalculation(componentRaw), isTrue);
      });

      test('returns false when calculateValue does not exist', () {
        final componentRaw = {'label': 'Test'};
        expect(CalculationEvaluator.hasCalculation(componentRaw), isFalse);
      });

      test('returns false for null component', () {
        expect(CalculationEvaluator.hasCalculation(null), isFalse);
      });
    });

    group('allowsOverride', () {
      test('returns true when allowCalculateOverride is true', () {
        final componentRaw = <String, dynamic>{'allowCalculateOverride': true};
        expect(CalculationEvaluator.allowsOverride(componentRaw), isTrue);
      });

      test('returns false when allowCalculateOverride is false', () {
        final componentRaw = <String, dynamic>{'allowCalculateOverride': false};
        expect(CalculationEvaluator.allowsOverride(componentRaw), isFalse);
      });

      test('returns false when allowCalculateOverride does not exist', () {
        final componentRaw = <String, dynamic>{};
        expect(CalculationEvaluator.allowsOverride(componentRaw), isFalse);
      });
    });

    group('extractDependencies', () {
      test('extracts single dependency', () {
        final calculateConfig = {'var': 'data.fieldName'};
        final deps = CalculationEvaluator.extractDependencies(calculateConfig);

        expect(deps, contains('fieldName'));
        expect(deps.length, equals(1));
      });

      test('extracts multiple dependencies', () {
        final calculateConfig = {
          '+': [
            {'var': 'data.price'},
            {'var': 'data.tax'}
          ]
        };

        final deps = CalculationEvaluator.extractDependencies(calculateConfig);

        expect(deps, contains('price'));
        expect(deps, contains('tax'));
        expect(deps.length, equals(2));
      });

      test('extracts dependencies from nested expressions', () {
        final calculateConfig = {
          '*': [
            {
              '+': [
                {'var': 'data.a'},
                {'var': 'data.b'}
              ]
            },
            {'var': 'data.c'}
          ]
        };

        final deps = CalculationEvaluator.extractDependencies(calculateConfig);

        expect(deps, contains('a'));
        expect(deps, contains('b'));
        expect(deps, contains('c'));
        expect(deps.length, equals(3));
      });

      test('returns empty set for non-map config', () {
        final deps = CalculationEvaluator.extractDependencies('string');
        expect(deps.isEmpty, isTrue);
      });
    });
  });
}
