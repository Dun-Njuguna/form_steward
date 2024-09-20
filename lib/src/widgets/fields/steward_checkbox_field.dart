import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/option_model.dart';
import 'package:form_steward/src/utils/helpers.dart';

/// A widget that represents a checkbox field within a form managed by Form Steward.
///
/// The [StewardCheckboxField] allows users to select multiple options from a list of checkboxes.
/// It integrates with the Form Steward state management system for handling validation and state updates.
///
/// ## Parameters:
///
/// - [field]: The [FieldModel] that defines the properties and validation rules for this checkbox field.
/// - [stepName]: The name of the form step this field belongs to.
/// - [validationTriggerNotifier]: The notifier that triggers validation when required.
/// - [formStewardStateNotifier]: The notifier that manages the form state.
///
/// The widget supports custom options and listens for changes to update the form state and trigger validation.
class StewardCheckboxField extends StatefulWidget {
  /// The model representing the field's properties and validation rules.
  final FieldModel field;

  /// The name of the step to which this field belongs.
  final String stepName;

  /// The [ValidationTriggerNotifier] instance used to listen for validation triggers.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// The [FormStewardStateNotifier] instance to manage the form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// Creates an instance of [StewardCheckboxField].
  ///
  /// The widget renders multiple checkbox options based on the [field.options] provided.
  StewardCheckboxField({
    super.key,
    required BaseFieldWidget fieldParams,
  })  : field = fieldParams.field,
        stepName = fieldParams.stepName,
        formStewardStateNotifier = fieldParams.formStewardStateNotifier,
        validationTriggerNotifier = fieldParams.validationTriggerNotifier;

  @override
  StewardCheckboxFieldState createState() => StewardCheckboxFieldState();
}

class StewardCheckboxFieldState extends State<StewardCheckboxField> {
  /// Stores the selected option IDs as integers.
  final List<int> _selectedValues = [];

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
        Container(
          decoration: customeBoxDecoration(_errorMessage, context),
          padding: appEqualPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0),
                child: Text(
                  widget.field.label,
                  style: TextStyle(
                      color: _errorMessage != null
                          ? Theme.of(context).colorScheme.error
                          : null),
                ),
              ),
              ..._buildCheckboxes(),
            ],
          ),
        ),
        // Display the error message if validation fails.
        displayErrorMessage(_errorMessage, context),
      ],
    );
  }

  /// Builds the list of checkboxes based on the options provided in the [FieldModel].
  ///
  /// Each option is rendered as a [CheckboxListTile]. The user can select or deselect
  /// the options, and the state is updated accordingly.
  List<Widget> _buildCheckboxes() {
    return (widget.field.options ?? []).map<Widget>((OptionModel option) {
      return CheckboxListTile(
        title: Text(
          option.value,
          style: TextStyle(
              color: _errorMessage != null
                  ? Theme.of(context).colorScheme.error
                  : null),
        ),
        value: _selectedValues.contains(option.id),
        onChanged: (isChecked) {
          setState(() {
            if (isChecked == true) {
              _selectedValues.add(option.id);
            } else {
              _selectedValues.remove(option.id);
            }
            // Trigger validation whenever an option is selected or deselected.
            _validate();
            // Update the form state after selection.
            _updateFormState();
          });
        },
      );
    }).toList();
  }

  /// Validates the checkbox field based on the required validation rule.
  ///
  /// If the field is required but no option is selected, an error message is displayed.
  /// Otherwise, the error message is cleared. The method triggers a UI update by calling [setState].
  void _validate() {
    if (widget.field.validation?.required == true && _selectedValues.isEmpty) {
      setState(() {
        _errorMessage = 'Selection required';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  /// Updates the form state using [FormStewardStateNotifier].
  ///
  /// The method updates the form state by passing the field name, the current
  /// value (selected options), and the validity status of the field to [FormStewardStateNotifier].
  void _updateFormState() {
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName,
      fieldName: widget.field.name,
      value: _selectedValues,
      isValid: _errorMessage == null,
    );
  }

  /// Handles the validation trigger when [ValidationTriggerNotifier] triggers validation.
  ///
  /// This method listens for validation triggers specific to this field's step
  /// and validates the field when the trigger occurs.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate();
      _updateFormState();
    }
  }
}
