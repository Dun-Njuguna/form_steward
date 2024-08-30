/// A model representing validation rules for a form field.
///
/// The [ValidationModel] class encapsulates the validation rules that apply to
/// a form field. It includes information on whether the field is required,
/// and if applicable, the minimum and maximum length constraints for the field's
/// value, as well as a regex pattern for custom validation.
class ValidationModel {
  /// Indicates whether the field is required.
  final bool required;

  /// The minimum length constraint for the field's value.
  final int? minLength;

  /// The maximum length constraint for the field's value.
  final int? maxLength;

  /// The regex pattern for custom validation (e.g., email, phone number).
  final String? pattern;

  /// Creates a new instance of the [ValidationModel] class.
  ///
  /// All properties are required or optional based on the validation requirements.
  ///
  /// - [required]: Indicates whether the field is required.
  /// - [minLength]: The minimum length constraint for the field's value.
  /// - [maxLength]: The maximum length constraint for the field's value.
  /// - [pattern]: The regex pattern for custom validation.
  ValidationModel({
    this.required = false,
    this.minLength,
    this.maxLength,
    this.pattern,
  });

  /// Creates a new [ValidationModel] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize a [ValidationModel] from a
  /// JSON object. It extracts the validation rules from the JSON and uses them
  /// to create a [ValidationModel] instance.
  ///
  /// - [json]: A map representing the JSON object with keys for `required`,
  /// `minLength`, `maxLength`, and `pattern`.
  ///
  /// Returns a new [ValidationModel] instance populated with the values from the JSON map.
  factory ValidationModel.fromJson(Map<String, dynamic> json) {
    return ValidationModel(
      required: json['required'] ?? false,
      minLength: json['minLength'],
      maxLength: json['maxLength'],
      pattern: json['pattern'],
    );
  }
}
