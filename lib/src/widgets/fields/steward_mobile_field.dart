import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/helpers.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

/// A widget that represents an international mobile number input field within a form managed by Form Steward.
///
/// The [StewardMobileField] uses [InternationalPhoneNumberInput] from the `intl_phone_number_input`
/// package to handle phone number inputs with automatic country code detection and validation.
///
/// The widget receives a [FieldModel] that defines the field's properties such as
/// label and validation rules. It also integrates with [FormStewardStateNotifier]
/// and [ValidationTriggerNotifier] to manage form state and trigger validation.
class StewardMobileField extends StatefulWidget {
  /// The model representing the field's properties and validation rules.
  final FieldModel field;

  /// The name of the step to which this field belongs.
  final String stepName;

  /// The [FormStewardStateNotifier] instance to manage the form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// The [ValidationTriggerNotifier] instance used to listen for validation triggers.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// Creates an instance of [StewardMobileField].
  ///
  /// This widget manages a form field, validates it based on the provided
  /// [FieldModel], and updates the form state using [FormStewardStateNotifier].
  StewardMobileField({
    super.key,
    required BaseFieldWidget fieldParams,
  })  : field = fieldParams.field,
        stepName = fieldParams.stepName,
        formStewardStateNotifier = fieldParams.formStewardStateNotifier,
        validationTriggerNotifier = fieldParams.validationTriggerNotifier;

  @override
  StewardMobileFieldState createState() => StewardMobileFieldState();
}

class StewardMobileFieldState extends State<StewardMobileField> {
  String? _errorMessage;
  String phoneValue = '';
  bool isPhoneNumberValid = true;
  PhoneNumber phoneNumber =
      PhoneNumber(isoCode: 'KE', dialCode: '+254'); // Default ISO code

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
          padding: appEqualPadding,
          decoration: BoxDecoration(
            border: Border.all(
                width: 1.0, color: borderColor(_errorMessage, context)),
            borderRadius: appBorderRadius,
          ),
          child: InternationalPhoneNumberInput(
            // Displays the label and error message for the mobile field.
            inputBorder: customeOutlineInputBorder(
              context,
              _errorMessage,
            ),
            inputDecoration: InputDecoration(
              border: InputBorder.none,
              labelText: widget.field.label,
              errorText: _errorMessage,
            ),
            // Automatically format the phone number as the user types.
            onInputChanged: (PhoneNumber number) {
              phoneNumber = number;
              phoneValue = number.phoneNumber ?? '';
              _updateFormState(); // Update form state on input change.
            },
            onInputValidated: (bool isValid) {
              // Handle validation errors.
              setState(() {
                if (!isValid && phoneValue.isNotEmpty) {
                  _errorMessage = 'Invalid ${widget.field.label}';
                } else {
                  _errorMessage = null;
                }
              });
              isPhoneNumberValid = isValid;
              _updateFormState(isValid: isValid);
            },
            keyboardType: TextInputType.phone,
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            ),
            initialValue: phoneNumber,
          ),
        ),
        displayErrorMessage(_errorMessage, context),
      ],
    );
  }

  /// Updates the form state using [FormStewardStateNotifier].
  ///
  /// The method updates the form state by passing the field name, the current
  /// value, and the validity status of the field to [FormStewardStateNotifier].
  void _updateFormState({bool isValid = true}) {
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName,
      fieldName: widget.field.name,
      value: phoneValue,
      isValid: isValid,
    );
  }

  /// Handles the validation trigger when [ValidationTriggerNotifier] triggers validation.
  ///
  /// This method listens for validation triggers specific to this field's step and
  /// validates the phone number when the trigger is activated.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validatePhoneNumber();
    }
  }

  /// Validates the phone number based on the field's required and pattern rules.
  ///
  /// Displays an error message if validation fails and updates the form state accordingly.
  void _validatePhoneNumber() {
    if (!isPhoneNumberValid) return;
    // Required field validation
    bool isValid = Validators.validateRequiredField(
      validationRequired: widget.field.validation?.required ?? false,
      fieldLabel: widget.field.label,
      fieldValue: phoneValue,
      setError: (errorMessage) {
        setState(() {
          _errorMessage = errorMessage;
        });
      },
    );

    if (!isValid) {
      _updateFormState(isValid: false);
      return;
    }

    // Clear error if validation passes.
    setState(() {
      _errorMessage = null;
    });
    _updateFormState(isValid: true);
  }
}
