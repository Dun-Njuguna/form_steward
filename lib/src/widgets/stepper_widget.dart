import 'package:flutter/material.dart';
import 'package:form_steward/src/utils/steward_stepper_type.dart';

/// A widget that displays a step-by-step form with custom titles for each step.
class StepperWidget extends StatefulWidget {
  /// The list of widgets to be displayed as the content of each step.
  final List<Widget> steps;

  /// The list of custom titles for each step.
  final List<String> titles;

  /// The callback function to be called when the user continues to the next step.
  final VoidCallback onNextClicked;

  /// The callback function to be called when the user cancels or goes back to the previous step.
  final VoidCallback onBackClicked;

  /// The callback function to be called when the user completes the form and submits.
  final VoidCallback onSubmitClicked;

  /// The index of the currently active step.
  final int currentStep;

  /// The type of stepper to render.
  final StewardStepperType stepperType;

  const StepperWidget({
    Key? key,
    required this.steps,
    required this.titles,
    required this.onNextClicked,
    required this.onBackClicked,
    required this.currentStep,
    required this.stepperType,
    required this.onSubmitClicked,
  }) : super(key: key);

  @override
  _StepperWidgetState createState() => _StepperWidgetState();
}

class _StepperWidgetState extends State<StepperWidget> {
  late final ValueNotifier<int> _currentStepNotifier;

  @override
  void initState() {
    super.initState();
    _currentStepNotifier = ValueNotifier(widget.currentStep);
  }

  @override
  void didUpdateWidget(covariant StepperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStep != oldWidget.currentStep) {
      _currentStepNotifier.value = widget.currentStep;
    }
  }

  @override
  void dispose() {
    _currentStepNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.stepperType) {
      case StewardStepperType.vertical:
        return _buildVerticalStepper();
      case StewardStepperType.horizontal:
        return _buildHorizontalStepper(context);
      case StewardStepperType.tablet:
        return _buildTabletStepper(context);
    }
  }

  Widget _buildVerticalStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stepper(
            currentStep: _currentStepNotifier.value,
            onStepContinue:
                _currentStepNotifier.value == widget.steps.length - 1
                    ? widget.onSubmitClicked
                    : widget.onNextClicked,
            onStepCancel:
                _currentStepNotifier.value > 0 ? widget.onBackClicked : null,
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
                    onPressed: widget.onBackClicked,
                    child: const Text('Back'),
                  )
                else
                  const Spacer(flex: 3),
                Text(
                    '${_currentStepNotifier.value + 1}/${widget.steps.length}'),
                if (_currentStepNotifier.value == 0) const Spacer(flex: 2),
                _currentStepNotifier.value == widget.steps.length - 1
                    ? ElevatedButton(
                        onPressed: widget.onSubmitClicked,
                        child: const Text('Submit'),
                      )
                    : ElevatedButton(
                        onPressed: widget.onNextClicked,
                        child: const Text('Next'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletStepper(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: ListView.builder(
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
                    if (index < _currentStepNotifier.value) {
                      widget.onBackClicked();
                    } else if (index > _currentStepNotifier.value) {
                      widget.onNextClicked();
                    }
                  });
                },
              );
            },
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
                          onPressed: widget.onBackClicked,
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
                              onPressed: widget.onSubmitClicked,
                              child: const Text('Submit'),
                            )
                          : ElevatedButton(
                              onPressed: widget.onNextClicked,
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
    return widget.steps.asMap().entries.map((entry) {
      int index = entry.key;
      Widget step = entry.value;
      return Step(
        title: Text(widget.titles[index]),
        content: step,
        isActive: index == _currentStepNotifier.value,
      );
    }).toList();
  }
}
