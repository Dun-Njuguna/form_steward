import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

class StewardTextFieldWidget extends StatefulWidget {
  final FieldModel field;
  final String stepName;
  final FormStewardStateNotifier formStewardStateNotifier;
  final ValidationTriggerNotifier validationTriggerNotifier;

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
  String? _errorMessage;
  String? textValue;

  @override
  void initState() {
    super.initState();
    widget.validationTriggerNotifier.addListener(_onValidationTrigger);
  }

  @override
  void dispose() {
    widget.validationTriggerNotifier.removeListener(_onValidationTrigger);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Value of the TextFormField
      decoration: InputDecoration(
        labelText: widget.field.label,
        errorText: _errorMessage,
      ),
      onChanged: (value) {
        textValue = value;
      },
    );
  }

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

  void updateState(bool isValid) {
    widget.formStewardStateNotifier.updateField(
        stepName: widget.stepName,
        fieldName: widget.field.name,
        value: textValue,
        isValid: isValid);
  }

  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate(textValue);
    }
  }
}
