import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/option_model.dart';

/// A widget that represents a radio button group within a form managed by Form Steward.
///
/// The [StewardRadioField] widget displays a list of radio buttons where users
/// can select one option. It integrates with the Form Steward state management system
/// to manage field validation and state updates. The widget receives a [FieldModel] that
/// defines the field's properties, options, and validation rules.
///
/// The widget listens to validation triggers and updates the form state using
/// [FormStewardStateNotifier] and [ValidationTriggerNotifier].
class StewardRadioField extends StatefulWidget {
  /// The model representing the field's properties, options, and validation rules.
  final FieldModel field;

  /// The name of the step to which this field belongs.
  final String stepName;

  /// The [FormStewardStateNotifier] instance to manage the form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// The [ValidationTriggerNotifier] instance used to listen for validation triggers.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// Creates an instance of [StewardRadioField].
  ///
  /// This widget manages a group of radio buttons based on the provided [FieldModel].
  /// It updates the form state and performs validation according to the model's rules.
  const StewardRadioField({
    super.key,
    required this.field,
    required this.stepName,
    required this.formStewardStateNotifier,
    required this.validationTriggerNotifier,
  });

  @override
  StewardRadioFieldState createState() => StewardRadioFieldState();
}

class StewardRadioFieldState extends State<StewardRadioField> {
  /// Stores the currently selected value of the radio group.
  int? _selectedValue;

  /// Stores the error message to display when validation fails.
  String? _errorMessage;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the field's label as the title.
        Text(
          widget.field.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        // Display the radio buttons.
        ...?widget.field.options?.map<Widget>((OptionModel option) {
          return RadioListTile<int>(
            title: Text(option.value),
            value: option.id,
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
                _validate();
              });
            },
          );
        }),
        // Display the error message if validation fails.
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  /// Validates the radio button group based on the required validation rule.
  ///
  /// If the field is required but no option is selected, an error message is
  /// displayed, and the form state is updated as invalid. Otherwise, the error
  /// message is cleared, and the form state is updated as valid.
  void _validate() {
    bool isValid = Validators.validateRequiredField(
      validationRequired: widget.field.validation?.required ?? false,
      fieldLabel: widget.field.label,
      fieldValue: _selectedValue?.toString(),
      setError: (errorMessage) {
        setState(() {
          _errorMessage = "Selection is required";
        });
      },
    );

    if (!isValid) {
      updateState(false);
      return;
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
      value: _selectedValue,
      isValid: isValid,
    );
  }

  /// Handles the validation trigger when [ValidationTriggerNotifier] triggers validation.
  ///
  /// This method listens for validation triggers specific to this field's step
  /// and validates the field when the trigger occurs.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate();
    }
  }
}
