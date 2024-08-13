import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/src/models/field_model.dart';
import 'package:form_steward/src/models/validation_model.dart';

void fieldModelTests() {
  group('FieldModel', () {
    late FieldModel fieldModel;
    late Map<String, dynamic> json;

    setUp(() {
      // Set up a sample FieldModel instance
      fieldModel = FieldModel(
        type: 'text',
        label: 'Username',
        name: 'username',
        validation: ValidationModel(
          required: true,
          minLength: 5,
        ),
      );

      // Set up a sample JSON object for deserialization
      json = {
        'type': 'text',
        'label': 'Username',
        'name': 'username',
        'validation': {
          'required': true,
          'minLength': 5,
        },
      };
    });

    test('creates FieldModel with provided properties', () {
      expect(fieldModel.type, equals('text'));
      expect(fieldModel.label, equals('Username'));
      expect(fieldModel.name, equals('username'));
      expect(fieldModel.validation.required, isTrue);
      expect(fieldModel.validation.minLength, equals(5));
    });

    test('creates FieldModel from JSON', () {
      final fieldModelFromJson = FieldModel.fromJson(json);

      expect(fieldModelFromJson.type, equals('text'));
      expect(fieldModelFromJson.label, equals('Username'));
      expect(fieldModelFromJson.name, equals('username'));
      expect(fieldModelFromJson.validation.required, isTrue);
      expect(fieldModelFromJson.validation.minLength, equals(5));
    });

    test('handles missing properties in JSON', () {
      final incompleteJson = {
        'type': 'text',
        'label': 'Username',
        'name': 'username',
        // Missing validation
      };

      expect(
          () => FieldModel.fromJson(incompleteJson), throwsA(isA<TypeError>()));
    });

    test('throws error on invalid JSON structure', () {
      final invalidJson = {
        'type': 'text',
        'label': 'Username',
        'name': 'username',
        'validation': {
          // Missing required fields
        },
      };

      expect(() => FieldModel.fromJson(invalidJson), throwsA(isA<TypeError>()));
    });
  });
}
