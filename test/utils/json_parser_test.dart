import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/src/utils/json_parser.dart';
import 'package:form_steward/src/models/form_step_model.dart';
import 'package:form_steward/src/models/field_model.dart';
import 'package:form_steward/src/models/validation_model.dart';
import 'package:collection/collection.dart'; // For ListEquality

// Custom matchers for comparing FormStepModel, FieldModel, and ValidationModel instances
Matcher hasFormStep({
  required String title,
  required List<FieldModel> fields,
}) {
  return predicate<FormStepModel>(
    (step) =>
        step.title == title &&
        ListEquality<FieldModel>().equals(step.fields, fields),
    'FormStepModel with title "$title" and fields $fields',
  );
}

Matcher hasField({
  required String type,
  required String label,
  required String name,
  required ValidationModel validation,
}) {
  return predicate<FieldModel>(
    (field) =>
        field.type == type &&
        field.label == label &&
        field.name == name &&
        field.validation == validation,
    'FieldModel with type "$type", label "$label", name "$name" and validation $validation',
  );
}

Matcher hasValidation({
  required bool required,
  int? minLength,
  int? maxLength,
}) {
  return predicate<ValidationModel>(
    (validation) =>
        validation.required == required &&
        validation.minLength == minLength &&
        validation.maxLength == maxLength,
    'ValidationModel with required $required, minLength $minLength and maxLength $maxLength',
  );
}

void main() {
  jsonParserTests();
}

void jsonParserTests() {
  group('JsonParser', () {
    test('throws FormatException for invalid JSON data', () {
      // Arrange
      const invalidJsonString = 'Invalid JSON';

      // Act & Assert
      expect(
        () => JsonParser.parseForm(invalidJsonString),
        throwsA(isA<FormatException>()),
      );
    });

    test('handles empty steps array correctly', () {
      // Arrange
      const jsonString = '''
      {
        "formName": "User Information Form",
        "steps": []
      }
      ''';

      final expectedSteps = <FormStepModel>[];

      // Act
      final result = JsonParser.parseForm(jsonString);

      // Assert
      expect(result, hasLength(expectedSteps.length));
    });
  });
}
