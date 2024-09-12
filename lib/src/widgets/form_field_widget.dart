import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/widgets/fields/steward_audio_recorder_field.dart';
import 'package:form_steward/src/widgets/fields/steward_email_field.dart';
import 'package:form_steward/src/widgets/fields/steward_file_picker_field.dart';
import 'package:form_steward/src/widgets/fields/steward_mobile_field.dart';
import 'package:form_steward/src/widgets/fields/steward_number_field.dart';
import 'package:form_steward/src/widgets/fields/steward_text_field.dart';
import 'package:form_steward/src/widgets/fields/steward_textarea_field.dart';
import 'package:form_steward/src/widgets/fields/steward_select_field.dart';
import 'package:form_steward/src/widgets/fields/steward_checkbox_field.dart';
import 'package:form_steward/src/widgets/fields/steward_radio_field.dart';
import 'package:form_steward/src/widgets/fields/steward_date_field.dart';
import 'package:form_steward/src/widgets/fields/steward_image_picker_field.dart';
import 'package:form_steward/src/widgets/fields/steward_video_picker_field.dart';

class FormFieldWidget extends StatefulWidget {
  final FieldModel field;
  final String stepName;
  final ValidationTriggerNotifier validationTriggerNotifier;
  final FormStewardStateNotifier formStewardStateNotifier;

  const FormFieldWidget({
    super.key,
    required this.field,
    required this.stepName,
    required this.validationTriggerNotifier,
    required this.formStewardStateNotifier,
  });

  @override
  FormFieldWidgetState createState() => FormFieldWidgetState();
}

class FormFieldWidgetState extends State<FormFieldWidget> {
  dynamic _selectedValue;

  @override
  Widget build(BuildContext context) {
    switch (widget.field.type) {
      case 'text':
        return StewardTextFieldWidget(
          stepName: widget.stepName,
          field: widget.field,
          validationTriggerNotifier: widget.validationTriggerNotifier,
          formStewardStateNotifier: widget.formStewardStateNotifier,
        );
      case 'number':
        return StewardNumberField(
          field: widget.field,
        );
      case 'email':
        return StewardEmailField(
          field: widget.field,
        );
      case 'tel':
        return StewardMobileField(
          field: widget.field,
        );
      case 'textarea':
        return StewardTextareaField(
          field: widget.field,
        );
      case 'select':
        return StewardSelectField(
          field: widget.field,
        );
      case 'checkbox':
        return StewardCheckboxField(
          field: widget.field,
        );
      case 'radio':
        return StewardRadioField(
          field: widget.field,
        );
      case 'date':
        return StewardDateField(
          field: widget.field,
        );
      case 'file':
        return StewardFilePickerField(
          field: widget.field,
        );
      case 'image':
        return StewardImagePickerField(
          field: widget.field,
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
        return StewardVideoPickerField(
          field: widget.field,
        );
      default:
        return const SizedBox
            .shrink(); // Default case if no matching field type
    }
  }
}
