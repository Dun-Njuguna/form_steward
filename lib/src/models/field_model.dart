import 'package:form_steward/src/models/validation_model.dart';
import 'package:form_steward/src/models/dependency_model.dart';
import 'package:form_steward/src/models/option_model.dart'; // Import OptionModel

/// A model representing a form field.
///
/// The [FieldModel] class encapsulates the properties of a form field, including
/// its type, label, name, options, and validation rules. It is typically used to define
/// the structure and behavior of individual fields within a dynamic form.
class FieldModel {
  /// The type of the form field (e.g., "text", "number", "file", "image", "audio", "video").
  final String type;

  /// The label of the form field.
  final String label;

  /// The name of the form field.
  final String name;

  /// The validation rules for the form field.
  final ValidationModel? validation;

  /// URL to fetch options for select fields.
  final String? fetchOptionsUrl;

  /// Indicates if the field allows multiple selections.
  final bool? multiSelect;

  /// The default value for the field.
  final dynamic value;

  /// Dependencies for the form field.
  ///
  /// The [dependencies] list contains information about other fields that influence
  /// the options or visibility of this field.
  final List<DependencyModel>? dependencies;

  /// Options for select or multi-select fields.
  ///
  /// The [options] list contains possible values that the user can select from
  /// if the field type supports selectable options (like dropdowns or radio buttons).
  final List<OptionModel>? options; // Added field for options

  FieldModel({
    required this.type,
    required this.label,
    required this.name,
    this.validation,
    this.fetchOptionsUrl,
    this.multiSelect,
    this.value,
    this.dependencies,
    this.options, // Initialize options in constructor
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      type: json['type'],
      label: json['label'],
      name: json['name'],
      validation: json['validation'] != null
          ? ValidationModel.fromJson(json['validation'])
          : null,
      fetchOptionsUrl: json['fetchOptionsUrl'],
      multiSelect: json['multiSelect'] ?? false,
      value: json['value'],
      dependencies: json['dependencies'] != null
          ? (json['dependencies'] as List)
              .map((depJson) => DependencyModel.fromJson(depJson))
              .toList()
          : null,
      options: json['options'] != null // Added options handling in fromJson
          ? (json['options'] as List)
              .map((optionJson) => OptionModel.fromMap(optionJson))
              .toList()
          : null,
    );
  }
}
