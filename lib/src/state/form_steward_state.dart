/// Represents the state of the form, including the validity of each step
/// and the data entered in each step's fields.
/// 
/// This class manages two key aspects of the form:
/// 1. [stepValidity] - Tracks the validity of each step, where each step maps to 
///    a nested map of field names and their respective boolean validity statuses (true or false).
/// 2. [formData] - Holds the form data for each step, where each step maps to 
///    a nested map of field names and their associated values entered by the user.
class FormStewardState {
  /// A map that tracks the validity of each step.
  ///
  /// The key is the step name, and the value is another map that tracks the validity
  /// of each field in that step. Each field name maps to a boolean that indicates 
  /// whether the field is valid (`true`) or not (`false`).
  final Map<String, Map<String, bool>> stepValidity;

  /// A map that holds the form data for each step.
  ///
  /// The key is the step name, and the value is another map that holds the field 
  /// data for that step. Each field name maps to a dynamic value that represents 
  /// the data entered by the user.
  final Map<String, Map<String, dynamic>> formData;

  /// Creates a new instance of [FormStewardState].
  ///
  /// [stepValidity] - A required map that contains the validity status of each step's fields.
  /// [formData] - A required map that contains the data for each step's fields.
  FormStewardState({
    required this.stepValidity,
    required this.formData,
  });

  /// Creates a copy of the current state with optional updates to [stepValidity] and/or [formData].
  ///
  /// This method is useful for updating the state immutably by creating a new instance
  /// of [FormStewardState] with the updated values. If [stepValidity] or [formData] are not 
  /// provided, the current values are used.
  ///
  /// [stepValidity] - A new map of step names to validity statuses. This is required.
  /// [formData] - An optional new map of step names to field data. If null, the current form data is retained.
  /// 
  /// Returns a new [FormStewardState] instance with the updated values.
  FormStewardState copyWith({
    required Map<String, Map<String, bool>> stepValidity,
    Map<String, Map<String, dynamic>>? formData,
  }) {
    return FormStewardState(
      stepValidity: stepValidity,
      formData: formData ?? this.formData,
    );
  }
}
