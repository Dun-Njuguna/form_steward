/// An abstract class that defines the navigation behavior for FormSteward.
///
/// Implementers of this class are expected to provide functionality for moving 
/// between steps, including navigating to the next or previous step,
/// as well as handling form submission.
abstract class StepperNavigation {
  
  /// Called when navigating to the next step.
  ///
  /// Implementers should define how to handle the transition to the next step in the form.
  /// The method receives the data from the previous step, which can be used to save the 
  /// step's data or perform any necessary operations before proceeding.
  ///
  /// [previousStepData] - A map containing the data from the previous step. It can be `null` 
  /// if no data exists for the step.
  void onNextStep({required Map<String, dynamic>? previousStepData}) {}

  /// Called when navigating to the previous step.
  ///
  /// Implementers should define how to handle moving back to the previous step in the form.
  /// This method is typically called when the user chooses to revisit a prior step.
  void onPreviousStep() {}

  /// Called when submitting the entire form.
  ///
  /// Implementers should define what happens when the form is submitted. The method receives 
  /// the complete form data.
  ///
  /// [formData] - A map containing the form data for all steps. The outer map's keys are step names, 
  /// and the inner maps hold the field names and their respective values.
  void onSubmit({required Map<String, Map<String, dynamic>> formData}) {}
}
