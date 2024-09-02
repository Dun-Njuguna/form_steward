import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

class StewardDateField extends StatefulWidget {
  final FieldModel field;

  const StewardDateField({super.key, required this.field});

  @override
  StewardDateFieldState createState() => StewardDateFieldState();
}

class StewardDateFieldState extends State<StewardDateField> {
  String? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: widget.field.label),
      keyboardType: TextInputType.datetime,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date.toLocal().toString().split(' ')[0];
          });
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
}
