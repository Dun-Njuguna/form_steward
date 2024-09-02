import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

class StewardTextFieldWidget extends StatelessWidget {
  final FieldModel field;

  const StewardTextFieldWidget({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: field.label),
      validator: (value) {
        if (field.validation?.required == true && value!.isEmpty) {
          return '${field.label} is required';
        }
        if (field.validation?.minLength != null &&
            value!.length < field.validation!.minLength!) {
          return '${field.label} must be at least ${field.validation!.minLength} characters';
        }
        return null;
      },
    );
  }
}
