import 'package:flutter/material.dart';

/// A widget that displays a step-by-step form with custom titles for each step.
///
/// The [StepperWidget] class creates a [Stepper] widget to manage and display
/// a series of steps in a form. It supports custom titles for each step and
/// handles navigation between steps using the provided callbacks.
class StepperWidget extends StatelessWidget {
  /// The list of widgets to be displayed as the content of each step.
  ///
  /// The [steps] parameter is a list of widgets where each widget represents
  /// the content of a step in the stepper.
  final List<Widget> steps;

  /// The list of custom titles for each step.
  ///
  /// The [titles] parameter is a list of strings where each string provides
  /// the title for the corresponding step in the stepper. The number of titles
  /// must match the number of steps.
  final List<String> titles;

  /// The callback function to be called when the user continues to the next step.
  ///
  /// The [onStepContinue] parameter is a function that will be called when the
  /// user presses the continue button on the current step.
  final Function onStepContinue;

  /// The callback function to be called when the user cancels or goes back to the previous step.
  ///
  /// The [onStepCancel] parameter is a function that will be called when the
  /// user presses the cancel or back button on the current step.
  final Function onStepCancel;

  /// The index of the currently active step.
  ///
  /// The [currentStep] parameter specifies which step is currently active and
  /// should be displayed as selected in the stepper.
  final int currentStep;

  /// Creates a new instance of the [StepperWidget] class.
  ///
  /// The [steps], [titles], [onStepContinue], [onStepCancel], and [currentStep]
  /// parameters are required to initialize the stepper.
  ///
  /// - Parameter steps: The list of widgets to be displayed in each step.
  /// - Parameter titles: The list of custom titles for each step.
  /// - Parameter onStepContinue: The callback function for continuing to the next step.
  /// - Parameter onStepCancel: The callback function for going back to the previous step.
  /// - Parameter currentStep: The index of the currently active step.
  const StepperWidget({
    super.key,
    required this.steps,
    required this.titles,
    required this.onStepContinue,
    required this.onStepCancel,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: currentStep,
      onStepContinue: onStepContinue as void Function()?,
      onStepCancel: onStepCancel as void Function()?,
      steps: steps.asMap().entries.map((entry) {
        int index = entry.key;
        Widget step = entry.value;
        return Step(
          title: Text(titles[index]),
          content: step,
          isActive: index == currentStep,
        );
      }).toList(),
    );
  }
}
