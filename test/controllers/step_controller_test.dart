import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/src/controllers/step_controller.dart';

void stepControllerTests() {
  /// Group of tests for the [StepController] class.
  group('StepController', () {
    /// Instance of [StepController] that will be used in the tests.
    late StepController stepController;

    /// Sets up the [StepController] instance before each test.
    ///
    /// The [setUp] function is called before every test in the group to
    /// ensure a fresh instance of [StepController] is used in each test.
    setUp(() {
      stepController = StepController();
    });

    /// Test to verify that the initial value of [currentStep] is 0.
    ///
    /// This test ensures that when a [StepController] is created, the
    /// [currentStep] is set to `0`, indicating the first step in the sequence.
    test('initial currentStep is 0', () {
      expect(stepController.currentStep, equals(0));
    });

    /// Test to verify that [nextStep] increments the value of [currentStep] by 1.
    ///
    /// This test checks that calling the [nextStep] method on the
    /// [StepController] instance correctly increments the [currentStep] value
    /// by `1`, moving to the next step in the sequence.
    test('nextStep increments currentStep by 1', () {
      stepController.nextStep();
      expect(stepController.currentStep, equals(1));
    });

    /// Test to verify that [previousStep] decrements the value of [currentStep] by 1 but not below 0.
    ///
    /// This test ensures that calling the [previousStep] method correctly
    /// decrements the [currentStep] value by `1` but does not allow the
    /// [currentStep] to go below `0`. It checks this by first incrementing
    /// the [currentStep] and then calling [previousStep] twice.
    test('previousStep decrements currentStep by 1 but not below 0', () {
      stepController.nextStep(); // Increment to 1
      stepController.previousStep(); // Should decrement to 0
      expect(stepController.currentStep, equals(0));

      stepController.previousStep(); // Should stay at 0
      expect(stepController.currentStep, equals(0));
    });

    /// Test to verify that [isFirstStep] returns true when [currentStep] is 0.
    ///
    /// This test checks that the [isFirstStep] method returns `true` when
    /// [currentStep] is `0`, indicating that the user is on the first step of
    /// the sequence. It also verifies that [isFirstStep] returns `false` after
    /// moving to the next step.
    test('isFirstStep returns true when currentStep is 0', () {
      expect(stepController.isFirstStep(), isTrue);

      stepController.nextStep();
      expect(stepController.isFirstStep(), isFalse);
    });

    /// Test to verify that [isLastStep] returns true when [currentStep] equals totalSteps - 1.
    ///
    /// This test checks that the [isLastStep] method returns `true` when
    /// [currentStep] is equal to `totalSteps - 1`, indicating that the user is
    /// on the last step of the sequence. It first verifies that [isLastStep]
    /// returns `false` initially, then advances the stepController to the last
    /// step and confirms that [isLastStep] returns `true`.
    test('isLastStep returns true when currentStep equals totalSteps - 1', () {
      const totalSteps = 3;

      // Initially, isLastStep should be false
      expect(stepController.isLastStep(totalSteps), isFalse);

      // Move to the last step
      stepController.nextStep();
      stepController.nextStep();

      expect(stepController.isLastStep(totalSteps), isTrue);
    });
  });
}
