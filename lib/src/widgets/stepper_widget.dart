import 'package:flutter/material.dart';

/// A widget that displays a step-by-step form with custom titles for each step.
///
/// The [StepperWidget] class creates a [Stepper] widget to manage and display
/// a series of steps in a form. It supports custom titles for each step and
/// handles navigation between steps using the provided callbacks.
class StepperWidget extends StatelessWidget {
  /// The list of widgets to be displayed as the content of each step.
  final List<Widget> steps;

  /// The list of custom titles for each step.
  final List<String> titles;

  /// The callback function to be called when the user continues to the next step.
  final Function onNextClicked;

  /// The callback function to be called when the user cancels or goes back to the previous step.
  final Function onBackClicked;

  /// The callback function to be called when the user completes the form and submits.
  final Function onSubmitClicked;

  /// The index of the currently active step.
  final int currentStep;

  /// The orientation of the stepper.
  final Axis orientation;

  const StepperWidget({
    super.key,
    required this.steps,
    required this.titles,
    required this.onNextClicked,
    required this.onBackClicked,
    required this.currentStep,
    required this.orientation,
    required this.onSubmitClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: orientation == Axis.vertical
          ? _buildVerticalStepper()
          : _buildHorizontalStepper(context),
    );
  }

  Widget _buildVerticalStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the Stepper widget for vertical orientation
        Expanded(
          child: Stepper(
            currentStep: currentStep,
            onStepContinue: currentStep == steps.length - 1
                ? onSubmitClicked as void Function()?
                : onNextClicked as void Function()?,
            onStepCancel:
                currentStep > 0 ? onBackClicked as void Function()? : null,
            steps: _buildSteps(),
            type: StepperType.vertical,
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Show the Back button only if the current step is 2 or above
                  if (currentStep > 0)
                    ElevatedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  const Spacer(
                    flex: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(
                        currentStep == steps.length - 1 ? 'Submit' : 'Next',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalStepper(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display only the title of the current step

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              titles[currentStep],
            ),
          ),
          Expanded(
            // Display the content of the current step
            child: SingleChildScrollView(
              child: steps[currentStep],
            ),
          ),
          // Display the step counter and control buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Show the Back button only if the current step is 2 or above
                if (currentStep > 0)
                  ElevatedButton(
                    onPressed: onBackClicked as void Function()?,
                    child: const Text('Back'),
                  )
                else
                  const Spacer(
                    flex: 3,
                  ),

                Text('${currentStep + 1}/${steps.length}'),

                if (currentStep == 0)
                  const Spacer(
                    flex: 2,
                  ),
                currentStep == steps.length - 1
                    ? ElevatedButton(
                        onPressed: onSubmitClicked as void Function()?,
                        child: const Text('Submit'),
                      )
                    : ElevatedButton(
                        onPressed: onNextClicked as void Function()?,
                        child: const Text('Next'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Step> _buildSteps() {
    return steps.asMap().entries.map((entry) {
      int index = entry.key;
      Widget step = entry.value;
      return Step(
        title: Text(titles[index]),
        content: step,
        isActive: index == currentStep,
      );
    }).toList();
  }
}
