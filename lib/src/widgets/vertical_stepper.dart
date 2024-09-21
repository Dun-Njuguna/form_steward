import 'package:flutter/material.dart';
import 'package:form_steward/src/state/form_steward_state_notifier.dart';
import 'package:form_steward/src/state/validation_trigger_notifier.dart';
import 'package:form_steward/src/models/form_step_model.dart';
import 'package:form_steward/src/widgets/form_builder.dart';

class VerticalStepper extends StatefulWidget {
  final List<FormStepModel> formSteps;
  final ValidationTriggerNotifier formStewardNotifier;
  final FormStewardStateNotifier formStewardStateNotifier;
  final Function(Map<String, Map<String, dynamic>>) onSubmit;

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

class VerticalStepperState extends State<VerticalStepper> {
  late final ValueNotifier<int> _currentStepNotifier;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _currentStepNotifier = ValueNotifier<int>(0);
  }

  void _goToNextStep(int index) {
  if (index < widget.formSteps.length) {
    setState(() {
      currentStep = index;
    });
  }
  }

  void _goToPreviousStep(int index) {
  if (index < widget.formSteps.length) {
    setState(() {
      currentStep = index;
    });
  }
  }

  void _submitForm() {
    widget.onSubmit(widget.formStewardStateNotifier.getFormData());
  }

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
            : (index == _currentStepNotifier.value ? StepState.editing : StepState.indexed),
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
          : () => _goToNextStep(currentStep+1),
      onStepCancel: () => _goToPreviousStep(currentStep-1),
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
                widget.formStewardNotifier.triggerValidation(
                    widget.formSteps[currentStep].name);
                if (widget.formStewardStateNotifier.isStepValid(
                  stepName: widget.formSteps[currentStep].name,
                )) {
                  details.onStepContinue!();
                } else {
                  widget.formStewardNotifier.reset();
                }
              },
              child: Text(
                currentStep == widget.formSteps.length - 1
                    ? 'Submit'
                    : 'Next',
              ),
            ),
          ],
        );
      },
    );
  }
}
