import 'dart:io';
import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/file_result_model.dart';
import 'package:form_steward/src/utils/file_picker/steward_file_picker_helper.dart';
import 'package:form_steward/src/utils/helpers.dart';

/// A custom widget for picking files in a form. This widget is part of the
/// form system managed by FormSteward. It includes validation logic and
/// updates the form state when a file is selected.
///
/// The [StewardFilePickerField] works in conjunction with a field model and
/// notifiers for state management and validation triggers.
class StewardFilePickerField extends StatefulWidget {
  /// The field model containing metadata such as label, name, and validation rules.
  final FieldModel field;

  /// The name of the step that the field belongs to. Used for step-wise validation.
  final String stepName;

  /// A notifier responsible for managing the state of the form, including field values.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// A notifier responsible for triggering validation for the current field.
  final ValidationTriggerNotifier validationTriggerNotifier;

  StewardFilePickerField({
    super.key,
    required BaseFieldWidget fieldParams,
  })  : field = fieldParams.field,
        stepName = fieldParams.stepName,
        formStewardStateNotifier = fieldParams.formStewardStateNotifier,
        validationTriggerNotifier = fieldParams.validationTriggerNotifier;

  @override
  StewardFilePickerFieldState createState() => StewardFilePickerFieldState();
}

/// State class for [StewardFilePickerField].
///
/// This class handles the internal state of the file picker widget,
/// including managing the selected file, validation, and UI rendering.
class StewardFilePickerFieldState extends State<StewardFilePickerField> {
  /// The file selected by the user, wrapped in a [StewardFilePickerResult] object.
  StewardFilePickerResult? _pickedFile;

  /// Holds the error message for display if validation fails.
  String? _errorMessage;

  /// Utility helper to handle the file picking logic.
  final FilePickerHelper _filePickerHelper = FilePickerHelper();

  @override
  void initState() {
    super.initState();
    // Registers a listener to trigger validation when required.
    widget.validationTriggerNotifier.addListener(_onValidationTrigger);
  }

  @override
  void dispose() {
    // Removes the listener when the widget is disposed of.
    widget.validationTriggerNotifier.removeListener(_onValidationTrigger);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the label of the field.
        Text(
          widget.field.label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),

        // GestureDetector to handle file selection.
        GestureDetector(
          onTap: () async {
            // Opens file picker dialog and assigns the result to _pickedFile.
            final pickedFile = await _filePickerHelper.pickFile();
            if (pickedFile.file == null)
              return; // If no file is selected, return early.
            setState(() {
              _pickedFile = pickedFile;
            });
            _validate(); // Validate the field after file selection.
          },

          // Display container for the file picker.
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: _pickedFile == null
                  ? _buildPlaceholder() // Show placeholder if no file is selected.
                  : _buildFilePreview(), // Show preview if a file is selected.
            ),
          ),
        ),

        // Display error message if validation fails.
        displayErrorMessage(_errorMessage, context),
      ],
    );
  }

  /// Builds a placeholder widget that is shown when no file is selected.
  /// This UI informs the user to select a file either by drag-and-drop or clicking.
  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.image_outlined, // Icon representing file upload.
          size: 50,
          color: Colors.grey,
        ),
        const SizedBox(height: 12),
        Text(
          "Drag-drop or click here to choose a file",
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Builds the preview widget to show the selected file.
  /// This will either display an image preview if the selected file is an image
  /// or the file name if it's a non-image file.
  Widget _buildFilePreview() {
    final file = _pickedFile!.file;
    if (file != null && _isImageFile(file.path)) {
      return Stack(
        children: [
          // Display image preview if the selected file is an image.
          Image.file(
            File(file.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              tooltip: "Update selection",
              icon: const Icon(
                Icons
                    .edit, // Icon to allow editing/replacing the selected file.
                color: Colors.red,
              ),
              onPressed: () async {
                // Re-opens file picker to replace the selected file.
                final pickedFile = await _filePickerHelper.pickFile();
                setState(() {
                  _pickedFile = pickedFile;
                });
                _validate(); // Validate after replacing the file.
              },
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show a generic file icon for non-image files.
          const Icon(
            Icons.insert_drive_file_outlined,
            size: 50,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          // Display the name of the selected file.
          Text(
            _pickedFile?.file?.name ?? 'File Selected',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap to replace", // Instruction for the user to replace the selected file.
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }

  /// Helper method to check if the selected file is an image.
  /// Returns `true` if the file extension matches common image formats.
  bool _isImageFile(String path) {
    final extension = path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension);
  }

  /// Validates the field and sets an error message if validation fails.
  /// The field is marked invalid if no file is selected when the field is required.
  void _validate([StewardFilePickerResult? pickedFile]) {
    bool isValid = _validateRequiredField();
    updateState(isValid);
  }

  /// Validates if a file is selected when the field is required.
  /// Displays an error message if the validation fails.
  bool _validateRequiredField() {
    final isRequired = Validators.validateRequiredField(
      validationRequired: widget.field.validation?.required ?? false,
      fieldLabel: widget.field.label,
      fieldValue: _pickedFile?.file != null ? 'File selected' : null,
      setError: (errorMessage) {
        setState(() {
          _errorMessage = errorMessage; // Set error message for display.
        });
      },
    );
    return isRequired;
  }

  /// Updates the form state using the [FormStewardStateNotifier].
  /// This method updates the form field's value and validity status.
  void updateState(bool isValid) {
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName,
      fieldName: widget.field.name,
      value: _pickedFile?.file?.path, // The path of the selected file.
      isValid: isValid, // The validity status of the field.
    );
  }

  /// Listens for a validation trigger from the [ValidationTriggerNotifier].
  /// When the trigger is detected, the field is validated.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate(_pickedFile); // Validate the field when triggered.
    }
  }
}
