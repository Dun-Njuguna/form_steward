import 'package:flutter/material.dart';

/// A utility class that manages a [ValueNotifier] for an integer step value.
///
/// This class follows the Singleton pattern, ensuring that only a single
/// instance of the [StepController] exists throughout the app.
/// It provides methods to access and update the current step value
/// via the [_currentStepNotifier].
class StepController {
  /// The Singleton instance of the [StepController].
  static final StepController _instance = StepController._internal();

  /// A [ValueNotifier] that holds the current step value.
  ///
  /// The step value is initialized to 0 and can be updated via
  /// the [updateCurrentStep] method.
  final ValueNotifier<int> _currentStepNotifier = ValueNotifier<int>(0);

  /// Private constructor for the Singleton instance.
  ///
  /// This constructor is only called internally and ensures that
  /// no additional instances of [StepController] are created.
  StepController._internal();

  /// Factory constructor that returns the Singleton instance.
  ///
  /// This ensures that every time [StepController] is instantiated,
  /// the same instance is returned.
  factory StepController() {
    return _instance;
  }

  /// Returns the current step value stored in the [ValueNotifier].
  ///
  /// This method allows access to the current value of the step.
  /// Example usage:
  /// ```dart
  /// int currentStep = StepNotifierUtility().getCurrentStep();
  /// ```
  int getCurrentStep() {
    return _currentStepNotifier.value;
  }

  /// Updates the current step value stored in the [ValueNotifier].
  ///
  /// This method updates the value of the current step to the provided [step].
  /// Example usage:
  /// ```dart
  /// StepNotifierUtility().updateCurrentStep(5);
  /// ```
  ///
  /// [step] is the new value to set for the current step.
  void updateCurrentStep(int step) {
    _currentStepNotifier.value = step;
  }

  /// Returns the [ValueNotifier] that holds the current step value.
  ///
  /// This can be useful if you need to directly listen for changes in the
  /// step value using a [ValueListenableBuilder].
  /// Example usage:
  /// ```dart
  /// ValueListenableBuilder<int>(
  ///   valueListenable: StepNotifierUtility().currentStepNotifier,
  ///   builder: (context, value, child) {
  ///     return Text('Step: $value');
  ///   },
  /// );
  /// ```
  ValueNotifier<int> get currentStepNotifier => _currentStepNotifier;

  /// Disposes the [ValueNotifier] to release resources.
  ///
  /// This should be called when the [StepController] is no longer needed
  /// to avoid memory leaks.
  void dispose() {
    _currentStepNotifier.dispose();
  }
}
