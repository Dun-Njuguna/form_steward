import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

/// A widget that represents a number input field within a form managed by Form Steward.
///
/// The [StewardNumberField] is a number input field that integrates with
/// the Form Steward state management system. It manages validation logic
/// for required fields and ensures numeric input, updating the form state
/// accordingly.
///
/// The widget listens to validation triggers and updates the form state using
/// [FormStewardStateNotifier] and [ValidationTriggerNotifier].
class StewardNumberField extends StatefulWidget {
  /// The model representing the field's properties and validation rules.
  final FieldModel field;

  /// The name of the step to which this field belongs.
  final String stepName;

  /// The [FormStewardStateNotifier] instance to manage the form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// The [ValidationTriggerNotifier] instance used to listen for validation triggers.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// Creates an instance of [StewardNumberField].
  ///
  /// This widget manages a form field, validates it based on the provided
  /// [FieldModel], and updates the form state using [FormStewardStateNotifier].
  const StewardNumberField({
    super.key,
    required this.field,
    required this.stepName,
    required this.formStewardStateNotifier,
    required this.validationTriggerNotifier,
  });

  @override
  State<StewardNumberField> createState() => _StewardNumberFieldState();
}

class _StewardNumberFieldState extends State<StewardNumberField> {
  /// Stores the error message to display when validation fails.
  String? _errorMessage;

  /// Stores the current value of the number field.
  String? textValue;

  @override
  void initState() {
    super.initState();
    // Listen for validation trigger events from ValidationTriggerNotifier.
    widget.validationTriggerNotifier.addListener(_onValidationTrigger);
  }

  @override
  void dispose() {
    // Remove the validation trigger listener when the widget is disposed.
    widget.validationTriggerNotifier.removeListener(_onValidationTrigger);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Displays the label and error message for the number field.
      decoration: InputDecoration(
        labelText: widget.field.label,
        errorText: _errorMessage,
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        // Update the value of the number field when the user changes the input.
        textValue = value;
      },
    );
  }

  /// Validates the number field based on the required and numeric validation rules.
  ///
  /// If the field is required but no value is provided, an error message is
  /// displayed, and the form state is updated as invalid. If the input is not a
  /// valid number, an error message is displayed. Otherwise, the error message is
  /// cleared, and the form state is updated as valid.
  void _validate([String? value]) {
    // Required field validation
    bool isValid = Validators.validateRequiredField(
      fieldLabel: widget.field.label,
      fieldValue: textValue,
      setError: (errorMessage) {
        setState(() {
          _errorMessage = errorMessage;
        });
      },
    );

    if (!isValid) {
      updateState(false);
      return;
    }

    // Numeric field validation
    if (textValue != null) {
      final numValue = num.tryParse(textValue!);
      if (numValue == null) {
        setState(() {
          _errorMessage = '${widget.field.label} must be a valid number';
        });
        updateState(false);
        return;
      }
    }

    // Clear error if validation passes
    setState(() {
      _errorMessage = null;
    });
    updateState(true);
  }

  /// Updates the form state using [FormStewardStateNotifier].
  ///
  /// The method updates the form state by passing the field name, the current
  /// value, and the validity status of the field to [FormStewardStateNotifier].
  void updateState(bool isValid) {
    widget.formStewardStateNotifier.updateField(
        stepName: widget.stepName,
        fieldName: widget.field.name,
        value: textValue,
        isValid: isValid);
  }

  /// Handles the validation trigger when [ValidationTriggerNotifier] triggers validation.
  ///
  /// This method listens for validation triggers specific to this field's step
  /// and validates the field when the trigger occurs.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate(textValue);
    }
  }
}
