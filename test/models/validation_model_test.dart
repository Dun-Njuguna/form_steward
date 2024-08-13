import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/src/models/validation_model.dart';

void validationModelTests() {
  group('ValidationModel', () {
    late ValidationModel validationModel;
    late Map<String, dynamic> json;

    setUp(() {
      // Set up a sample ValidationModel instance
      validationModel = ValidationModel(
        required: true,
        minLength: 5,
        maxLength: 10,
      );

      // Set up a sample JSON object for deserialization
      json = {
        'required': true,
        'minLength': 5,
        'maxLength': 10,
      };
    });

    test('creates ValidationModel with provided properties', () {
      expect(validationModel.required, isTrue);
      expect(validationModel.minLength, equals(5));
      expect(validationModel.maxLength, equals(10));
    });

    test('creates ValidationModel from JSON', () {
      final validationModelFromJson = ValidationModel.fromJson(json);

      expect(validationModelFromJson.required, isTrue);
      expect(validationModelFromJson.minLength, equals(5));
      expect(validationModelFromJson.maxLength, equals(10));
    });

    test('creates ValidationModel from JSON with missing optional fields', () {
      final jsonWithMissingFields = {
        'required': true,
      };

      final validationModelFromJson =
          ValidationModel.fromJson(jsonWithMissingFields);

      expect(validationModelFromJson.required, isTrue);
      expect(validationModelFromJson.minLength, isNull);
      expect(validationModelFromJson.maxLength, isNull);
    });

    test(
        'creates ValidationModel from JSON with null values for optional fields',
        () {
      final jsonWithNullFields = {
        'required': true,
        'minLength': null,
        'maxLength': null,
      };

      final validationModelFromJson =
          ValidationModel.fromJson(jsonWithNullFields);

      expect(validationModelFromJson.required, isTrue);
      expect(validationModelFromJson.minLength, isNull);
      expect(validationModelFromJson.maxLength, isNull);
    });

    test('throws error on invalid JSON structure', () {
      final invalidJson = {
        'required': 'true', // Incorrect type
      };

      expect(() => ValidationModel.fromJson(invalidJson),
          throwsA(isA<TypeError>()));
    });
  });
}
