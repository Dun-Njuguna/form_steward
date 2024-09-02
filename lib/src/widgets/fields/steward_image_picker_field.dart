import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/file_picker/steward_file_picker_helper.dart';

class StewardImagePickerField extends StatefulWidget {
  final FieldModel field;

  const StewardImagePickerField({
    super.key,
    required this.field,
  });

  @override
  StewardImagePickerFieldState createState() => StewardImagePickerFieldState();
}

class StewardImagePickerFieldState extends State<StewardImagePickerField> {
  final FilePickerHelper filePickerHelper = FilePickerHelper();
  dynamic _pickedImage;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        var pickedImage;
        if (widget.field.source == 'capture') {
          pickedImage =
              await filePickerHelper.pickOrCaptureImage(capture: true);
        } else {
          pickedImage = await filePickerHelper.pickOrCaptureImage();
        }

        if (pickedImage != null) {
          setState(() {
            _pickedImage = pickedImage;
          });
        }
      },
      child: Text(widget.field.label),
    );
  }
}
