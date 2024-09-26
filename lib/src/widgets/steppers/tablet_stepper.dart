import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/breakpoints.dart';

/// A widget that builds the tablet layout for the stepper,
/// which includes a scrollable list of steps on the left and the form content on the right.
class TabletStepperWidget extends StatefulWidget {
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

  final Function(Map<String, dynamic>) onNext;
  final Function() onPrevious;

  const TabletStepperWidget({
    super.key,
    required this.formSteps,
    required this.formStewardNotifier,
    required this.formStewardStateNotifier,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
  });

  @override
  TabletStepperWidgetState createState() => TabletStepperWidgetState();
}

class TabletStepperWidgetState extends State<TabletStepperWidget> {
  late final ValueNotifier<int> _currentStepNotifier;
  late final ScrollController _scrollController;
  final double _itemHeight = 62;
  late final int currentStep;

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
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentStepNotifier = ValueNotifier<int>(0);
    currentStep = _currentStepNotifier.value;
  }

  @override
  void dispose() {
    _currentStepNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TabletStepperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentStepNotifier.value == currentStep) {
      currentStep = _currentStepNotifier.value;
      _scrollToActiveStep();
    }
  }

  /// Moves to the next step if possible.
  ///
  /// [index] is the index of the next step.
  void _goToNextStep() {
    final nextStep = _currentStepNotifier.value + 1;
    if (_currentStepNotifier.value + 1 < widget.formSteps.length) {
      updateCurrentStep(nextStep);
    }
  }

  /// Moves to the previous step if possible.
  ///
  /// [index] is the index of the previous step.
  void _goToPreviousStep() {
    final previousStep = _currentStepNotifier.value - 1;
    if (previousStep >= 0) {
      updateCurrentStep(previousStep);
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

  /// Scrolls to the active step if it is not visible in the scrollable list.
  void _scrollToActiveStep() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stepIndex = _currentStepNotifier.value;
      final itemOffset = _itemHeight * stepIndex;

      if (_isStepVisible(stepIndex)) {
        return;
      }
      _scrollController.animateTo(
        itemOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
              _currentStepNotifier.value = index;
              _scrollToActiveStep();
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
  final ValueNotifier<int> currentStepNotifier;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final scallingFactor =  screenWidth <= Breakpoints.lg ? 0.3 : 0.2;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: screenWidth * scallingFactor,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical:20.0),
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              interactive: true,
              thickness: 1.2,
              child: ListView.builder(
                controller: scrollController,
                itemCount: formSteps.length,
                itemBuilder: (context, index) {
                  final theme = Theme.of(context);
                  final isActive = index == currentStepNotifier.value;
                      
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
                      formSteps[index].title,
                      style: isActive
                          ? TextStyle(color: theme.colorScheme.primary)
                          : null,
                    ),
                    selected: isActive,
                    onTap: () => onStepTap(index),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormContentWidget extends StatelessWidget {
  final ValueNotifier<int> currentStepNotifier;
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
            padding: const EdgeInsets.symmetric(horizontal: 10.0,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    child: IndexedStack(
                      index: currentStepNotifier.value,
                      children: stepWidgets,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:  8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentStepNotifier.value > 0)
                        ElevatedButton(
                          onPressed: goToPreviousStep,
                          child: const Text('Back'),
                        )
                      else
                        const Spacer(flex: 3),
                      Text('${currentStepNotifier.value + 1}/${formSteps.length}'),
                      if (currentStepNotifier.value == 0) const Spacer(flex: 2),
                      currentStepNotifier.value == formSteps.length - 1
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
