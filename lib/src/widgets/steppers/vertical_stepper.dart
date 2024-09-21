import 'package:flutter/material.dart';
import 'package:form_steward/src/state/form_steward_state_notifier.dart';
import 'package:form_steward/src/state/validation_trigger_notifier.dart';
import 'package:form_steward/src/models/form_step_model.dart';
import 'package:form_steward/src/widgets/form_builder/form_builder.dart';

/// A vertical stepper widget that displays a multi-step form.
///
/// This widget creates a vertical stepper interface with multiple form steps,
/// allowing users to navigate through different sections of a form. It uses
/// Flutter's built-in [Stepper] widget for the UI and manages the state of
/// the current step and form data.
class VerticalStepper extends StatefulWidget {
  /// List of form steps to be displayed in the stepper.
  ///
  /// Each [FormStepModel] represents a single step in the form.
  final List<FormStepModel> formSteps;

  /// Notifier for triggering form validation.
  ///
  /// This notifier is used to trigger validation for the current step
  /// when moving to the next step or submitting the form.
  final ValidationTriggerNotifier formStewardNotifier;

  /// Notifier for managing the state of the form steward.
  ///
  /// This notifier holds the current state of the form, including
  /// the data for each step and validation status.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// Callback function to be called when a step is completed or the form is submitted.
  ///
  /// The function takes a Map<String, dynamic> as an argument,
  /// representing the form data for the current step or the entire form.
  final Function(Map<String, dynamic>) onSubmit;

  /// Creates a [VerticalStepper] widget.
  ///
  /// All parameters are required.
  const VerticalStepper({
    super.key,
    required this.formSteps,
    required this.formStewardNotifier,
    required this.formStewardStateNotifier,
    required this.onSubmit,
  });

  @override
  VerticalStepperState createState() => VerticalStepperState();
}

/// The state for the [VerticalStepper] widget.
class VerticalStepperState extends State<VerticalStepper> {
  /// Notifier for the current step index.
  late final ValueNotifier<int> _currentStepNotifier;

  /// The index of the current step.
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _currentStepNotifier = ValueNotifier<int>(0);
  }

  /// Moves to the next step if possible and submits the current step's data.
  ///
  /// [index] is the index of the next step.
  void _goToNextStep(int index) {
    final data = widget.formStewardStateNotifier.getCurrentStepData(
      currentStepName: widget.formSteps[currentStep].name
    );
    if (data != null) {
      widget.onSubmit(data);
    }
    if (index < widget.formSteps.length) {
      setState(() {
        currentStep = index;
      });
    }
  }

  /// Moves to the previous step if possible.
  ///
  /// [index] is the index of the previous step.
  void _goToPreviousStep(int index) {
    if (index < widget.formSteps.length) {
      setState(() {
        currentStep = index;
      });
    }
  }

  /// Submits the entire form by calling the [onSubmit] callback with all form data.
  void _submitForm() {
    widget.onSubmit(widget.formStewardStateNotifier.getFormData());
  }

  /// Builds the list of [Step] widgets for the [Stepper].
  ///
  /// Each step corresponds to a form step defined in [formSteps].
  List<Step> _buildSteps() {
    return List<Step>.generate(widget.formSteps.length, (int index) {
      return Step(
        title: Text(widget.formSteps[index].title),
        content: FormBuilder(
          steps: [widget.formSteps[index]],
          validationTriggerNotifier: widget.formStewardNotifier,
          formStewardStateNotifier: widget.formStewardStateNotifier,
        ),
        isActive: index == _currentStepNotifier.value,
        state: index < _currentStepNotifier.value
            ? StepState.complete
            : (index == _currentStepNotifier.value
                ? StepState.editing
                : StepState.indexed),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: currentStep,
      onStepTapped: (int index) {
        if (currentStep > index) {
          _goToPreviousStep(index);
        } else {
          currentStep == widget.formSteps.length - 1
              ? _submitForm()
              : _goToNextStep(index);
        }
      },
      onStepContinue: currentStep == widget.formSteps.length - 1
          ? () => _submitForm()
          : () => _goToNextStep(currentStep + 1),
      onStepCancel: () => _goToPreviousStep(currentStep - 1),
      steps: _buildSteps(),
      controlsBuilder: (BuildContext context, ControlsDetails details) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (currentStep > 0)
              ElevatedButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Trigger validation for the current step
                widget.formStewardNotifier
                    .triggerValidation(widget.formSteps[currentStep].name);
                // Check if the current step is valid
                if (widget.formStewardStateNotifier.isStepValid(
                  stepName: widget.formSteps[currentStep].name,
                )) {
                  // If valid, continue to the next step or submit
                  details.onStepContinue!();
                } else {
                  // If not valid, reset the validation trigger
                  widget.formStewardNotifier.reset();
                }
              },
              child: Text(
                currentStep == widget.formSteps.length - 1 ? 'Submit' : 'Next',
              ),
            ),
          ],
        );
      },
    );
  }
}