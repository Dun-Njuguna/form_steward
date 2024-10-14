import 'package:flutter/material.dart';
import 'package:form_steward/src/state/form_steward_state.dart';

/// A [ChangeNotifier] class that manages the form state and provides methods
/// to update form data, step validity, and trigger submission actions.
///
/// [FormStewardStateNotifier] maintains and modifies [FormStewardState] using
/// [notifyListeners] to update any listeners when state changes. It provides
/// methods for initializing step validity, updating field values and validity,
/// and retrieving current form data.
class FormStewardStateNotifier extends ChangeNotifier {
  /// Holds the current form state including step validity and form data.
  FormStewardState _state = FormStewardState(stepValidity: {}, formData: {});

  /// Exposes the current form state for access by other components.
  FormStewardState get state => _state;

  /// Initializes the validity for a specific step in the form.
  ///
  /// This method merges the provided step validity into the existing form state,
  /// either updating fields in an existing step or adding a new step with its fields.
  ///
  /// [stepValidity] - A map containing the step name as the key and a nested map
  /// of field names and their boolean validity statuses as the value.
  void initializeStepValidity({
    required Map<String, Map<String, bool>> stepValidity,
  }) {
    // Create a deep copy of the existing step validity state.
    final updatedStepValidity = Map<String, Map<String, bool>>.from(
      _state.stepValidity.map(
        (key, value) => MapEntry(
          key,
          Map<String, bool>.from(value),
        ),
      ),
    );

    // Merge new step validity data with the existing state.
    stepValidity.forEach((stepName, fields) {
      if (updatedStepValidity.containsKey(stepName)) {
        // Merge fields if the step already exists.
        fields.forEach((fieldName, status) {
          updatedStepValidity[stepName]![fieldName] = status;
        });
      } else {
        // Add a new step if it doesn't already exist.
        updatedStepValidity[stepName] = Map<String, bool>.from(fields);
      }
    });

    // Update the state with the new validity map.
    _state = _state.copyWith(stepValidity: updatedStepValidity);

    // Notify listeners that the state has changed.
    notifyListeners();
  }

  /// Updates the value and validity of a specific field in a specific step.
  ///
  /// This method updates the form's data and field validity for a particular
  /// field in a given step, and notifies listeners of the change.
  ///
  /// [stepName] - The name of the step that contains the field.
  /// [fieldName] - The name of the field being updated.
  /// [value] - The new value assigned to the field.
  /// [isValid] - A boolean indicating whether the field is valid.
  void updateField({
    required String stepName,
    required String fieldName,
    required dynamic value,
    required bool isValid,
  }) {
    // Update the form data by adding the new value for the field.
    final updatedFormData = {
      ..._state.formData,
      stepName: {
        ...?_state.formData[stepName],
        fieldName: value,
      },
    };

    // Update the step validity with the new status for the field.
    final updatedStepValidity = {
      ..._state.stepValidity,
      stepName: {
        ...?_state.stepValidity[stepName],
        fieldName: isValid,
      },
    };

    // Apply the updated form data and step validity to the state.
    _state = _state.copyWith(
      formData: updatedFormData,
      stepValidity: updatedStepValidity,
    );

    // Notify listeners about the updated state.
    notifyListeners();
  }

  /// Checks whether all fields in a step are valid.
  ///
  /// Returns `true` if all fields within the given step are valid, or `false`
  /// if any field is invalid or if the step doesn't exist in the form.
  ///
  /// [stepTitle] - The title of the step being checked for validity.
  bool isStepValid({
    required String stepName,
  }) {
    final Map<String, bool>? currentStep = _state.stepValidity[stepName];
    return currentStep?.entries.every((entry) => entry.value == true) ?? false;
  }

  /// Retrieves the current form data for a specific step.
  ///
  /// [currentStepName] - The name of the step for which data should be retrieved.
  /// Returns a map of field names and their associated values for the step, or
  /// `null` if no data exists for the step.
  Map<String, dynamic>? getCurrentStepData({
    required String currentStepName,
  }) {
    return _state.formData[currentStepName];
  }

  /// Retrieves the entire form's data.
  ///
  /// Returns a map containing step names as keys and nested maps of field names
  /// and their values as the values.
  Map<String, Map<String, dynamic>> getFormData() {
    return _state.formData;
  }
}
