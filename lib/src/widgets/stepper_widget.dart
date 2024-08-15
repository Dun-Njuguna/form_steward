import 'package:flutter/material.dart';
import 'package:form_steward/src/utils/steward_stepper_type.dart';

/// A widget that displays a step-by-step form with custom titles for each step.
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

  /// The type of stepper to render.
  final StewardStepperType stepperType;

  const StepperWidget({
    super.key,
    required this.steps,
    required this.titles,
    required this.onNextClicked,
    required this.onBackClicked,
    required this.currentStep,
    required this.stepperType,
    required this.onSubmitClicked,
  });

  @override
  Widget build(BuildContext context) {
    switch (stepperType) {
      case StewardStepperType.vertical:
        return _buildVerticalStepper();
      case StewardStepperType.horizontal:
        return _buildHorizontalStepper(context);
      case StewardStepperType.tablet:
        return _buildtabletStepper(context);
    }
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

  Widget _buildtabletStepper(BuildContext context) {
    return Row(
      children: [
        // Display the list of all steps on the left
        SizedBox(
          width: MediaQuery.of(context).size.width *
              0.25, // 25% of the screen width
          child: ListView.builder(
            itemCount: titles.length,
            itemBuilder: (context, index) {
              final theme = Theme.of(context);
              final isActive = index == currentStep;

              return ListTile(
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.1),
                  foregroundColor: isActive
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  child: Text(
                    '${index + 1}', // Step number
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  titles[index],
                  style: isActive
                      ? TextStyle(color: theme.colorScheme.primary)
                      : null,
                ),
                selected: isActive,
                onTap: () {
                  // Handle step change when a step is tapped
                  if (index < currentStep) {
                    onBackClicked();
                  } else if (index > currentStep) {
                    onNextClicked();
                  }
                },
              );
            },
          ),
        ),

        // Display the content of the active step on the right
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    child: steps[currentStep],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentStep > 0)
                        ElevatedButton(
                          onPressed: onBackClicked as void Function()?,
                          child: const Text('Back'),
                        )
                      else
                        const Spacer(flex: 3),
                      Text('${currentStep + 1}/${steps.length}'),
                      if (currentStep == 0) const Spacer(flex: 2),
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
          ),
        ),
      ],
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
