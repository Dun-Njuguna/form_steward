import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/widgets/form_builder/responsive_field_layout.dart';
import 'package:media_kit/media_kit.dart';

/// A widget that builds a dynamic form based on a list of form steps.
///
/// The [FormBuilder] class takes a list of [FormStepModel] instances and
/// dynamically generates a form. Each form step is represented by a
/// [FormStepModel], which includes a title and a list of fields. The
/// widget uses [FormFieldWidget] to render each field within the form steps.
class FormBuilder extends StatefulWidget {
  /// The list of form steps to be built into the form.
  ///
  /// The [steps] parameter is a list of [FormStepModel] instances that define
  /// the structure and content of the form. Each step includes a title and
  /// a list of fields to be displayed in that step.
  final List<FormStepModel> steps;

  // Instance of FormStewardStateNotifier
  final ValidationTriggerNotifier validationTriggerNotifier;

  final FormStewardStateNotifier formStewardStateNotifier;

  /// Creates a new instance of the [FormBuilder] class.
  ///
  /// The [steps] parameter is required and should contain the form steps
  /// that define the form's structure.
  ///
  /// - Parameter steps: The list of form steps to be rendered.
  const FormBuilder({
    super.key,
    required this.steps,
    required this.validationTriggerNotifier,
    required this.formStewardStateNotifier,
  });

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  @override
  void initState() {
    super.initState();
    MediaKit.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.steps.map((step) {
        // Initialize step validity
        final Map<String, bool> fieldsValidity = {
          for (var field in step.fields) field.name: true
        };
        widget.formStewardStateNotifier.initializeStepValidity(
          stepValidity: {
            step.name: fieldsValidity,
          },
        );
        return ResponsiveFieldLayout(
          step: step,
          validationTriggerNotifier: widget.validationTriggerNotifier,
          formStewardStateNotifier: widget.formStewardStateNotifier,
        );
      }).toList(),
    );
  }
}



