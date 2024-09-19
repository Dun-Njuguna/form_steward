import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/file_result_model.dart';
import 'package:form_steward/src/utils/file_picker/steward_file_picker_helper.dart';

class StewardImagePickerField extends StatefulWidget {
  /// The [FieldModel] containing metadata about the field, such as:
  /// - [FieldModel.label]: The label for the field, displayed as a title.
  /// - [FieldModel.name]: The unique name of the field, used to identify it.
  /// - [FieldModel.validation]: Optional validation rules for the field, such as whether it is required.
  final FieldModel field;

  /// The name of the step to which this field belongs, used to group the fields and manage step-wise validation.
  /// This allows the form steward to trigger validation only for the fields in the current step.
  final String stepName;

  /// The [FormStewardStateNotifier] responsible for managing and updating the form's overall state.
  /// This includes keeping track of field values, validity, and other state information.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// The [ValidationTriggerNotifier] used to notify and trigger validation for the current field when needed.
  /// This enables deferred validation to occur at specific points, such as when navigating between steps.
  final ValidationTriggerNotifier validationTriggerNotifier;

  const StewardImagePickerField({
    super.key,
    required this.field,
    required this.stepName,
    required this.formStewardStateNotifier,
    required this.validationTriggerNotifier,
  });

  @override
  StewardImagePickerFieldState createState() => StewardImagePickerFieldState();
}

class StewardImagePickerFieldState extends State<StewardImagePickerField> {
  final FilePickerHelper filePickerHelper = FilePickerHelper();
  File? _pickedImage; // Holds the selected image file
  String? _errorMessage; // Stores the validation error message

  @override
  void initState() {
    super.initState();
    // Registers a listener to trigger validation when required
    widget.validationTriggerNotifier.addListener(_onValidationTrigger);
  }

  @override
  void dispose() {
    // Removes the listener when the widget is disposed of
    widget.validationTriggerNotifier.removeListener(_onValidationTrigger);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            await _pickImage(); // Picks or captures an image
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.field.label, // Displays the label for the field
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                height: 8.0,
              ),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 60.0, // Ensures a minimum height for the field container
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Border styling
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (_pickedImage != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              _pickedImage!, // Displays the selected image
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(
                          width: _pickedImage == null ? 8.0 : 15.0,
                        ),
                        Text(
                          _pickedImage == null
                              ? "Click to capture image" // Instruction when no image is selected
                              : "Tap to replace", // Instruction when an image is already selected
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.camera_alt_outlined, // Camera icon for picking or capturing an image
                      size: 32,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!, // Displays the error message, if any
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  /// Method to pick an image, either from the gallery or by capturing it using the camera.
  /// It updates the form's state with the picked image and triggers validation if needed.
  Future<void> _pickImage() async {
    StewardFilePickerResult pickedImage;

    // Determines whether to capture an image or pick from the gallery based on the field's configuration
    if (widget.field.source == 'capture') {
      pickedImage = await filePickerHelper.pickOrCaptureImage(capture: true);
    } else {
      pickedImage = await filePickerHelper.pickOrCaptureImage();
    }

    // If an image was picked or captured, update the state and form
    if (pickedImage.file != null) {
      setState(() {
        _pickedImage = File(pickedImage.file!.path); // Converts the file path to a File object
        _errorMessage = null; // Clears any previous error message
      });
    }

    _validate(); // Triggers validation after picking an image
  }

  /// Method to validate the image field based on its required status.
  /// If the field is marked as required and no image is selected, an error message is displayed.
  void _validate() {
    if (widget.field.validation?.required == true && _pickedImage == null) {
      setState(() {
        _errorMessage = '${widget.field.label} is required.'; // Shows the required field error message
      });
    } else {
      updateState(true); // Marks the field as valid
      setState(() {
        _errorMessage = null; // Clears the error message if validation passes
      });
    }
  }

  /// Updates the form state using the [FormStewardStateNotifier].
  /// This method updates the form field's value (the file path of the image) and its validity status.
  void updateState(bool isValid) {
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName, // The current step to which this field belongs
      fieldName: widget.field.name, // The name of the field being updated
      value: _pickedImage?.path, // The file path of the selected image
      isValid: isValid, // Whether the field is valid or not
    );
  }

  /// Listens for a validation trigger from the [ValidationTriggerNotifier].
  /// When the trigger is detected, the field is validated.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate(); // Validates the field when triggered
    }
  }
}