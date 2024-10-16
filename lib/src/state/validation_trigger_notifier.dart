import 'package:flutter/material.dart';

/// A [ValueNotifier] that triggers validation events for a specific form step.
///
/// This notifier is designed to notify listeners when validation should be triggered
/// for a particular step in a form. Widgets or fields can listen to this notifier and
/// initiate their validation process when its value changes. The value of this notifier
/// is the name of the step that needs validation.
class ValidationTriggerNotifier extends ValueNotifier<String?> {
  // Private static field for the singleton instance
  static ValidationTriggerNotifier? _instance;

  /// Private constructor to prevent external instantiation
  ValidationTriggerNotifier._internal() : super(null);

  /// Public static method to access the singleton instance
  ///
  /// This ensures that only one instance of [ValidationTriggerNotifier] exists.
  static ValidationTriggerNotifier get instance {
    _instance ??= ValidationTriggerNotifier._internal();
    return _instance!;
  }

  /// Triggers validation for a specific step.
  ///
  /// This method sets the value of the notifier to the provided [stepName],
  /// which indicates that validation should be performed for that step.
  /// Any listeners to this notifier will react accordingly to validate the fields
  /// associated with the given step.
  ///
  /// [stepName] - The name of the step for which validation is being triggered.
  void triggerValidation(String stepName) {
    value = stepName;
  }

  /// Resets the validation trigger.
  ///
  /// This method clears the current validation trigger by setting the notifier's value
  /// back to `null`.
  void reset() {
    value = null;
  }
}
