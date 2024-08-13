import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/src/utils/validators.dart';

void main() {
  validatorTests();
}

void validatorTests() {
  group('Validators', () {
    group('requiredField', () {
      test('returns error message if value is null', () {
        final result = Validators.requiredField(null, 'Field');
        expect(result, equals('Field is required'));
      });

      test('returns error message if value is empty', () {
        final result = Validators.requiredField('', 'Field');
        expect(result, equals('Field is required'));
      });

      test('returns null if value is not null or empty', () {
        final result = Validators.requiredField('Some value', 'Field');
        expect(result, isNull);
      });
    });

    group('minLength', () {
      test('returns error message if value length is less than minLength', () {
        final result = Validators.minLength('short', 6, 'Field');
        expect(result, equals('Field must be at least 6 characters'));
      });

      test('returns null if value length meets or exceeds minLength', () {
        final result = Validators.minLength('sufficient length', 6, 'Field');
        expect(result, isNull);
      });

      test('returns null if value is null', () {
        final result = Validators.minLength(null, 6, 'Field');
        expect(result, isNull);
      });
    });
  });
}
