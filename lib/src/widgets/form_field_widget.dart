import 'package:flutter/material.dart';
import 'package:form_steward/src/utils/file_picker_result.dart';
import 'package:form_steward/src/utils/steward_file_picker_helper.dart';
import 'package:form_steward/src/widgets/audio_recorder_widget.dart';
import '../models/field_model.dart';
import '../models/option_model.dart';
import 'package:http/http.dart' as http;

class FormFieldWidget extends StatefulWidget {
  final FieldModel field;

  const FormFieldWidget({
    super.key,
    required this.field,
  });

  @override
  FormFieldWidgetState createState() => FormFieldWidgetState();
}

class FormFieldWidgetState extends State<FormFieldWidget> {
  dynamic _selectedValue;
  StewardFilePickerResult? _pickedFile;
  StewardFilePickerResult? _pickedImage;
  StewardFilePickerResult? _pickedAudio;
  StewardFilePickerResult? _pickedVideo;

  final FilePickerHelper _filePickerHelper = FilePickerHelper();

  @override
  Widget build(BuildContext context) {
    switch (widget.field.type) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(labelText: widget.field.label),
          validator: (value) {
            if (widget.field.validation?.required == true && value!.isEmpty) {
              return '${widget.field.label} is required';
            }
            if (widget.field.validation?.minLength != null &&
                value!.length < widget.field.validation!.minLength!) {
              return '${widget.field.label} must be at least ${widget.field.validation!.minLength} characters';
            }
            return null;
          },
        );
      case 'number':
        return TextFormField(
          decoration: InputDecoration(labelText: widget.field.label),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (widget.field.validation?.required == true && value!.isEmpty) {
              return '${widget.field.label} is required';
            }
            return null;
          },
        );
      case 'email':
        return TextFormField(
          decoration: InputDecoration(labelText: widget.field.label),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (widget.field.validation?.required == true && value!.isEmpty) {
              return '${widget.field.label} is required';
            }
            if (widget.field.validation?.pattern != null &&
                !RegExp(widget.field.validation!.pattern!).hasMatch(value!)) {
              return 'Invalid ${widget.field.label}';
            }
            return null;
          },
        );

      case 'tel':
        return TextFormField(
          decoration: InputDecoration(labelText: widget.field.label),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (widget.field.validation?.required == true && value!.isEmpty) {
              return '${widget.field.label} is required';
            }
            if (widget.field.validation?.pattern != null &&
                !RegExp(widget.field.validation!.pattern!).hasMatch(value!)) {
              return 'Invalid ${widget.field.label}';
            }
            return null;
          },
        );

      case 'textarea':
        return TextFormField(
          decoration: InputDecoration(labelText: widget.field.label),
          maxLines: 5,
          validator: (value) {
            if (widget.field.validation?.required == true && value!.isEmpty) {
              return '${widget.field.label} is required';
            }
            if (widget.field.validation?.maxLength != null &&
                value!.length > widget.field.validation!.maxLength!) {
              return '${widget.field.label} cannot exceed ${widget.field.validation!.maxLength} characters';
            }
            return null;
          },
        );
      case 'select':
        return FutureBuilder<List<OptionModel>>(
          future:
              _fetchOptions(), // Changed the return type to List<OptionModel>
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error fetching options');
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
                if (widget.field.validation?.required == true &&
                    value == null) {
                  return '${widget.field.label} is required';
                }
                return null;
              },
            );
          },
        );
      case 'checkbox':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              (widget.field.options ?? []).map<Widget>((OptionModel option) {
            return CheckboxListTile(
              title: Text(option.value),
              value: _selectedValue?.contains(option.id) ?? false,
              onChanged: (isChecked) {
                setState(() {
                  if (isChecked == true) {
                    _selectedValue = (_selectedValue ?? <int>[]).toList()
                      ..add(option.id);
                  } else {
                    _selectedValue = (_selectedValue ?? <int>[]).toList()
                      ..remove(option.id);
                  }
                });
              },
            );
          }).toList(),
        );
      case 'radio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              (widget.field.options ?? []).map<Widget>((OptionModel option) {
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
      case 'date':
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
                _selectedValue = date.toLocal().toString().split(' ')[0];
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
          controller: TextEditingController(text: _selectedValue),
        );

      case 'file':
        return ElevatedButton(
          onPressed: () async {
            final pickedFile = await _filePickerHelper.pickFile();
            if (pickedFile != null) {
              setState(() {
                _pickedFile = pickedFile;
              });
            }
          },
          child: Text(widget.field.label),
        );

      case 'image':
        return ElevatedButton(
          onPressed: () async {
            StewardFilePickerResult? pickedImage;
            if (widget.field.source == 'capture') {
              // Capture a new image using the camera
              pickedImage =
                  await _filePickerHelper.pickOrCaptureImage(capture: true);
            } else {
              // Pick an image from the gallery
              pickedImage = await _filePickerHelper.pickOrCaptureImage();
            }

            if (pickedImage != null) {
              setState(() {
                _pickedImage = pickedImage;
              });
            }
          },
          child: Text(widget.field.label),
        );
      case 'audio':
        return AudioRecorderWidget(
          onAudioSaved: (String? savedFilePath) {
            if (savedFilePath != null) {
              // Handle the saved file path if needed
              print("Audio file saved at: $savedFilePath");
              setState(() {});
            }
          },
        );

      case 'video':
        return ElevatedButton(
          onPressed: () async {
            StewardFilePickerResult? pickedVideo;
            if (widget.field.source == 'capture') {
              // Record a new video using the camera
              pickedVideo =
                  await _filePickerHelper.pickOrCaptureVideo(capture: true);
            } else {
              // Pick a video file from the gallery
              pickedVideo = await _filePickerHelper.pickOrCaptureVideo();
            }

            setState(() {
              _pickedVideo = pickedVideo;
            });
          },
          child: Text(widget.field.label),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<List<OptionModel>> _fetchOptions() async {
    // Fetch options from a URL or other source based on the field's configuration
    if (widget.field.fetchOptionsUrl != null) {
      var uri = Uri.parse(widget.field.fetchOptionsUrl!);
      final response = await http.get(uri); // Replace with actual fetch logic
      // Assuming response is a list of maps, each representing an option.
      return (response as List)
          .map((optionJson) => OptionModel.fromMap(optionJson))
          .toList();
    }
    return widget.field.options ?? [];
  }
}
