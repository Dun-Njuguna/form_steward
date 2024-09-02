import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/file_result_model.dart';
import 'package:form_steward/src/utils/file_picker/steward_file_picker_helper.dart';

class StewardFilePickerField extends StatefulWidget {
  final FieldModel field;

  const StewardFilePickerField({super.key, required this.field});

  @override
  StewardFilePickerFieldState createState() => StewardFilePickerFieldState();
}

class StewardFilePickerFieldState extends State<StewardFilePickerField> {
  StewardFilePickerResult? _pickedFile;
  final FilePickerHelper _filePickerHelper = FilePickerHelper();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final pickedFile = await _filePickerHelper.pickFile();
        setState(() {
          _pickedFile = pickedFile;
        });
      },
      child: Text(widget.field.label),
    );
  }
}
