import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

/// A widget that represents a text field within a form managed by Form Steward.
///
/// The [StewardTextFieldWidget] is a customizable text field that works with
/// the Form Steward state management system to manage field validation and
/// state updates. This widget listens for validation triggers and updates the
/// form state accordingly.
///
/// The widget receives a [FieldModel] that defines the field's properties such as
/// label and validation rules. It also receives references to [FormStewardStateNotifier]
/// to update the form state and [ValidationTriggerNotifier] to trigger field validation.
class StewardTextFieldWidget extends StatefulWidget {
  /// The model representing the field's properties and validation rules.
  final FieldModel field;

  /// The name of the step to which this field belongs.
  final String stepName;

  /// The [FormStewardStateNotifier] instance to manage the form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// The [ValidationTriggerNotifier] instance used to listen for validation triggers.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// Creates an instance of [StewardTextFieldWidget].
  ///
  /// This widget manages a form field, validates it based on the provided
  /// [FieldModel], and updates the form state using [FormStewardStateNotifier].
  const StewardTextFieldWidget({
    super.key,
    required this.field,
    required this.stepName,
    required this.formStewardStateNotifier,
    required this.validationTriggerNotifier,
  });

  @override
  State<StewardTextFieldWidget> createState() => _StewardTextFieldWidgetState();
}

class _StewardTextFieldWidgetState extends State<StewardTextFieldWidget> {
  /// Stores the error message to display when validation fails.
  String? _errorMessage;

  /// Stores the current value of the text field.
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
      // Displays the label and error message for the text field.
      decoration: InputDecoration(
        labelText: widget.field.label,
        errorText: _errorMessage,
      ),
      onChanged: (value) {
        // Update the value of the text field when the user changes the input.
        textValue = value;
      },
    );
  }

  /// Validates the field based on the required validation rule.
  ///
  /// If the field is required but no value is provided, an error message is
  /// displayed, and the form state is updated as invalid. Otherwise, the error
  /// message is cleared, and the form state is updated as valid.
  void _validate([String? value]) {
    if (widget.field.validation?.required == true &&
        (textValue == null || textValue?.isEmpty == true)) {
      setState(() {
        _errorMessage = '${widget.field.label} is required';
      });
      updateState(false);
    } else {
      setState(() {
        _errorMessage = null;
      });
      updateState(true);
    }
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
  /// This method listens for validation triggers specific to this field's step.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate(textValue);
    }
  }
}
