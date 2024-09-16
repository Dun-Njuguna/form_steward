import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/option_model.dart';

/// A widget that represents a dropdown select field within a form managed by Form Steward.
///
/// The [StewardSelectField] allows users to select a value from a dropdown list of options.
/// It integrates with the Form Steward state management system for handling validation
/// and state updates.
///
/// ## Parameters:
///
/// - [field]: The [FieldModel] that defines the properties and validation rules for this dropdown field.
/// - [stepName]: The name of the form step this field belongs to.
/// - [validationTriggerNotifier]: The notifier that triggers validation when required.
/// - [formStewardStateNotifier]: The notifier that manages the form state.
/// - [fetchOptions]: A function that asynchronously fetches the list of options for the dropdown.
///
/// The widget supports both pre-provided options or options fetched asynchronously. It listens
/// for changes to update the form state and trigger validation.
class StewardSelectField extends StatefulWidget {
  /// The model representing the field's properties and validation rules.
  final FieldModel field;

  /// The name of the step to which this field belongs.
  final String stepName;

  /// The [ValidationTriggerNotifier] instance used to listen for validation triggers.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// The [FormStewardStateNotifier] instance to manage the form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// A function that fetches options asynchronously for the dropdown.
  final Future<List<OptionModel>> Function()? fetchOptions;

  /// Creates an instance of [StewardSelectField].
  ///
  /// The widget renders a dropdown select field based on the options provided
  /// or fetched asynchronously.
  const StewardSelectField({
    super.key,
    required this.field,
    required this.stepName,
    required this.validationTriggerNotifier,
    required this.formStewardStateNotifier,
    this.fetchOptions,
  });

  @override
  StewardSelectFieldState createState() => StewardSelectFieldState();
}

class StewardSelectFieldState extends State<StewardSelectField> {
  /// Stores the currently selected value from the dropdown.
  dynamic _selectedValue;

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
    return FutureBuilder<List<OptionModel>>(
      future: widget.fetchOptions?.call() ?? Future.value(widget.field.options),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text('Error fetching options');
        }
        final options = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            DropdownButtonFormField<int>(
              value: _selectedValue,
              decoration: InputDecoration(labelText: widget.field.label),
              items: options.map((OptionModel option) {
                return DropdownMenuItem<int>(
                  value: option.id,
                  child: Text(option.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedValue = value;
                  // Trigger validation and update the form state.
                  _validate();
                  _updateFormState();
                });
              },
            ),
          ],
        );
      },
    );
  }

  /// Validates the select field based on the required validation rule.
  ///
  /// If the field is required but no value is selected, an error message is displayed.
  /// Otherwise, the error message is cleared. The method triggers a UI update by calling [setState].
  void _validate() {
    if (widget.field.validation?.required == true && _selectedValue == null) {
      setState(() {
        _errorMessage = '${widget.field.label} is required';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  /// Updates the form state using [FormStewardStateNotifier].
  ///
  /// The method updates the form state by passing the field name, the current value,
  /// and the validity status of the field to [FormStewardStateNotifier].
  void _updateFormState() {
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName,
      fieldName: widget.field.name,
      value: _selectedValue,
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
