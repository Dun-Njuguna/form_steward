import 'package:flutter/material.dart';
import 'package:form_steward/src/utils/enums/steward_stepper_type.dart';
import 'package:form_steward/src/utils/interfaces/stepper_navigation.dart';

/// A customizable stepper widget that allows users to navigate through multiple steps.
/// Supports vertical, horizontal, and tablet layouts.
///
/// This widget handles step navigation and allows for custom behaviors by overriding
/// the `onNextStep`, `onPreviousStep`, and `onSubmit` methods.
class StepperWidget extends StatefulWidget implements StepperNavigation {
  /// Creates an instance of [StepperWidget].
  ///
  /// [steps] is a list of widgets representing the content for each step.
  /// [titles] is a list of titles corresponding to each step.
  /// [currentStep] is the index of the currently active step.
  /// [stepperType] determines the layout of the stepper (vertical, horizontal, or tablet).
  const StepperWidget({
    super.key,
    required this.steps,
    required this.titles,
    required this.currentStep,
    required this.stepperType,
  });

  /// List of widgets representing the content for each step.
  ///
  /// Each widget should represent the content for a specific step in the stepper.
  final List<Widget> steps;

  /// List of titles corresponding to each step.
  ///
  /// The titles are displayed alongside each step and help identify the content of each step.
  final List<String> titles;

  /// The index of the currently active step.
  ///
  /// This determines which step is currently visible and active.
  final int currentStep;

  /// The type of stepper layout to use.
  ///
  /// This defines the layout style of the stepper. Possible values include vertical,
  /// horizontal, and tablet.
  final StewardStepperType stepperType;

  @override
  StepperWidgetState createState() => StepperWidgetState();

  @override
  void onNextStep() {}

  @override
  void onPreviousStep() {}

  @override
  void onSubmit() {}
}

class StepperWidgetState extends State<StepperWidget> {
  late final ValueNotifier<int> _currentStepNotifier;
  late final ScrollController _scrollController;
  final double _itemHeight = 62; // Height of each item in the scrollable list

  @override
  void initState() {
    super.initState();
    _currentStepNotifier = ValueNotifier(widget.currentStep);
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant StepperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      // Update the step notifier and scroll to the new active step if needed
      _currentStepNotifier.value = widget.currentStep;
      _scrollToActiveStep();
    }
  }

  @override
  void dispose() {
    _currentStepNotifier.dispose();
    super.dispose();
  }

  /// Scrolls to the currently active step in the list if it's not already visible.
  ///
  /// This method is used to ensure the active step is visible in the viewport,
  /// particularly useful for the tablet layout where steps are displayed in a scrollable list.
  void _scrollToActiveStep() {
    if (widget.stepperType != StewardStepperType.tablet) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stepIndex = _currentStepNotifier.value;
      final itemOffset = _itemHeight * stepIndex;

      // Only scroll if the step is not already visible
      if (_isStepVisible(stepIndex)) {
        return; // No need to scroll
      }

      // Animate scrolling to the new step
      _scrollController.animateTo(
        itemOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  /// Checks if the step at [index] is currently visible in the viewport.
  ///
  /// [index] is the index of the step to check.
  /// Returns true if the step is visible, otherwise false.
  bool _isStepVisible(int index) {
    final viewport = _scrollController.position;
    final itemOffset = _itemHeight * index;
    final itemEndOffset = itemOffset + _itemHeight;

    return itemOffset >= viewport.pixels &&
        itemEndOffset <= viewport.pixels + viewport.viewportDimension;
  }

  /// Advances to the next step if possible.
  ///
  /// Calls [onNextStep] and updates the current step index.
  /// If [position] is provided, it will set the current step to that position.
  void _goToNextStep(int? position) {
    widget.onNextStep();

    setState(() {
      position != null
          ? _currentStepNotifier.value = position
          : _currentStepNotifier.value++;
      _scrollToActiveStep();
    });
  }

  /// Moves to the previous step if possible.
  ///
  /// Calls [onPreviousStep] and updates the current step index.
  /// If [position] is provided, it will set the current step to that position.
  void _goToPreviousStep(int? position) {
    widget.onPreviousStep();
    if (_currentStepNotifier.value > 0) {
      setState(() {
        position != null
            ? _currentStepNotifier.value = position
            : _currentStepNotifier.value--;
        _scrollToActiveStep();
      });
    }
  }

  /// Submits the form and prints a submission message.
  ///
  /// Calls [onSubmit] and prints 'Form submitted' to the console.
  void _submitForm() {
    widget.onSubmit();
    print('Form submitted');
  }

  @override
  Widget build(BuildContext context) {
    // Build the widget based on the stepper type
    switch (widget.stepperType) {
      case StewardStepperType.vertical:
        return _buildVerticalStepper();
      case StewardStepperType.horizontal:
        return _buildHorizontalStepper(context);
      case StewardStepperType.tablet:
        return _buildTabletStepper(context);
    }
  }

  /// Builds the layout for a vertical stepper.
  ///
  /// Displays the steps in a vertical column with navigation controls at the bottom.
  /// Handles step tapping to navigate between steps or submit the form.
  Widget _buildVerticalStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stepper(
            currentStep: _currentStepNotifier.value,
            onStepTapped: (int index) {
              // Handle step tap
              if (_currentStepNotifier.value > index) {
                _goToPreviousStep(index);
              } else {
                _currentStepNotifier.value == widget.steps.length - 1
                    ? _submitForm()
                    : _goToNextStep(index);
              }
            },
            onStepContinue:
                _currentStepNotifier.value == widget.steps.length - 1
                    ? _submitForm
                    : () {
                        _goToNextStep(null);
                      },
            onStepCancel: () {
              _currentStepNotifier.value > 0 ? _goToPreviousStep(null) : null;
            },
            steps: _buildSteps(),
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStepNotifier.value > 0)
                    ElevatedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  const Spacer(flex: 5),
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(
                      _currentStepNotifier.value == widget.steps.length - 1
                          ? 'Submit'
                          : 'Next',
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

  /// Builds the layout for a horizontal stepper.
  ///
  /// Displays the steps in a horizontal stack with navigation controls at the bottom.
  /// Handles step navigation with "Back" and "Next" buttons.
  Widget _buildHorizontalStepper(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.titles[_currentStepNotifier.value],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _currentStepNotifier.value,
              children: widget.steps,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStepNotifier.value > 0)
                  ElevatedButton(
                    onPressed: () {
                      _goToPreviousStep(null);
                    },
                    child: const Text('Back'),
                  )
                else
                  const Spacer(flex: 3),
                Text(
                    '${_currentStepNotifier.value + 1}/${widget.steps.length}'),
                if (_currentStepNotifier.value == 0) const Spacer(flex: 2),
                _currentStepNotifier.value == widget.steps.length - 1
                    ? ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Submit'),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          _goToNextStep(null);
                        },
                        child: const Text('Next'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the layout for a tablet stepper.
  ///
  /// Displays a vertical list of steps on the left and content on the right.
  /// The list is scrollable, and the content changes based on the selected step.
  Widget _buildTabletStepper(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.30,
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            interactive: true,
            thickness: 1.2,
            child: Padding(
              padding: const EdgeInsets.only(right: 7),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.titles.length,
                itemBuilder: (context, index) {
                  final theme = Theme.of(context);
                  final isActive = index == _currentStepNotifier.value;

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
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      widget.titles[index],
                      style: isActive
                          ? TextStyle(color: theme.colorScheme.primary)
                          : null,
                    ),
                    selected: isActive,
                    onTap: () {
                      setState(() {
                        _currentStepNotifier.value = index;
                        _scrollToActiveStep();
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Expanded(
                  child: IndexedStack(
                    index: _currentStepNotifier.value,
                    children: widget.steps,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStepNotifier.value > 0)
                        ElevatedButton(
                          onPressed: (){
                            _goToPreviousStep(null);
                          },
                          child: const Text('Back'),
                        )
                      else
                        const Spacer(flex: 3),
                      Text(
                          '${_currentStepNotifier.value + 1}/${widget.steps.length}'),
                      if (_currentStepNotifier.value == 0)
                        const Spacer(flex: 2),
                      _currentStepNotifier.value == widget.steps.length - 1
                          ? ElevatedButton(
                              onPressed: _submitForm,
                              child: const Text('Submit'),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                _goToNextStep(null);
                              },
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

  /// Builds the list of steps for the [Stepper] widget.
  ///
  /// Creates a list of [Step] widgets, each representing a step in the stepper.
  /// The current step is marked as active and editable.
  List<Step> _buildSteps() {
    return List.generate(widget.steps.length, (index) {
      return Step(
        title: Text(widget.titles[index]),
        content: widget.steps[index],
        isActive: index == _currentStepNotifier.value,
        state: index == _currentStepNotifier.value
            ? StepState.editing
            : StepState.indexed,
      );
    });
  }
}
