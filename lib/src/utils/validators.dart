class Validators {
  
  static bool validateRequiredField({
    required String fieldLabel,
    required String? fieldValue,
    required Function(String? errorMessage) setError,
  }) {
    if (fieldValue == null || fieldValue.isEmpty) {
      setError('$fieldLabel is required');
      return false;
    } else {
      setError(null); // No error
      return true;
    }
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
