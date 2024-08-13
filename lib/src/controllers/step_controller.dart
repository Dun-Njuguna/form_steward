/// A controller that manages the current step in a multi-step process.
///
/// The [StepController] class provides methods to navigate between steps in a
/// multi-step process, such as a form with multiple pages. It keeps track of
/// the current step and provides utility methods to determine the position
/// within the step sequence.
class StepController {
  /// The index of the current step.
  ///
  /// The index starts at `0` for the first step and increments as the user
  /// progresses through the steps. The value of [currentStep] represents the
  /// current position within the sequence of steps.
  int currentStep = 0;

  /// Moves to the next step.
  ///
  /// This method increments the [currentStep] by `1`, advancing to the next
  /// step in the sequence. Ensure that the step sequence is not already at
  /// the last step when calling this method.
  void nextStep() {
    currentStep += 1;
  }

  /// Moves to the previous step.
  ///
  /// This method decrements the [currentStep] by `1`, moving back to the
  /// previous step in the sequence. It will not decrement below `0`, so if
  /// the [currentStep] is already `0`, it will remain at `0`.
  void previousStep() {
    if (currentStep > 0) {
      currentStep -= 1;
    }
  }

  /// Determines if the current step is the first step.
  ///
  /// Returns `true` if the [currentStep] is `0`, indicating that the user is
  /// on the first step of the sequence. Otherwise, it returns `false`.
  ///
  /// This method is useful for disabling the "Previous" button or for other
  /// logic specific to the first step.
  bool isFirstStep() {
    return currentStep == 0;
  }

  /// Determines if the current step is the last step.
  ///
  /// Takes the total number of steps as a parameter and returns `true` if the
  /// [currentStep] is equal to `totalSteps - 1`, indicating that the user is
  /// on the last step of the sequence. Otherwise, it returns `false`.
  ///
  /// This method is useful for enabling the "Submit" button or for other
  /// logic specific to the last step.
  ///
  /// - Parameter totalSteps: The total number of steps in the sequence.
  bool isLastStep(int totalSteps) {
    return currentStep == totalSteps - 1;
  }
}
