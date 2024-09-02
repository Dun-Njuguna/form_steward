import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/option_model.dart';


class StewardSelectField extends StatefulWidget {
  final FieldModel field;
  final Future<List<OptionModel>> Function()? fetchOptions;

  const StewardSelectField({super.key, required this.field, this.fetchOptions});

  @override
  StewardSelectFieldState createState() => StewardSelectFieldState();
}

class StewardSelectFieldState extends State<StewardSelectField> {
  dynamic _selectedValue;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OptionModel>>(
      future: widget.fetchOptions?.call() ?? Future.value(widget.field.options),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text('Error fetching options');
        }
        final options = snapshot.data ?? [];
        return DropdownButtonFormField<int>(
          value: _selectedValue,
          decoration: InputDecoration(labelText: widget.field.label),
          items: options.map((OptionModel option) {
            return DropdownMenuItem<int>(
              value: option.id,
              child: Text(option.value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedValue = value;
            });
          },
          validator: (value) {
            if (widget.field.validation?.required == true && value == null) {
              return '${widget.field.label} is required';
            }
            return null;
          },
        );
      },
    );
  }
}
