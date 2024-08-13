// Import your test files here

import 'package:flutter_test/flutter_test.dart';

import 'controllers/form_controller_test.dart';
import 'controllers/step_controller_test.dart';
import 'models/field_model_test.dart';
import 'models/form_step_model_test.dart';
import 'models/validation_model_test.dart';
import 'services/api_service_test.dart';
import 'services/form_service_test.dart';
import 'utils/json_parser_test.dart';
import 'utils/validators_test.dart';
import 'widgets/form_builder_test.dart';
import 'widgets/form_field_widget_test.dart';
import 'widgets/stepper_widget_test.dart';

void main() {
  // Run all tests from the specified files
  group('All Tests', () {
    formControllerTests();
    stepControllerTests();
    fieldModelTests();
    formStepModelTests();
    validationModelTests();
    apiServiceTests();
    formServiceTests();
    jsonParserTests();
    validatorTests();
    formBuilderTests();
    formFieldWidgetTests();
    stepperWidgetTests();
  });
}
