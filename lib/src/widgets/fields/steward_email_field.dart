import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

/// A widget that represents an email field within a form managed by Form Steward.
///
/// The [StewardEmailField] is a customizable email input field that works with
/// the Form Steward state management system to handle field validation and state updates.
/// This widget listens for validation triggers and updates the form state accordingly.
///
/// The widget receives a [FieldModel] that defines the field's properties such as
/// label and validation rules. It also interacts with [FormStewardStateNotifier]
/// to update the form state and [ValidationTriggerNotifier] to trigger field validation.
class StewardEmailField extends StatefulWidget {
  /// The model representing the field's properties and validation rules.
  final FieldModel field;

  /// The name of the step to which this field belongs.
  final String stepName;

  /// The [FormStewardStateNotifier] instance to manage the form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// The [ValidationTriggerNotifier] instance used to listen for validation triggers.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// Creates an instance of [StewardEmailField].
  ///
  /// This widget manages an email form field, validates it based on the provided
  /// [FieldModel], and updates the form state using [FormStewardStateNotifier].
  const StewardEmailField({
    super.key,
    required this.field,
    required this.stepName,
    required this.formStewardStateNotifier,
    required this.validationTriggerNotifier,
  });

  @override
  State<StewardEmailField> createState() => _StewardEmailFieldState();
}

class _StewardEmailFieldState extends State<StewardEmailField> {
  /// Stores the error message to display when validation fails.
  String? _errorMessage;

  /// Stores the current value of the email field.
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
      decoration: InputDecoration(
        labelText: widget.field.label,
        errorText: _errorMessage,
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        // Update the value of the email field when the user changes the input.
        textValue = value;
      },
      onEditingComplete: () => _validate(),
    );
  }

  /// Validates the field based on the required and pattern validation rules.
  ///
  /// This method validates the field for required input and checks whether
  /// the input matches the provided pattern (email format).
  void _validate([String? value]) {
    // Required field validation
    bool isValid = Validators.validateRequiredField(
      validationRequired: widget.field.validation?.required ?? false,
      fieldLabel: widget.field.label,
      fieldValue: textValue,
      setError: (errorMessage) {
        setState(() {
          _errorMessage = errorMessage;
        });
      },
    );

    // If required validation fails, update state and return.
    if (!isValid) {
      updateState(false);
      return;
    }

    // Email pattern validation
    if (widget.field.validation?.pattern != null && textValue != null) {
      final emailPattern = RegExp(widget.field.validation!.pattern!);
      if (!emailPattern.hasMatch(textValue!)) {
        setState(() {
          _errorMessage = 'Invalid ${widget.field.label}';
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
  /// This method updates the form state by passing the field name, the current
  /// value, and the validity status of the field to [FormStewardStateNotifier].
  void updateState(bool isValid) {
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName,
      fieldName: widget.field.name,
      value: textValue,
      isValid: isValid,
    );
  }

  /// Handles the validation trigger when [ValidationTriggerNotifier] triggers validation.
  ///
  /// This method listens for validation triggers specific to this field's step.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate(textValue);
    }
  }
}
