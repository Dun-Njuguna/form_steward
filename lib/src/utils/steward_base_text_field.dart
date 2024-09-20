import 'package:flutter/material.dart';
import 'package:form_steward/src/utils/helpers.dart';

class StewardBaseTextField extends StatelessWidget {
  final String label;
  final TextInputType keyboardType;
  final String? errorMessage;
  final void Function(String) onChanged;
  final VoidCallback onEditingComplete;

  const StewardBaseTextField({
    super.key,
    required this.label,
    required this.keyboardType,
    required this.onChanged,
    required this.onEditingComplete,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: customInputDecoration(
        context,
        labelText: label,
        errorText: errorMessage,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
    );
  }
}
