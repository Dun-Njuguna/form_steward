import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/option_model.dart';

class StewardRadioField extends StatefulWidget {
  final FieldModel field;

  const StewardRadioField({super.key, required this.field});

  @override
  StewardRadioFieldState createState() => StewardRadioFieldState();
}

class StewardRadioFieldState extends State<StewardRadioField> {
  int? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (widget.field.options ?? []).map<Widget>((OptionModel option) {
        return RadioListTile<int>(
          title: Text(option.value),
          value: option.id,
          groupValue: _selectedValue,
          onChanged: (value) {
            setState(() {
              _selectedValue = value;
            });
          },
        );
      }).toList(),
    );
  }
}
