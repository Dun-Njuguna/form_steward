import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

class StewardNumberField extends StatelessWidget {
  final FieldModel field;

  const StewardNumberField({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: field.label),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (field.validation?.required == true && value!.isEmpty) {
          return '${field.label} is required';
        }
        return null;
      },
    );
  }
}
