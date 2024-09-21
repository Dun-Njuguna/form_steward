import 'package:flutter/material.dart';
import 'package:form_steward/src/state/form_steward_state_notifier.dart';
import 'package:form_steward/src/state/validation_trigger_notifier.dart';
import 'package:form_steward/src/models/form_step_model.dart';
import 'package:form_steward/src/utils/helpers.dart';
import 'package:form_steward/src/widgets/form_builder/form_builder.dart';

/// A horizontal stepper widget that displays a multi-step form.
///
/// This widget creates a horizontal stepper interface with multiple form steps,
/// allowing users to navigate through different sections of a form.
class HorizontalStepper extends StatefulWidget {
  /// List of form steps to be displayed in the stepper.
  final List<FormStepModel> formSteps;

  /// Notifier for triggering form validation.
  final ValidationTriggerNotifier formStewardNotifier;

  /// Notifier for managing the state of the form steward.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// Callback function to be called when the form is submitted.
  ///
  /// The function takes a Map<String, Map<String, dynamic>> as an argument,
  /// representing the form data.
  final Function(Map<String, Map<String, dynamic>>) onSubmit;

  /// Creates a [HorizontalStepper] widget.
  ///
  /// All parameters are required.
  const HorizontalStepper({
    super.key,
    required this.formSteps,
    required this.formStewardNotifier,
    required this.formStewardStateNotifier,
    required this.onSubmit,
  });

  @override
  HorizontalStepperState createState() => HorizontalStepperState();
}

/// The state for the [HorizontalStepper] widget.
class HorizontalStepperState extends State<HorizontalStepper> {
  /// Notifier for the current step index.
  late final ValueNotifier<int> _currentStepNotifier;

  @override
  void initState() {
    super.initState();
    _currentStepNotifier = ValueNotifier<int>(0);
  }

  /// Moves to the next step if possible.
  ///
  /// [index] is the index of the next step.
  void _goToNextStep(int index) {
    if (index < widget.formSteps.length) {
      updateCurrentStep(index);
    }
  }

  /// Moves to the previous step if possible.
  ///
  /// [index] is the index of the previous step.
  void _goToPreviousStep(int index) {
    if (index >= 0) {
      updateCurrentStep(index);
    }
  }

  /// Updates the current step index and triggers a rebuild.
  ///
  /// [index] is the new step index.
  void updateCurrentStep(int index) {
    setState(() {
      _currentStepNotifier.value = index;
    });
  }

  /// Submits the form by calling the [onSubmit] callback.
  void _submitForm() {
    widget.onSubmit(widget.formStewardStateNotifier.getFormData());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: appEqualPadding,
      child: Column(
        children: [
          StepIndicatorRow(
            formSteps: widget.formSteps,
            currentStep: _currentStepNotifier.value,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: IndexedStack(
                index: _currentStepNotifier.value,
                children:
                    List<Widget>.generate(widget.formSteps.length, (int index) {
                  return FormBuilder(
                    steps: [widget.formSteps[index]],
                    validationTriggerNotifier: widget.formStewardNotifier,
                    formStewardStateNotifier: widget.formStewardStateNotifier,
                  );
                }),
              ),
            ),
          ),
          StepButtonsRow(
            currentStep: _currentStepNotifier.value,
            totalSteps: widget.formSteps.length,
            onPrevious: () => _goToPreviousStep(_currentStepNotifier.value - 1),
            onNext: () {
              widget.formStewardNotifier.triggerValidation(
                widget.formSteps[_currentStepNotifier.value].name,
              );
              if (widget.formStewardStateNotifier.isStepValid(
                stepName: widget.formSteps[_currentStepNotifier.value].name,
              )) {
                _goToNextStep(_currentStepNotifier.value + 1);
              } else {
                widget.formStewardNotifier.reset();
              }
            },
            onSubmit: _submitForm,
          ),
        ],
      ),
    );
  }
}

/// A widget that displays navigation buttons.
///
/// This widget provides buttons to navigate between steps, including
/// "Back", "Next", and "Submit" buttons, depending on the current step.
class StepButtonsRow extends StatelessWidget {
  /// The index of the current step (0-based).
  final int currentStep;

  /// The total number of steps in the stepper.
  final int totalSteps;

  /// Callback function to be invoked when the "Next" button is pressed.
  final VoidCallback onNext;

  /// Callback function to be invoked when the "Back" button is pressed.
  final VoidCallback onPrevious;

  /// Callback function to be invoked when the "Submit" button is pressed.
  final VoidCallback onSubmit;

  /// Creates a [StepButtonsRow] widget.
  ///
  /// Requires the following parameters:
  /// - [currentStep]: The index of the current step (0-based).
  /// - [totalSteps]: The total number of steps in the stepper.
  /// - [onNext]: Callback function for "Next" button.
  /// - [onPrevious]: Callback function for "Back" button.
  /// - [onSubmit]: Callback function for "Submit" button.
  const StepButtonsRow({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Display the "Back" button if not on the first step.
        if (currentStep > 0)
          ElevatedButton(
            onPressed: onPrevious,
            child: const Text('Back'),
          )
        else
          const Spacer(flex: 3), // Spacer for alignment when on the first step.

        // Display the current step number and total steps.
        Text('${currentStep + 1}/$totalSteps'),

        // Spacer for alignment when on the first step.
        if (currentStep == 0) const Spacer(flex: 2),

        // Display "Submit" button if on the last step, otherwise "Next" button.
        currentStep == totalSteps - 1
            ? ElevatedButton(
                onPressed: onSubmit,
                child: const Text('Submit'),
              )
            : ElevatedButton(
                onPressed: onNext,
                child: const Text('Next'),
              ),
      ],
    );
  }
}






/// A widget that displays a row of step indicators.
///
/// This widget shows the progress of the steps using indicators for each step
/// based on the current step status (active, completed, or pending).
class StepIndicatorRow extends StatelessWidget {
  /// The list of form steps to be displayed as indicators.
  final List<FormStepModel> formSteps;

  /// The index of the current step (0-based).
  final int currentStep;

  /// Creates a [StepIndicatorRow] widget.
  ///
  /// Requires the following parameters:
  /// - [formSteps]: The list of form steps to display.
  /// - [currentStep]: The index of the current step (0-based).
  const StepIndicatorRow({
    super.key,
    required this.formSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: List.generate(formSteps.length, (index) {
          return Expanded(
            child: StepIndicatorWidget(
              title: formSteps[index].title,
              isActive: index == currentStep,
              isCompleted: index < currentStep,
              isPending: index > currentStep,
            ),
          );
        }),
      ),
    );
  }
}

/// A widget that represents a single step indicator.
///
/// This widget displays the title of the step along with its status as active,
/// completed, or pending, indicated by icons and colors.
class StepIndicatorWidget extends StatelessWidget {
  /// The title of the step.
  final String title;

  /// Indicates if this step is currently active.
  final bool isActive;

  /// Indicates if this step is completed.
  final bool isCompleted;

  /// Indicates if this step is pending.
  final bool isPending;

  /// Creates a [StepIndicatorWidget].
  ///
  /// Requires the following parameters:
  /// - [title]: The title of the step.
  /// - [isActive]: Whether this step is currently active.
  /// - [isCompleted]: Whether this step is completed.
  /// - [isPending]: Whether this step is pending.
  const StepIndicatorWidget({
    super.key,
    required this.title,
    required this.isActive,
    required this.isCompleted,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Display the appropriate icon based on step status.
            if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green)
            else if (isActive)
              const Icon(Icons.radio_button_checked, color: Colors.blue)
            else
              const Icon(Icons.radio_button_unchecked, color: Colors.grey),

            // Divider between indicators, changing color based on status.
            if (isPending && !isCompleted)
              const Expanded(child: Divider(color: Colors.grey))
            else
              const Expanded(child: Divider(color: Colors.blue)),
          ],
        ),
        // Display the title of the step.
        Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        // Display the status of the step.
        Text(
          isCompleted
              ? 'Completed'
              : isActive
                  ? 'In Progress'
                  : 'Pending',
          style: TextStyle(
            color: isCompleted ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

