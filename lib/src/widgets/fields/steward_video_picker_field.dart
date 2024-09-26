import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
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

class StewardVideoPickerFieldState extends State<StewardVideoPickerField> {
  final FilePickerHelper filePickerHelper = FilePickerHelper();
  dynamic
      _videoFile; // Changed to dynamic to support both File and web-specific file types
  late final Player _player;
  late final VideoController _controller;
  bool _isRecording = false;
  bool _hasVideo = false;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    checkForSavedFile();
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

  // ... (keep existing dispose method)

  Future<void> _recordVideo() async {
    if (!_isSupportedPlatform()) {
      _showUnsupportedRecordingDialog();
      return;
    }

    bool permissionGranted = await _requestPermission();
    if (!permissionGranted) return;

    setState(() {
      _isRecording = true;
    });

    final pickedVideo =
        await filePickerHelper.pickOrCaptureVideo(capture: true);

    if (pickedVideo.file != null) {
      final savedFilePath = await _saveVideoFile(pickedVideo.file!);
      if (savedFilePath != null) {
        _updateFormState(savedFilePath);
        setState(() {
          _videoFile = kIsWeb ? pickedVideo.file : File(savedFilePath);
          _hasVideo = true;
        });
        _initializeVideoPlayer();
      }
    }

    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _pickVideo() async {
    final pickedVideo = await filePickerHelper.pickOrCaptureVideo();

    if (pickedVideo.file != null) {
      final savedFilePath = await _saveVideoFile(pickedVideo.file!);
      if (savedFilePath != null) {
        setState(() {
          _isLoading = true;
        });
        _updateFormState(savedFilePath);
        _handleSavedVideoFile(kIsWeb ? pickedVideo.file : File(savedFilePath));
      }
    }
  }

  void _handleSavedVideoFile(dynamic savedFile) {
    _updateFormState(kIsWeb ? savedFile.name : savedFile.path);
    setState(() {
      _videoFile = savedFile;
      _hasVideo = true;
    });
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    if (_videoFile != null) {
      try {
        await _player.open(
          kIsWeb
              ? Media(Uri.parse(_videoFile.path).toString())
              : Media(_videoFile.path),
          play: false,
        );
      } catch (e) {
        print("Error initializing video player: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _saveVideoFile(dynamic videoFile) async {
    if (kIsWeb) {
      // For web, we can't save files locally. Return a URL or identifier instead.
      return videoFile.name; // or some unique identifier
    }

    Directory? directory = await _getSaveDirectory();
    if (directory != null && await directory.exists()) {
      final filePath =
          '${directory.path}/${widget.field.name}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      try {
        if (videoFile is File) {
          await videoFile.copy(filePath);
        } else {
          // Handle other file types if necessary
          // This might involve writing the file data to the new path
        }
        return filePath;
      } catch (e) {
        print("Error saving video file: $e");
      }
    }
    return null;
  }

  Future<dynamic> _retrieveSavedVideoFile() async {
    if (kIsWeb) {
      // For web, implement retrieval from IndexedDB or other web storage
      return null; // Placeholder for web implementation
    }

    Directory? directory = await _getSaveDirectory();
    if (directory != null && await directory.exists()) {
      try {
        List<FileSystemEntity> files = directory.listSync();
        List<FileSystemEntity> videoFiles = files.where((file) {
          final fileName = file.path.split('/').last;
          return fileName.startsWith('${widget.field.name}_') &&
              fileName.endsWith('.mp4');
        }).toList();

        if (videoFiles.isNotEmpty) {
          videoFiles.sort((a, b) {
            return File(b.path)
                .lastModifiedSync()
                .compareTo(File(a.path).lastModifiedSync());
          });
          return File(videoFiles.first.path);
        }
      } catch (e) {
        print("Error retrieving video file: $e");
      }
    }
    return null;
  }

  Future<Directory?> _getSaveDirectory() async {
    if (kIsWeb) return null;
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Movies');
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return await getApplicationDocumentsDirectory();
    }
    if (Platform.isWindows || Platform.isLinux) {
      return await getApplicationDocumentsDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<bool> _requestPermission() async {
    if (kIsWeb) return true; // Web doesn't require explicit permissions
    if (Platform.isAndroid || Platform.isIOS) {
      var cameraStatus = await Permission.camera.status;
      var microphoneStatus = await Permission.microphone.status;
      var storageStatus = await Permission.storage.status;

      if (!cameraStatus.isGranted ||
          !microphoneStatus.isGranted ||
          !storageStatus.isGranted) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.camera,
          Permission.microphone,
          Permission.storage,
        ].request();

        if (statuses[Permission.camera]!.isDenied ||
            statuses[Permission.microphone]!.isDenied ||
            statuses[Permission.storage]!.isDenied) {
          _showPermissionDialog();
          return false;
        }
      }
    }
    return true;
  }

  // ... (keep existing _showPermissionDialog and _showUnsupportedRecordingDialog methods)

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

  void _updateFormState(String? filePath) {
    bool isValid =
        filePath != null || widget.field.validation?.required != true;
    if (isValid) {
      setState(() {
        _errorMessage = null;
      });
    }
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName,
      fieldName: widget.field.name,
      value: filePath,
      isValid: isValid,
    );
  }

  // ... (keep existing _onValidationTrigger and _validate methods)

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

  void _deleteVideo() async {
    if (kIsWeb) {
      // Implement web-specific deletion logic if necessary
    } else if (_videoFile != null && await (_videoFile as File).exists()) {
      try {
        await (_videoFile as File).delete();
      } catch (e) {
        print("Error deleting video file: $e");
      }
    }

    setState(() {
      _videoFile = null;
      _hasVideo = false;
      _player.stop();
    });

    _updateFormState(null);
  }

  bool _isSupportedPlatform() {
    return kIsWeb ||
        Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),
            _buildVideoContainer(),
            if (_errorMessage != null) ...[
              displayErrorMessage(_errorMessage, context),
            ],
          ],
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildVideoContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildVideoPreview(),
          const SizedBox(height: 8),
          _buildVideoControls(),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_hasVideo) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Video(controller: _controller),
      );
    } else {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: Text('No video selected')),
      );
    }
  }

  Widget _buildVideoControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_isSupportedPlatform())
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
            onPressed: _isRecording ? null : _recordVideo,
            color: Colors.blue,
          ),
        IconButton(
          icon: const Icon(Icons.photo_library),
          onPressed: _isRecording ? null : _pickVideo,
          color: Colors.green,
        ),
        if (_hasVideo) ...[
          IconButton(
            icon: Icon(_player.state.playing ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_player.state.playing) {
                _player.pause();
              } else {
                _player.play();
              }
              setState(() {});
            },
            color: Colors.orange,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteVideo,
            color: Colors.red,
          ),
        ],
      ],
    );
  }
}
