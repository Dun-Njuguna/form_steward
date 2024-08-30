import 'package:form_steward/src/models/field_model.dart';

/// A model representing a step in a multi-step form.
///
/// The [FormStepModel] class encapsulates the properties of a single step within
/// a multi-step form. Each step includes a title and a list of fields that
/// belong to that step. This model is typically used to define the structure
/// and content of each step in a dynamic form.
class FormStepModel {
  /// The title of the form step.
  final String title;

  /// The list of form fields associated with this step.
  final List<FieldModel> fields;

  FormStepModel({
    required this.title,
    required this.fields,
  });

  factory FormStepModel.fromJson(Map<String, dynamic> json) {
    return FormStepModel(
      title: json['title'],
      fields: (json['fields'] as List)
          .map((fieldJson) => FieldModel.fromJson(fieldJson))
          .toList(),
    );
  }
}
