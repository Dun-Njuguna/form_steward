import 'package:form_steward/src/models/field_model.dart';

/// A model representing a step in a multi-step form.
///
/// The [FormStepModel] class encapsulates the properties of a single step within
/// a multi-step form. Each step includes a title and a list of fields that
/// belong to that step. This model is typically used to define the structure
/// and content of each step in a dynamic form.
class FormStepModel {
  /// The title of the form step.
  ///
  /// The [title] provides a descriptive name for the step, typically displayed
  /// at the top of the step or in the stepper navigation. It helps users
  /// understand the context or purpose of the step.
  final String title;

  /// The list of form fields associated with this step.
  ///
  /// The [fields] represent the individual form fields that are part of this
  /// step. Each field is defined using the [FieldModel] class, which includes
  /// properties like the field type, label, and validation rules.
  final List<FieldModel> fields;

  /// Creates a new instance of the [FormStepModel] class.
  ///
  /// All properties are required to ensure that the form step is properly
  /// configured.
  ///
  /// - [title]: The title of the form step.
  /// - [fields]: The list of form fields in this step.
  FormStepModel({
    required this.title,
    required this.fields,
  });

  /// Creates a new [FormStepModel] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize a [FormStepModel] from a
  /// JSON object. It extracts the step's title and fields from the JSON and
  /// uses them to create a [FormStepModel] instance.
  ///
  /// - [json]: A map representing the JSON object with keys for `title` and
  /// `fields`.
  ///
  /// Returns a new [FormStepModel] instance populated with the values from the JSON map.
  factory FormStepModel.fromJson(Map<String, dynamic> json) {
    return FormStepModel(
      title: json['title'],
      fields: (json['fields'] as List)
          .map((fieldJson) => FieldModel.fromJson(fieldJson))
          .toList(),
    );
  }
}
