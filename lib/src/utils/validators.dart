/// A utility class for form validation.
///
/// The [Validators] class provides static methods for common validation
/// checks, such as ensuring that a field is required or that its value
/// meets a minimum length requirement. These methods return validation
/// error messages if the checks fail.
class Validators {
  /// Validates that a field is required.
  ///
  /// This method checks if the provided [value] is null or empty. If it
  /// is, it returns an error message indicating that the field, identified
  /// by [label], is required. If the value is present, it returns `null`,
  /// indicating that the validation passed.
  ///
  /// - Parameter value: The value of the field to validate.
  /// - Parameter label: The label of the field, used in the error message.
  ///
  /// - Returns: A [String?] containing the error message if validation fails;
  /// otherwise, `null`.
  static String? requiredField(String? value, String label) {
    if (value == null || value.isEmpty) {
      return '$label is required';
    }
    return null;
  }

  /// Validates that a field meets a minimum length requirement.
  ///
  /// This method checks if the provided [value] has at least the specified
  /// [minLength]. If the value's length is less than the minimum length, it
  /// returns an error message indicating that the field, identified by [label],
  /// must be at least [minLength] characters long. If the value meets the
  /// requirement, it returns `null`, indicating that the validation passed.
  ///
  /// - Parameter value: The value of the field to validate.
  /// - Parameter minLength: The minimum length that the field's value must meet.
  /// - Parameter label: The label of the field, used in the error message.
  ///
  /// - Returns: A [String?] containing the error message if validation fails;
  /// otherwise, `null`.
  static String? minLength(String? value, int minLength, String label) {
    if (value != null && value.length < minLength) {
      return '$label must be at least $minLength characters';
    }
    return null;
  }
}
