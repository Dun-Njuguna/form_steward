/// A model representing validation rules for a form field.
///
/// The [ValidationModel] class encapsulates the validation rules that apply to
/// a form field. It includes information on whether the field is required,
/// and if applicable, the minimum and maximum length constraints for the field's
/// value.
class ValidationModel {
  /// Indicates whether the field is required.
  ///
  /// The [required] flag specifies whether the form field must be filled out
  /// in order for the form to be considered valid. If `true`, the field is
  /// required; if `false`, the field is optional.
  final bool required;

  /// The minimum length constraint for the field's value.
  ///
  /// The [minLength] specifies the minimum number of characters that the
  /// field's value must have. If `null`, there is no minimum length constraint.
  final int? minLength;

  /// The maximum length constraint for the field's value.
  ///
  /// The [maxLength] specifies the maximum number of characters that the
  /// field's value can have. If `null`, there is no maximum length constraint.
  final int? maxLength;

  /// Creates a new instance of the [ValidationModel] class.
  ///
  /// All properties are required or optional based on the validation requirements.
  ///
  /// - [required]: Indicates whether the field is required.
  /// - [minLength]: The minimum length constraint for the field's value.
  /// - [maxLength]: The maximum length constraint for the field's value.
  ValidationModel({
    required this.required,
    this.minLength,
    this.maxLength,
  });

  /// Creates a new [ValidationModel] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize a [ValidationModel] from a
  /// JSON object. It extracts the validation rules from the JSON and uses them
  /// to create a [ValidationModel] instance.
  ///
  /// - [json]: A map representing the JSON object with keys for `required`,
  /// `minLength`, and `maxLength`.
  ///
  /// Returns a new [ValidationModel] instance populated with the values from the JSON map.
  factory ValidationModel.fromJson(Map<String, dynamic> json) {
    return ValidationModel(
      required: json['required'],
      minLength: json['minLength'],
      maxLength: json['maxLength'],
    );
  }
}
