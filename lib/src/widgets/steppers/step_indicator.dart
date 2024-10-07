import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

/// A widget that displays a row of step indicators.
///
/// This widget shows the progress of the steps using indicators for each step
/// based on the current step status (active, completed, or pending).
class StepIndicator extends StatelessWidget {
  /// The list of form steps to be displayed as indicators.
  final List<FormStepModel> formSteps;

  /// The index of the current step (0-based).
  final int currentStep;

  final StewardStepperType stepperType;

  /// Creates a [StepIndicator] widget.
  ///
  /// Requires the following parameters:
  /// - [formSteps]: The list of form steps to display.
  /// - [currentStep]: The index of the current step (0-based).
  const StepIndicator({
    super.key,
    required this.formSteps,
    required this.currentStep,
    required this.stepperType,
  });

  @override
  Widget build(BuildContext context) {
    final steps = List.generate(formSteps.length, (index) {
      bool isLast = index == formSteps.length - 1;
      return stepperType == StewardStepperType.horizontal
          ? Expanded(
              child: StepIndicatorWidget(
              title: formSteps[index].title,
              isActive: index == currentStep,
              isCompleted: index < currentStep,
              isPending: index > currentStep,
              stepperType: stepperType,
              isLast: isLast,
            ))
          : StepIndicatorWidget(
              title: formSteps[index].title,
              isActive: index == currentStep,
              isCompleted: index < currentStep,
              isPending: index > currentStep,
              stepperType: stepperType,
              isLast: isLast,
            );
    });

    return stepperType == StewardStepperType.tablet
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps,
          )
        : Row(
            children: steps,
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

  final StewardStepperType stepperType;

  final bool isLast;

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
    required this.stepperType,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stepperType == StewardStepperType.horizontal
          ? [
              StepIcon(
                isCompleted: isCompleted,
                isActive: isActive,
                isPending: isPending,
                stepperType: stepperType,
              ),
              StepTitle(
                title: title,
                isActive: isActive,
                isCompleted: isCompleted,
              ),
            ]
          : [
              StepTitle(
                title: title,
                isActive: isActive,
                isCompleted: isCompleted,
              ),
              if (!isLast)
                StepIcon(
                  isCompleted: isCompleted,
                  isActive: isActive,
                  isPending: isPending,
                  stepperType: stepperType,
                ),
            ],
    );
  }
}

// Display the title of the step.
class StepTitle extends StatelessWidget {
  const StepTitle({
    super.key,
    required this.title,
    required this.isActive,
    required this.isCompleted,
  });

  final String title;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

class StepIcon extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;
  final bool isPending;
  final StewardStepperType stepperType;

  const StepIcon({
    super.key,
    required this.isCompleted,
    required this.isActive,
    required this.isPending,
    required this.stepperType,
  });

  @override
  Widget build(BuildContext context) {
    return stepperType == StewardStepperType.horizontal
        ? Row(
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
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                const SizedBox(
                    height: 20, child: VerticalDivider(color: Colors.grey))
              else
                const SizedBox(
                    height: 20, child: VerticalDivider(color: Colors.blue)),
            ],
          );
  }
}
