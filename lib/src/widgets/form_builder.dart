import 'package:flutter/material.dart';
import '../models/form_step_model.dart';
import 'form_field_widget.dart';

/// A widget that builds a dynamic form based on a list of form steps.
///
/// The [FormBuilder] class takes a list of [FormStepModel] instances and
/// dynamically generates a form. Each form step is represented by a
/// [FormStepModel], which includes a title and a list of fields. The
/// widget uses [FormFieldWidget] to render each field within the form steps.
class FormBuilder extends StatelessWidget {
  /// The list of form steps to be built into the form.
  ///
  /// The [steps] parameter is a list of [FormStepModel] instances that define
  /// the structure and content of the form. Each step includes a title and
  /// a list of fields to be displayed in that step.
  final List<FormStepModel> steps;

  /// Creates a new instance of the [FormBuilder] class.
  ///
  /// The [steps] parameter is required and should contain the form steps
  /// that define the form's structure.
  ///
  /// - Parameter steps: The list of form steps to be rendered.
  const FormBuilder({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps
          .map((step) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Optionally include a title for each step:
                  // Text(
                  //   step.title,
                  //   style: const TextStyle(
                  //       fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  ...step.fields.map((field) => FormFieldWidget(field: field)),
                ],
              ))
          .toList(),
    );
  }
}
