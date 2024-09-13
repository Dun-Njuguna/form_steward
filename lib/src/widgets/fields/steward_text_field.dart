import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

/// A widget that represents a text input field within a form managed by Form Steward.
///
/// The [StewardTextFieldWidget] supports both single-line and multi-line text inputs. It integrates
/// with the Form Steward state management system to handle field validation and state updates.
/// This widget listens for validation triggers and updates the form state accordingly.
///
/// The widget receives a [FieldModel] to define properties like label and validation rules, and
/// uses [FormStewardStateNotifier] and [ValidationTriggerNotifier] for state management and
/// validation.
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
  /// This widget manages a form field, validates it based on the provided [FieldModel],
  /// and updates the form state using [FormStewardStateNotifier].
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
      decoration: InputDecoration(
        labelText: widget.field.label,
        errorText: _errorMessage,
      ),
      keyboardType: _getKeyboardType(),
      maxLines: _getMaxLines(),
      minLines: _getKeyboardType() == TextInputType.multiline ? 3 : 1,
      onChanged: (value) {
        setState(() {
          textValue = value;
        });
      },
      onEditingComplete: () => _validate(),
    );
  }

  /// Determines the keyboard type based on the field type.
  TextInputType _getKeyboardType() {
    return widget.field.type == 'textarea'
        ? TextInputType.multiline
        : TextInputType.text;
  }

  /// Determines the maximum number of lines for the text field.
  int? _getMaxLines() {
    return widget.field.type == 'textarea' ? null : 1;
  }

  /// Validates the field based on its properties.
  ///
  /// Validations include checking for required fields, minimum and maximum length, and pattern matching.
  void _validate([String? value]) {
    bool isValid = _validateRequiredField();
    if (isValid) {
      isValid = _validateFieldLength();
    }

    // Update the form state based on validation results
    updateState(isValid);
  }

  /// Validates if the field is required and not empty.
  bool _validateRequiredField() {
    final isRequired = Validators.validateRequiredField(
      validationRequired: widget.field.validation?.required ?? false,
      fieldLabel: widget.field.label,
      fieldValue: textValue,
      setError: (errorMessage) {
        setState(() {
          _errorMessage = errorMessage;
        });
      },
    );
    if (isRequired) {
      setState(() {
        _errorMessage = '${widget.field.label} is required';
      });
    }
    return isRequired;
  }

  /// Validates the field length based on minimum and maximum length constraints.
  bool _validateFieldLength() {
    final minLength = widget.field.validation?.minLength;
    final maxLength = widget.field.validation?.maxLength;
    final length = textValue?.length ?? 0;

    if (minLength != null && length < minLength) {
      setState(() {
        _errorMessage = 'Minimum character length should be $minLength';
      });
      return false;
    }
    if (maxLength != null && length > maxLength) {
      setState(() {
        _errorMessage =
            'Exceeds allowed maximum character length of $maxLength';
      });
      return false;
    }
    setState(() {
      _errorMessage = null;
    });
    return true;
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
