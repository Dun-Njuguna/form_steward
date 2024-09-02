import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/option_model.dart';

class StewardCheckboxField extends StatefulWidget {
  final FieldModel field;

  const StewardCheckboxField({super.key, required this.field});

  @override
  StewardCheckboxFieldState createState() => StewardCheckboxFieldState();
}

class StewardCheckboxFieldState extends State<StewardCheckboxField> {
  final List<int> _selectedValues = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (widget.field.options ?? []).map<Widget>((OptionModel option) {
        return CheckboxListTile(
          title: Text(option.value),
          value: _selectedValues.contains(option.id),
          onChanged: (isChecked) {
            setState(() {
              if (isChecked == true) {
                _selectedValues.add(option.id);
              } else {
                _selectedValues.remove(option.id);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
