import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/file_picker/steward_file_picker_helper.dart';
import 'package:form_steward/src/utils/helpers.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// A widget that allows users to pick and manage video files within a form.
///
/// This class is designed to work with the form steward state management
/// and provides validation feedback based on the user's actions.
///
/// **Parameters:**
/// - `field`: The model representing the field's data and validation rules.
/// - `stepName`: The name of the current step in the form process.
/// - `formStewardStateNotifier`: A notifier for managing the form state.
/// - `validationTriggerNotifier`: A notifier to trigger validation for the field.
///
/// Usage:
/// ```dart
/// StewardVideoPickerField(
///   field: myFieldModel,
///   stepName: 'step1',
///   formStewardStateNotifier: myFormStewardStateNotifier,
///   validationTriggerNotifier: myValidationTriggerNotifier,
/// )
/// ```
///
/// This widget manages video selection, displaying the selected video and
/// handling user interactions for picking a video file.
class StewardVideoPickerField extends StatefulWidget {
  final FieldModel field;
  final String stepName;
  final FormStewardStateNotifier formStewardStateNotifier;
  final ValidationTriggerNotifier validationTriggerNotifier;

  StewardVideoPickerField({
    super.key,
    required BaseFieldWidget fieldParams,
  })  : field = fieldParams.field,
        stepName = fieldParams.stepName,
        formStewardStateNotifier = fieldParams.formStewardStateNotifier,
        validationTriggerNotifier = fieldParams.validationTriggerNotifier;

  @override
  StewardVideoPickerFieldState createState() => StewardVideoPickerFieldState();
}

/// The state for the `StewardVideoPickerField` widget.
class StewardVideoPickerFieldState extends State<StewardVideoPickerField> {
  /// An instance of [FilePickerHelper] to assist with file picking operations.
  final FilePickerHelper filePickerHelper = FilePickerHelper();

  /// The selected video file, if any.
  File? _videoFile;

  /// The player used for video playback.
  late final Player _player;

  /// The controller for managing video playback and state.
  late final VideoController _controller;

  /// A flag indicating whether the recording is in progress.
  bool _isRecording = false;

  /// A flag indicating whether a video has been successfully selected or recorded.
  bool _hasVideo = false;

  /// An error message to display when validation fails or an error occurs.
  String? _errorMessage;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize the video player and controller.
    _player = Player();
    _controller = VideoController(_player);
    checkForSavedFile();

    // Add a listener to the validation trigger notifier to respond to validation changes.
    widget.validationTriggerNotifier.addListener(_onValidationTrigger);
  }

  void checkForSavedFile() async {
    final savedFile = await _retrieveSavedVideoFile();
    if (savedFile?.path != null) {
      _handleSavedVideoFile(savedFile!);
    }
  }

  @override
  void dispose() {
    // Dispose of the video player to release resources.
    if (_videoFile?.path != null) {
      _player.dispose();
    }

    // Remove the listener from the validation trigger notifier to avoid memory leaks.
    widget.validationTriggerNotifier.removeListener(_onValidationTrigger);

    super.dispose();
  }

  /// Initiates video recording or picking from the device.
  ///
  /// This method checks if the platform is mobile and requests the necessary
  /// permissions before allowing the user to record a video. If permission
  /// is granted, it sets the recording state to true, prompts the user to
  /// capture a video, and saves the recorded video file. Once saved, it
  /// updates the form state with the file path and initializes the video player.
  /// Finally, it resets the recording state to false.
  ///
  /// If the platform is not mobile, a dialog will be displayed to inform
  /// the user that video recording is unsupported.
  ///
  /// Returns:
  /// - A [Future] that completes when the video recording process is finished.
  Future<void> _recordVideo() async {
    // Check if the platform supports video recording
    if (!_isMobilePlatform()) {
      _showUnsupportedRecordingDialog();
      return;
    }

    // Request permissions to access the camera and storage
    bool permissionGranted = await _requestPermission();
    if (!permissionGranted) return;

    // Update the state to indicate recording is in progress
    setState(() {
      _isRecording = true;
    });

    // Prompt the user to capture a video
    final pickedVideo =
        await filePickerHelper.pickOrCaptureVideo(capture: true);

    // If a video file was picked, save it and update the form state
    if (pickedVideo.file != null) {
      final savedFilePath = await _saveVideoFile(File(pickedVideo.file!.path));
      if (savedFilePath != null) {
        _updateFormState(savedFilePath);
        setState(() {
          _videoFile = File(savedFilePath);
          _hasVideo = true;
        });
        _initializeVideoPlayer();
      }
    }

    // Reset the recording state
    setState(() {
      _isRecording = false;
    });
  }

  /// Prompts the user to pick a video file from the device.
  ///
  /// This method uses the `filePickerHelper` to allow the user to either pick
  /// an existing video or capture a new one. If a video file is successfully
  /// picked, it saves the file and updates the form state accordingly.
  ///
  /// Returns:
  /// - A [Future] that completes when the video picking process is finished.
  Future<void> _pickVideo() async {
    // Prompt the user to pick or capture a video
    final pickedVideo = await filePickerHelper.pickOrCaptureVideo();

    if (pickedVideo.file != null) {
      final savedFilePath = await _saveVideoFile(File(pickedVideo.file!.path));
      if (savedFilePath != null) {
        setState(() {
          _isLoading = true; // Start showing the loader
        });
        _updateFormState(savedFilePath);
        _handleSavedVideoFile(File(savedFilePath));
      }
    }
  }

  // If a video file was picked, save it and update the form state
  void _handleSavedVideoFile(File savedFile) {
    _updateFormState(savedFile.path);
    setState(() {
      _videoFile = savedFile;
      _hasVideo = true;
    });
    _initializeVideoPlayer();
  }

  /// Initializes the video player with the selected video file.
  ///
  /// This method opens the video file using the player. If a video file
  /// is available, it sets up the player to prepare for playback.
  ///
  /// Returns:
  /// - A [Future] that completes when the video player is initialized.
  Future<void> _initializeVideoPlayer() async {
    // Check if a video file is available
    if (_videoFile != null) {
      try {
        await _player.open(
          Media(_videoFile!.path),
          play: false, // Do not auto-play the video
        );
      } catch (e) {
        print("Error initializing video player: $e");
      } finally {
        setState(() {
          _isLoading = false; // Hide the loader after the video is loaded
        });
      }
    }
  }

  /// Saves the selected video file to a specified directory.
  ///
  /// This method attempts to copy the provided [videoFile] to a designated
  /// save directory. The file is named with a timestamp to ensure uniqueness.
  ///
  /// Returns:
  /// - A [Future<String?>] that resolves to the path of the saved video file
  ///   if successful, or null if the save operation failed.
  Future<String?> _saveVideoFile(File videoFile) async {
    // Get the directory where the video file will be saved
    Directory? directory = await _getSaveDirectory();
    if (directory != null && await directory.exists()) {
      // Generate a unique file path using the field name and current timestamp
      final filePath =
          '${directory.path}/${widget.field.name}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      try {
        // Copy the video file to the new location
        await videoFile.copy(filePath);
        return filePath; // Return the path of the saved file
      } catch (e) {
        print("Error saving video file: $e"); // Log any errors
      }
    }
    return null; // Return null if the save operation failed
  }

  Future<File?> _retrieveSavedVideoFile() async {
    // Get the directory where the video files are saved
    Directory? directory = await _getSaveDirectory();
    if (directory != null && await directory.exists()) {
      try {
        // List all the files in the directory
        List<FileSystemEntity> files = directory.listSync();

        // Filter for files that match the field name and end with .mp4
        List<FileSystemEntity> videoFiles = files.where((file) {
          final fileName = file.path.split('/').last;
          return fileName.startsWith('${widget.field.name}_') &&
              fileName.endsWith('.mp4');
        }).toList();

        if (videoFiles.isNotEmpty) {
          // Sort the files by last modified date (most recent first)
          videoFiles.sort((a, b) {
            return File(b.path)
                .lastModifiedSync()
                .compareTo(File(a.path).lastModifiedSync());
          });

          // Return the most recent video file
          return File(videoFiles.first.path);
        }
      } catch (e) {
        print("Error retrieving video file: $e"); // Log any errors
      }
    }
    return null; // Return null if no video files are found or an error occurs
  }

  /// Determines the appropriate directory for saving video files based on the platform.
  ///
  /// This method checks the platform (Android or iOS) and returns the appropriate
  /// directory for storing video files. It defaults to the application documents
  /// directory if the platform is not recognized.
  ///
  /// Returns:
  /// - A [Future<Directory?>] that resolves to the directory for saving video files,
  ///   or null if the directory cannot be determined.
  Future<Directory?> _getSaveDirectory() async {
    if (Platform.isAndroid) {
      return Directory(
          '/storage/emulated/0/Movies'); // Default path for Android
    }
    if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory(); // Default path for iOS
    }
    return await getApplicationDocumentsDirectory(); // Fallback for other platforms
  }

  /// Requests the necessary permissions to access the camera, microphone, and storage.
  ///
  /// This method checks the current status of the camera, microphone, and storage
  /// permissions. If any permission is not granted, it requests the user for
  /// the necessary permissions. If the user denies any of the permissions, a
  /// dialog will be shown informing them of the need for permissions.
  ///
  /// Returns:
  /// - A [Future<bool>] that resolves to true if all permissions are granted,
  ///   or false if any permission was denied.
  Future<bool> _requestPermission() async {
    // Check permissions for Android and iOS platforms
    if (Platform.isAndroid || Platform.isIOS) {
      var cameraStatus =
          await Permission.camera.status; // Check camera permission status
      var microphoneStatus = await Permission
          .microphone.status; // Check microphone permission status
      var storageStatus =
          await Permission.storage.status; // Check storage permission status

      // If any permission is not granted, request permissions
      if (!cameraStatus.isGranted ||
          !microphoneStatus.isGranted ||
          !storageStatus.isGranted) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.camera,
          Permission.microphone,
          Permission.storage,
        ].request(); // Request permissions

        // Check if any permission was denied
        if (statuses[Permission.camera]!.isDenied ||
            statuses[Permission.microphone]!.isDenied ||
            statuses[Permission.storage]!.isDenied) {
          _showPermissionDialog(); // Show dialog if permissions are denied
          return false; // Return false if any permission is denied
        }
      }
    }
    return true; // Return true if all permissions are granted
  }

  /// Displays a dialog informing the user that camera, microphone, and storage
  /// permissions are required to record and save videos.
  ///
  /// This dialog prompts the user to either open the app settings to grant the
  /// necessary permissions or to cancel the dialog. It is called when any of
  /// the required permissions are denied.
  ///
  /// The dialog contains:
  /// - A title indicating that permission is required.
  /// - A message explaining the permissions needed for video recording and saving.
  /// - Two action buttons:
  ///   - "Open Settings": Navigates the user to the app's settings to grant permissions.
  ///   - "Cancel": Closes the dialog without taking any action.
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permission Required"), // Dialog title
          content: const Text(
            "Camera, microphone, and storage permissions are required to record and save videos. Please grant these permissions in the app settings.",
          ), // Dialog message
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                openAppSettings(); // Open app settings to grant permissions
              },
              child: const Text("Open Settings"), // Button to open settings
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text("Cancel"), // Cancel button
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog informing the user that video recording is not supported
  /// on the current platform.
  ///
  /// This dialog informs the user that they cannot record video on the device
  /// and suggests using a native video recording app instead. It provides an
  /// "OK" button to close the dialog.
  ///
  /// The dialog contains:
  /// - A title indicating that the feature is unsupported.
  /// - A message explaining the limitation and providing a suggestion.
  void _showUnsupportedRecordingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Unsupported Feature"), // Dialog title
          content: const Text(
            "Video recording is not supported on this platform. Please use a native video recorder app to capture video.",
          ), // Dialog message
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text("OK"), // Button to acknowledge the message
            ),
          ],
        );
      },
    );
  }

  /// Updates the form state with the provided video file path.
  ///
  /// This method checks whether the file path is valid based on the field's
  /// validation requirements. If the file path is valid, it clears any error
  /// message and updates the form state with the new value.
  ///
  /// The form state is updated through the provided `formStewardStateNotifier`.
  ///
  /// Parameters:
  /// - [filePath]: The path of the video file to be saved. If null and the
  ///   field is required, the field will be marked as invalid.
  void _updateFormState(String? filePath) {
    bool isValid =
        filePath != null || widget.field.validation?.required != true;
    if (isValid) {
      setState(() {
        _errorMessage = null; // Clear error message if valid
      });
    }
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName,
      fieldName: widget.field.name,
      value: filePath,
      isValid: isValid, // Update validity based on file path
    );
  }

  /// Triggers validation when the validation notifier indicates a change in state.
  ///
  /// This method checks if the current step name matches the value of the
  /// `validationTriggerNotifier`. If they match, it calls the `_validate`
  /// method to perform validation for the video field.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate(); // Trigger validation if the step name matches
    }
  }

  /// Validates the video field to ensure that all required criteria are met.
  ///
  /// This method checks if the video field is required and if a video file
  /// has been selected. If the video file is not present and the field is
  /// marked as required, it sets an error message. Otherwise, it updates
  /// the form state with the path of the selected video file.
  ///
  /// If the video field is valid, the form state will be updated accordingly.
  void _validate() {
    if (widget.field.validation?.required == true && _videoFile == null) {
      setState(() {
        _errorMessage =
            '${widget.field.label} is required.'; // Set error message if required field is empty
      });
    } else {
      _updateFormState(
          _videoFile?.path); // Update form state with video file path
    }
  }

  /// Deletes the currently selected video and updates the form state.
  ///
  /// This method resets the video file and related state variables to their
  /// initial values, stops the video player, and updates the form state
  /// to indicate that no video file is selected.
  ///
  /// After calling this method, the user will no longer see any video file
  /// associated with the video picker field.
  void _deleteVideo() async {
    if (_videoFile != null && await _videoFile!.exists()) {
      try {
        // Delete the file from the file system
        await _videoFile!.delete();
      } catch (e) {
        print("Error deleting video file: $e");
      }
    }

    // Reset the video file and player state
    setState(() {
      _videoFile = null; // Reset the video file
      _hasVideo = false; // Indicate that no video is present
      _player.stop(); // Stop any video playback
    });

    _updateFormState(null); // Update form state to reflect the deletion
  }

  /// Checks if the current platform is mobile (Android or iOS).
  ///
  /// This method returns a boolean value indicating whether the app is running
  /// on a mobile platform. It is used to determine if video recording features
  /// are supported, as they may not be available on non-mobile platforms.
  bool _isMobilePlatform() {
    return Platform.isAndroid ||
        Platform.isIOS; // Returns true if the platform is Android or iOS
  }

  /// Builds the widget tree for the video picker field.
  ///
  /// This method constructs the visual representation of the video picker field,
  /// including the label, video container, and any error messages. It utilizes
  /// a column layout to arrange these elements vertically.
  ///
  /// Returns a [Column] widget containing the label, video container, and
  /// error message if applicable.
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field.label,
              style:
                  Theme.of(context).textTheme.bodyMedium, // Display field label
            ),
            const SizedBox(
                height: 8.0), // Add space between label and video container
            _buildVideoContainer(), // Build the container for video controls
            if (_errorMessage != null) ...[
              displayErrorMessage(_errorMessage, context),
            ],
          ],
        ),
        // Loader
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  /// Builds the container that holds the video preview and controls.
  ///
  /// This method creates a container with a border and rounded corners.
  /// Inside the container, it arranges the video preview and control elements
  /// in a vertical column layout.
  ///
  /// Returns a [Container] widget that contains the video preview and controls.
  Widget _buildVideoContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Border around the container
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
      padding: const EdgeInsets.all(8), // Padding inside the container
      child: Column(
        children: [
          _buildVideoPreview(), // Build the video preview
          const SizedBox(height: 8), // Space between preview and controls
          _buildVideoControls(), // Build the video control buttons
        ],
      ),
    );
  }

  /// Builds the video preview section.
  ///
  /// This method checks if a video has been recorded. If a video exists,
  /// it displays the video using an [AspectRatio] widget to maintain
  /// the correct dimensions. If no video is selected, it displays a message
  /// indicating that no video is available.
  ///
  /// Returns an [AspectRatio] widget containing the video player or a message
  /// if no video is selected.
  Widget _buildVideoPreview() {
    if (_hasVideo) {
      return AspectRatio(
        aspectRatio: 16 / 9, // Maintain 16:9 aspect ratio for video
        child: Video(controller: _controller), // Display the video
      );
    } else {
      return const AspectRatio(
        aspectRatio: 16 / 9, // Maintain 16:9 aspect ratio for placeholder
        child: Center(
            child: Text(
                'No video selected')), // Message when no video is available
      );
    }
  }

  /// Builds the video control buttons for recording and playing videos.
  ///
  /// This method constructs a row of buttons that allow the user to record a
  /// new video, select a video from the library, play or pause the currently
  /// selected video, and delete the video if one has been recorded. The
  /// controls are arranged evenly within the row.
  ///
  /// Returns a [Row] widget containing the video control buttons.
  Widget _buildVideoControls() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, // Evenly distribute buttons
      children: [
        if (_isMobilePlatform())
          IconButton(
            icon: Icon(_isRecording
                ? Icons.stop
                : Icons.videocam), // Toggle icon based on recording state
            onPressed: _isRecording
                ? null
                : _recordVideo, // Disable button if recording
            color: Colors.blue, // Color for the recording button
          ),
        IconButton(
          icon: const Icon(Icons.photo_library), // Icon for picking a video
          onPressed:
              _isRecording ? null : _pickVideo, // Disable button if recording
          color: Colors.green, // Color for the pick video button
        ),
        if (_hasVideo) ...[
          IconButton(
            icon: Icon(_player.state.playing
                ? Icons.pause
                : Icons.play_arrow), // Toggle play/pause icon
            onPressed: () {
              if (_player.state.playing) {
                _player.pause(); // Pause the video if playing
              } else {
                _player.play(); // Play the video if paused
              }
              setState(() {}); // Update the UI
            },
            color: Colors.orange, // Color for the play/pause button
          ),
          IconButton(
            icon: const Icon(Icons.delete), // Icon for deleting the video
            onPressed: _deleteVideo, // Action to delete the video
            color: Colors.red, // Color for the delete button
          ),
        ],
      ],
    );
  }
}
