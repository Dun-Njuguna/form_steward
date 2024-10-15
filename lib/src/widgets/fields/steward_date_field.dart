import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/breakpoints.dart';
import 'package:form_steward/src/utils/helpers.dart';

/// A widget that represents a date input field within a form managed by Form Steward.
///
/// The [StewardDateField] widget allows users to select a date or year. It integrates with
/// the Form Steward state management system to handle validation and state updates. The widget
/// listens for validation triggers and updates the form state accordingly.
///
/// ## Parameters:
///
/// - [field]: The [FieldModel] that defines the properties and validation rules for this field.
/// - [stepName]: The name of the step that this field belongs to.
/// - [formStewardStateNotifier]: The instance of [FormStewardStateNotifier] that manages the form state.
/// - [validationTriggerNotifier]: The instance of [ValidationTriggerNotifier] that listens for validation triggers.
///
/// The widget supports selecting either a specific date or just a year depending on the validation
/// properties in [field].
class StewardDateField extends StatefulWidget {
  /// The model representing the field's properties and validation rules.
  final FieldModel field;

  /// The name of the step to which this field belongs.
  final String stepName;

  /// The [FormStewardStateNotifier] instance to manage the form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// The [ValidationTriggerNotifier] instance used to listen for validation triggers.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// Creates an instance of [StewardDateField].
  ///
  /// This widget allows for selecting a date or a year and integrates with the form
  /// management system to handle validation and state updates.
  StewardDateField({
    super.key,
    required BaseFieldWidget fieldParams,
  })  : field = fieldParams.field,
        stepName = fieldParams.stepName,
        formStewardStateNotifier = fieldParams.formStewardStateNotifier,
        validationTriggerNotifier = fieldParams.validationTriggerNotifier;

  @override
  StewardDateFieldState createState() => StewardDateFieldState();
}

class StewardDateFieldState extends State<StewardDateField> {
  /// Stores the currently selected date in string format.
  String? _selectedDate;

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
    return TextFormField(
      decoration: customInputDecoration(
        context,
        labelText: widget.field.label,
        errorText: _errorMessage,
      ),
      keyboardType: TextInputType.datetime,
      onTap: () async {
        if (widget.field.validation?.yearOnly ?? false) {
          _pickYear(context);
        } else {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime(2050),
            initialDatePickerMode: DatePickerMode.day,
          );
          if (date != null) {
            setState(() {
              _selectedDate = date.toLocal().toString().split(' ')[0];
              // Trigger validation on date selection.
              _validate(_selectedDate);
            });
          }
        }
      },
      validator: (value) {
        if (widget.field.validation?.required == true && value!.isEmpty) {
          return '${widget.field.label} is required';
        }
        return null;
      },
      readOnly: true,
      controller: TextEditingController(text: _selectedDate),
    );
  }

  /// Opens a dialog to allow the user to pick a year.
  ///
  /// This method shows an [AlertDialog] with a grid of years for selection. Upon selecting
  /// a year, it updates the `_selectedDate` and triggers validation.
  void _pickYear(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = theme.primaryColor;
    final int currentYear = DateTime.now().year;

    showDialog(
      context: context,
      builder: (context) {
        final Size size = MediaQuery.of(context).size;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Year', style: TextStyle(color: buttonColor)),
              contentPadding: const EdgeInsets.all(10),
              content: SizedBox(
                height: size.height / 3,
                width:
                    size.width > Breakpoints.sm ? size.width / 3 : size.width,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: GridView.count(
                    crossAxisCount: size.width > Breakpoints.sm
                        ? size.width > Breakpoints.lg
                            ? 5
                            : 4
                        : 3,
                    children: [
                      ...List.generate(
                        130,
                        (index) {
                          final year = currentYear - index;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDate = year.toString();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _selectedDate?.startsWith('$year') == true
                                          ? buttonColor
                                          : Colors.grey,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  year.toString(),
                                  style: TextStyle(
                                    color: _selectedDate?.startsWith('$year') ==
                                            true
                                        ? buttonColor
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: buttonColor)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Trigger validation on year selection.
                    _validate(_selectedDate);
                  },
                  child: Text('Okay', style: TextStyle(color: buttonColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Validates the date field based on the required validation rule.
  ///
  /// If the field is required but no date or year is selected, an error message is
  /// displayed and the form state is updated as invalid. Otherwise, the error
  /// message is cleared, and the form state is updated as valid.
  ///
  /// - [value]: The selected date or year, used for validation.
  void _validate([String? value]) {
    bool isValid = Validators.validateRequiredField(
      validationRequired: widget.field.validation?.required ?? false,
      fieldLabel: widget.field.label,
      fieldValue: _selectedDate,
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

    // Clear error if validation passes
    setState(() {
      _errorMessage = null;
    });
    updateState(true);
  }

  /// Updates the form state using [FormStewardStateNotifier].
  ///
  /// This method updates the form state by passing the field name, current value,
  /// and the validity status of the field to the [FormStewardStateNotifier].
  ///
  /// - [isValid]: The validation status of the current field.
  void updateState(bool isValid) {
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName,
      fieldName: widget.field.name,
      value: _selectedDate,
      isValid: isValid,
    );
  }

  /// Handles validation when triggered by the [ValidationTriggerNotifier].
  ///
  /// This method listens for validation triggers specific to this field's step and
  /// performs validation when the trigger occurs.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate(_selectedDate);
    }
  }
}
