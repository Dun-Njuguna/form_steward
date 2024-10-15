import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/interfaces/stepper_navigation.dart';
import 'package:form_steward/src/controllers/step_controller.dart';
import 'package:form_steward/src/widgets/steppers/horizontal_stepper.dart';
import 'package:form_steward/src/widgets/steppers/tablet_stepper.dart';
import 'package:form_steward/src/widgets/steppers/vertical_stepper.dart';

/// A customizable stepper widget that enables navigation through multiple steps.
/// It supports vertical, horizontal, and tablet layouts.
///
/// The widget handles navigation between steps and allows custom behaviors through
/// the `onNextStep`, `onPreviousStep`, and `onSubmit` methods. You can customize
/// the layout and behavior of the stepper by providing different stepper types
/// and overriding the default behavior of step transitions.
class StepperWidget extends StatefulWidget implements StepperNavigation {
  /// Creates an instance of [StepperWidget].
  ///
  /// Requires a list of [FormStepModel] objects for the content of each step,
  /// the current step index, the layout type, and notifiers for form state and validation.
  StepperWidget({
    super.key,
    required this.formSteps,
    required this.stepperType,
    required this.formStewardNotifier,
    required this.formStewardStateNotifier,
  });

  /// A list of [FormStepModel] objects, each representing a step in the stepper.
  ///
  /// Each [FormStepModel] should include the content and validation requirements
  /// for the specific step.
  final List<FormStepModel> formSteps;

  /// A list of [Widget]s where each widget is a [FormBuilder] instance.
  ///
  /// This list is created by mapping over [formSteps], where each step is used
  /// to instantiate a [FormBuilder] widget. Each [FormBuilder] is configured
  /// with the following parameters:
  /// - `steps`: A list containing a single [FormStepModel] representing the current step.
  /// - `validationTriggerNotifier`: A notifier used to trigger validation for the form.
  /// - `formStewardStateNotifier`: A notifier managing the state of the form.
  ///
  /// The resulting list of [FormBuilder] widgets corresponds to each step in the
  /// form, with each widget handling its specific step's content and validation.
  ///
  /// The list is populated by transforming the [formSteps] into [FormBuilder] widgets
  /// and then converting the iterable to a list.
  ///
  /// This list is used to display the form steps in the [StepperWidget], with each
  /// step's content and validation being managed by its respective [FormBuilder] instance.
  late final List<Widget> stepWidgets = formSteps.map((step) {
    return FormBuilder(
      steps: [step],
      validationTriggerNotifier: formStewardNotifier,
      formStewardStateNotifier: formStewardStateNotifier,
    );
  }).toList();

  /// The type of stepper layout to use.
  ///
  /// Defines the layout style of the stepper. Possible values are:
  /// - [StewardStepperType.vertical]
  /// - [StewardStepperType.horizontal]
  /// - [StewardStepperType.tablet]
  final StewardStepperType stepperType;

  /// Notifier for triggering form validation.
  final ValidationTriggerNotifier formStewardNotifier;

  /// Notifier for managing the form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  @override
  StepperWidgetState createState() => StepperWidgetState();

  @override
  void onNextStep({required Map<String, dynamic>? previousStepData}) {}

  @override
  void onPreviousStep() {}

  @override
  void onSubmit({required Map<String, Map<String, dynamic>> formData}) {}
}

class StepperWidgetState extends State<StepperWidget> {
  @override
  void dispose() {
    // Dispose StepNotifierUtility Singleton
    StepController().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.stepperType) {
      case StewardStepperType.vertical:
        return VerticalStepper(
          formSteps: widget.formSteps,
          formStewardNotifier: widget.formStewardNotifier,
          formStewardStateNotifier: widget.formStewardStateNotifier,
          submitStepData: (stepData) {
            widget.onNextStep(previousStepData: stepData);
          },
          submitFormData: (formData) {
            widget.onSubmit(formData: formData);
          },
        );
      case StewardStepperType.horizontal:
        return HorizontalStepper(
          formSteps: widget.formSteps,
          formStewardNotifier: widget.formStewardNotifier,
          formStewardStateNotifier: widget.formStewardStateNotifier,
          submitStepData: (stepData) {
            widget.onNextStep(previousStepData: stepData);
          },
          submitFormData: (formData) {
            widget.onSubmit(formData: formData);
          },
        );
      case StewardStepperType.tablet:
        return TabletStepperWidget(
          formSteps: widget.formSteps,
          formStewardNotifier: widget.formStewardNotifier,
          formStewardStateNotifier: widget.formStewardStateNotifier,
          submitStepData: (stepData) {
            widget.onNextStep(previousStepData: stepData);
          },
          submitFormData: (formData) {
            widget.onSubmit(formData: formData);
          },
        );
    }
  }
}
