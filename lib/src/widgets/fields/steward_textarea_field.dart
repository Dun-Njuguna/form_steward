import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

class StewardTextareaField extends StatelessWidget {
  final FieldModel field;

  const StewardTextareaField({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: field.label),
      maxLines: 5,
      validator: (value) {
        if (field.validation?.required == true && value!.isEmpty) {
          return '${field.label} is required';
        }
        if (field.validation?.maxLength != null &&
            value!.length > field.validation!.maxLength!) {
          return '${field.label} cannot exceed ${field.validation!.maxLength} characters';
        }
        return null;
      },
    );
  }
}
