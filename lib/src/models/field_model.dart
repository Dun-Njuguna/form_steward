import 'package:form_steward/src/models/validation_model.dart';

/// A model representing a form field.
///
/// The [FieldModel] class encapsulates the properties of a form field, including
/// its type, label, name, and validation rules. It is typically used to define
/// the structure and behavior of individual fields within a dynamic form.
class FieldModel {
  /// The type of the form field (e.g., "text", "number").
  ///
  /// The [type] defines what kind of input the field will accept. This could be
  /// text, number, date, etc. It is used to determine the appropriate widget
  /// and validation logic for the field.
  final String type;

  /// The label of the form field.
  ///
  /// The [label] is a human-readable string that describes the field's purpose
  /// and is typically displayed next to or above the field in the UI.
  final String label;

  /// The name of the form field.
  ///
  /// The [name] serves as a unique identifier for the field within the form. It
  /// is often used as a key for storing and retrieving the field's value from
  /// form data.
  final String name;

  /// The validation rules for the form field.
  ///
  /// The [validation] contains the validation logic for the field, such as
  /// required status, minimum length, or custom validators. This is represented
  /// by the [ValidationModel] class.
  final ValidationModel validation;

  /// Creates a new instance of the [FieldModel] class.
  ///
  /// All properties are required to ensure that the form field is properly
  /// configured.
  ///
  /// - [type]: The type of the form field.
  /// - [label]: The label of the form field.
  /// - [name]: The name of the form field.
  /// - [validation]: The validation rules for the form field.
  FieldModel({
    required this.type,
    required this.label,
    required this.name,
    required this.validation,
  });

  /// Creates a new [FieldModel] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize a [FieldModel] from a
  /// JSON object. It extracts the field properties from the JSON and uses
  /// them to create a [FieldModel] instance.
  ///
  /// - [json]: A map representing the JSON object with keys for `type`, `label`,
  /// `name`, and `validation`.
  ///
  /// Returns a new [FieldModel] instance populated with the values from the JSON map.
  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      type: json['type'],
      label: json['label'],
      name: json['name'],
      validation: ValidationModel.fromJson(json['validation']),
    );
  }
}
