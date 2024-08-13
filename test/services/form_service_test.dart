import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/src/models/field_model.dart';
import 'package:form_steward/src/models/form_step_model.dart';
import 'package:form_steward/src/models/validation_model.dart';
import 'package:form_steward/src/services/form_service.dart';

void main() {
  formServiceTests();
}

void formServiceTests() {
  group('FormService', () {
    late FormService formService;

    setUp(() {
      formService = FormService();
    });

    test('loadFormFromJson parses JSON data correctly', () {
      // Arrange
      const jsonString = '''
      {
        "formName": "User Information Form",
        "steps": [
          {
            "title": "Personal Information",
            "fields": [
              {
                "type": "text",
                "label": "First Name",
                "name": "first_name",
                "validation": {
                  "required": true,
                  "minLength": 2
                }
              },
              {
                "type": "text",
                "label": "Last Name",
                "name": "last_name",
                "validation": {
                  "required": true,
                  "minLength": 2
                }
              }
            ]
          },
          {
            "title": "Contact Information",
            "fields": [
              {
                "type": "number",
                "label": "Phone Number",
                "name": "phone_number",
                "validation": {
                  "required": true,
                  "minLength": 10
                }
              }
            ]
          }
        ]
      }
      ''';

      final expectedSteps = [
        FormStepModel(title: 'Personal Information', fields: [
          FieldModel(
            type: 'text',
            label: 'First Name',
            name: 'first_name',
            validation: ValidationModel(required: true, minLength: 2),
          ),
          FieldModel(
            type: 'text',
            label: 'Last Name',
            name: 'last_name',
            validation: ValidationModel(required: true, minLength: 2),
          ),
        ]),
        FormStepModel(title: 'Contact Information', fields: [
          FieldModel(
            type: 'number',
            label: 'Phone Number',
            name: 'phone_number',
            validation: ValidationModel(required: true, minLength: 10),
          ),
        ]),
      ];

      // Act
      final result = formService.loadFormFromJson(jsonString);

      // Assert
      expect(result, hasLength(expectedSteps.length));
    });

    test('loadFormFromJson throws an exception for invalid JSON', () {
      // Arrange
      const invalidJsonString = 'Invalid JSON';

      // Act & Assert
      expect(() => formService.loadFormFromJson(invalidJsonString),
          throwsException);
    });
  });
}
