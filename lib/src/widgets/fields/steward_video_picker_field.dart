import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/file_picker/steward_file_picker_helper.dart';

class StewardVideoPickerField extends StatefulWidget {
  final FieldModel field;

  const StewardVideoPickerField({
    super.key,
    required this.field,
  });

  @override
  StewardVideoPickerFieldState createState() => StewardVideoPickerFieldState();
}

class StewardVideoPickerFieldState extends State<StewardVideoPickerField> {
  final FilePickerHelper filePickerHelper = FilePickerHelper();
  dynamic _pickedVideo;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        var pickedVideo;
        if (widget.field.source == 'capture') {
          // Record a new video using the camera
          pickedVideo =
              await filePickerHelper.pickOrCaptureVideo(capture: true);
        } else {
          // Pick a video from the gallery
          pickedVideo = await filePickerHelper.pickOrCaptureVideo();
        }

        if (pickedVideo != null) {
          setState(() {
            _pickedVideo = pickedVideo;
          });
        }
      },
      child: Text(widget.field.label),
    );
  }
}
