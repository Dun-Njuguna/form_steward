import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/src/models/form_step_model.dart';
import 'package:form_steward/src/models/field_model.dart';
import 'package:form_steward/src/models/validation_model.dart';

void formStepModelTests() {
  group('FormStepModel', () {
    late FormStepModel formStepModel;
    late Map<String, dynamic> json;

    setUp(() {
      // Set up a sample FormStepModel instance with fields
      formStepModel = FormStepModel(
        title: 'Step 1',
        fields: [
          FieldModel(
            type: 'text',
            label: 'Username',
            name: 'username',
            validation: ValidationModel(
              required: true,
              minLength: 5,
            ),
          ),
          FieldModel(
            type: 'number',
            label: 'Age',
            name: 'age',
            validation: ValidationModel(
              required: true,
              minLength: 1,
            ),
          ),
        ],
      );

      // Set up a sample JSON object for deserialization
      json = {
        'title': 'Step 1',
        'fields': [
          {
            'type': 'text',
            'label': 'Username',
            'name': 'username',
            'validation': {
              'required': true,
              'minLength': 5,
            },
          },
          {
            'type': 'number',
            'label': 'Age',
            'name': 'age',
            'validation': {
              'required': true,
              'minLength': 1,
            },
          },
        ],
      };
    });

    test('creates FormStepModel with provided properties', () {
      expect(formStepModel.title, equals('Step 1'));
      expect(formStepModel.fields, hasLength(2));
      expect(formStepModel.fields[0].type, equals('text'));
      expect(formStepModel.fields[0].label, equals('Username'));
      expect(formStepModel.fields[1].type, equals('number'));
      expect(formStepModel.fields[1].label, equals('Age'));
    });

    test('creates FormStepModel from JSON', () {
      final formStepModelFromJson = FormStepModel.fromJson(json);

      expect(formStepModelFromJson.title, equals('Step 1'));
      expect(formStepModelFromJson.fields, hasLength(2));

      final field1 = formStepModelFromJson.fields[0];
      expect(field1.type, equals('text'));
      expect(field1.label, equals('Username'));
      expect(field1.validation.required, isTrue);
      expect(field1.validation.minLength, equals(5));

      final field2 = formStepModelFromJson.fields[1];
      expect(field2.type, equals('number'));
      expect(field2.label, equals('Age'));
      expect(field2.validation.required, isTrue);
      expect(field2.validation.minLength, equals(1));
    });

    test('throws error on invalid JSON structure', () {
      final invalidJson = {
        'title': 'Step 1',
        'fields': [
          {
            'type': 'text',
            'label': 'Username',
            'name': 'username',
            // Missing validation
          },
        ],
      };

      expect(
          () => FormStepModel.fromJson(invalidJson), throwsA(isA<TypeError>()));
    });
  });
}
