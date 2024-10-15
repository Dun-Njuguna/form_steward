import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/breakpoints.dart';
import 'package:form_steward/src/controllers/step_controller.dart';
import 'package:form_steward/src/widgets/steppers/step_indicator.dart';

/// A widget that builds the tablet layout for the stepper,
/// which includes a scrollable list of steps on the left and the form content on the right.
class TabletStepperWidget extends StatefulWidget {
  /// List of form steps to be displayed in the stepper.
  final List<FormStepModel> formSteps;

  /// Notifier for triggering form validation.
  final ValidationTriggerNotifier formStewardNotifier;

  /// Notifier for managing the state of the form steward.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// Callback function to be called when a step is completed.
  ///
  /// The function takes a Map<String, dynamic> as an argument,
  /// representing the step data for the current step.
  final Function(Map<String, dynamic>) submitStepData;

  /// Callback function to be called when the form is submitted.
  ///
  /// The function takes a Map<String, Map<String, dynamic>> as an argument,
  /// representing the form data.
  final Function(Map<String, Map<String, dynamic>>) submitFormData;

  const TabletStepperWidget({
    super.key,
    required this.formSteps,
    required this.formStewardNotifier,
    required this.formStewardStateNotifier,
    required this.submitStepData,
    required this.submitFormData,
  });

  @override
  TabletStepperWidgetState createState() => TabletStepperWidgetState();
}

class TabletStepperWidgetState extends State<TabletStepperWidget> {
  late final StepController _currentStepNotifier;
  late final ScrollController _scrollController;
  final double _itemHeight = 62;
  bool _isDisposed = false; // Flag to check if the widget is disposed

  late final List<Widget> stepWidgets = widget.formSteps.map((step) {
    return FormBuilder(
      steps: [step],
      validationTriggerNotifier: widget.formStewardNotifier,
      formStewardStateNotifier: widget.formStewardStateNotifier,
    );
  }).toList();

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _currentStepNotifier = StepController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TabletStepperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  /// Moves to the next step if possible.
  ///
  /// [index] is the index of the next step.
  void _goToNextStep() {
    if (_currentStepNotifier.getCurrentStep() + 1 < widget.formSteps.length) {
      final data = widget.formStewardStateNotifier.getCurrentStepData(
          currentStepName:
              widget.formSteps[_currentStepNotifier.getCurrentStep()].name);
      if (data != null) {
        widget.submitStepData(data);
      }
      updateCurrentStep(_currentStepNotifier.getCurrentStep() + 1);
    }
  }

  /// Moves to the previous step if possible.
  ///
  /// [index] is the index of the previous step.
  void _goToPreviousStep() {
    final previousStep = _currentStepNotifier.getCurrentStep() - 1;
    if (previousStep >= 0) {
      updateCurrentStep(previousStep);
    }
  }

  /// Updates the current step index and triggers a rebuild.
  ///
  /// [index] is the new step index.
  void updateCurrentStep(int index) {
    setState(() {
      _currentStepNotifier.updateCurrentStep(index);
    });
  }

  /// Submits the form by calling the [onSubmit] callback.
  void _submitForm() {
    widget.submitFormData(widget.formStewardStateNotifier.getFormData());
  }

  /// Scrolls to the active step if it is not visible in the scrollable list.
  void _scrollToActiveStep(_) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is disposed before proceeding
      if (_isDisposed) return;
      final stepIndex = _currentStepNotifier.getCurrentStep();
      final itemOffset = _itemHeight * stepIndex;

      if (_isStepVisible(stepIndex)) {
        return;
      }
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          itemOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Checks if a step at the given index is visible within the viewport.
  bool _isStepVisible(int index) {
    final viewport = _scrollController.position;
    final itemOffset = _itemHeight * index;
    final itemEndOffset = itemOffset + _itemHeight;

    return itemOffset >= viewport.pixels &&
        itemEndOffset <= viewport.pixels + viewport.viewportDimension;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StepListWidget(
          formSteps: widget.formSteps,
          currentStepNotifier: _currentStepNotifier,
          scrollController: _scrollController,
          onStepTap: (index) {
            setState(() {
              updateCurrentStep(index);
              _scrollToActiveStep(null);
            });
          },
        ),
        FormContentWidget(
          currentStepNotifier: _currentStepNotifier,
          stepWidgets: stepWidgets,
          formSteps: widget.formSteps,
          goToPreviousStep: _goToPreviousStep,
          goToNextStep: _goToNextStep,
          submitForm: _submitForm,
        ),
      ],
    );
  }
}

class StepListWidget extends StatelessWidget {
  final List<FormStepModel> formSteps;
  final StepController currentStepNotifier;
  final ScrollController scrollController;
  final Function(int) onStepTap;

  const StepListWidget({
    super.key,
    required this.formSteps,
    required this.currentStepNotifier,
    required this.scrollController,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final scallingFactor = screenWidth <= Breakpoints.lg ? 0.2 : 0.15;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: screenWidth * scallingFactor,
            height: screenSize.height,
            child: SingleChildScrollView(
              child: StepIndicator(
                formSteps: formSteps,
                currentStep: currentStepNotifier.getCurrentStep(),
                stepperType: StewardStepperType.tablet,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormContentWidget extends StatelessWidget {
  final StepController currentStepNotifier;
  final List<Widget> stepWidgets;
  final List<FormStepModel> formSteps;
  final VoidCallback goToPreviousStep;
  final VoidCallback goToNextStep;
  final VoidCallback submitForm;

  const FormContentWidget({
    super.key,
    required this.currentStepNotifier,
    required this.stepWidgets,
    required this.formSteps,
    required this.goToPreviousStep,
    required this.goToNextStep,
    required this.submitForm,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    child: IndexedStack(
                      index: currentStepNotifier.getCurrentStep(),
                      children: stepWidgets,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentStepNotifier.getCurrentStep() > 0)
                        ElevatedButton(
                          onPressed: goToPreviousStep,
                          child: const Text('Back'),
                        )
                      else
                        const Spacer(flex: 3),
                      Text(
                          '${currentStepNotifier.getCurrentStep() + 1}/${formSteps.length}'),
                      if (currentStepNotifier.getCurrentStep() == 0)
                        const Spacer(flex: 2),
                      currentStepNotifier.getCurrentStep() ==
                              formSteps.length - 1
                          ? ElevatedButton(
                              onPressed: submitForm,
                              child: const Text('Submit'),
                            )
                          : ElevatedButton(
                              onPressed: goToNextStep,
                              child: const Text('Next'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
