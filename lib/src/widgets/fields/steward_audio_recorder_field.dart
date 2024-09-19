import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/audio_recorder/audio_recorder_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';

/// A widget that provides audio recording and playback functionality within a form.
///
/// The `AudioRecorderWidget` allows users to record audio, play back the recorded audio,
/// and manage the audio file as part of a form field. It integrates with [FormStewardStateNotifier]
/// and [ValidationTriggerNotifier] to handle form state and validation.
///
/// This widget supports recording audio, displaying recording duration, playing back
/// recorded audio, and deleting the audio file. It ensures that the audio file is managed
/// correctly and integrates with the form's validation system to update the form state based on
/// the presence and validity of the recorded audio file.
class AudioRecorderWidget extends StatefulWidget {
  /// Creates an [AudioRecorderWidget].
  ///
  /// The [field], [stepName], [formStewardStateNotifier], and [validationTriggerNotifier]
  /// parameters are required to set up the widget.
  ///
  /// - [field] is used to provide the configuration for the form field and to handle
  ///   validation.
  /// - [stepName] indicates the name of the current step in the form.
  /// - [formStewardStateNotifier] is used to update and manage the form state.
  /// - [validationTriggerNotifier] is used to trigger validation for the form field.
  const AudioRecorderWidget({
    super.key,
    required this.field,
    required this.stepName,
    required this.formStewardStateNotifier,
    required this.validationTriggerNotifier,
  });

  /// The [FieldModel] used for validation and configuration of the form field.
  ///
  /// This model contains information about the form field and its validation rules.
  final FieldModel field;

  /// The name of the current step in the form.
  ///
  /// This string identifies the step in the form process where this widget is used.
  final String stepName;

  /// The [FormStewardStateNotifier] used to manage and update the form state.
  ///
  /// This notifier helps in updating the state of the form based on user interactions
  /// and form field values.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// The [ValidationTriggerNotifier] used to trigger validation of the form field.
  ///
  /// This notifier is used to trigger validation when needed, based on user actions
  /// or other triggers within the form.
  final ValidationTriggerNotifier validationTriggerNotifier;

  @override
  AudioRecorderWidgetState createState() => AudioRecorderWidgetState();
}

/// The state class for [AudioRecorderWidget].
///
/// This class manages the internal state of the [AudioRecorderWidget], including
/// audio recording and playback functionality. It handles user interactions, such as
/// starting and stopping recordings, playing back recorded audio, and updating
/// the UI based on the state of the audio recording and playback.
///
/// The state class uses [AudioRecorderHelper] for recording audio, [AudioPlayer]
/// for playback, and manages various UI-related states like recording status,
/// playback progress, and error messages.
class AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  /// Helper instance for managing audio recording.
  final AudioRecorderHelper _audioRecorderHelper = AudioRecorderHelper();

  /// Indicates whether the audio recording is currently in progress.
  bool _isRecording = false;

  /// Indicates whether an audio recording has been completed.
  bool _hasRecorded = false;

  /// The recorded audio file.
  XFile? _audioFile;

  /// Timer used to track the duration of the recording.
  Timer? _timer;

  /// The number of seconds recorded so far.
  int _recordedSeconds = 0;

  /// The audio player used for playback of the recorded audio.
  AudioPlayer? _audioPlayer;

  /// Indicates whether the audio is currently being played.
  bool _isPlaying = false;

  /// The total duration of the recorded audio.
  Duration _audioDuration = Duration.zero;

  /// The current playback position of the audio.
  Duration _currentPosition = Duration.zero;

  /// Stores any error messages for field validity.
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Adds a listener to the [validationTriggerNotifier] to listen for validation triggers.
    widget.validationTriggerNotifier.addListener(_onValidationTrigger);
  }

  @override
  void dispose() {
    // Cancels the timer if it's running.
    _timer?.cancel();

    // Disposes of the audio player to release resources.
    _audioPlayer?.dispose();

    // Removes the listener from [validationTriggerNotifier].
    widget.validationTriggerNotifier.removeListener(_onValidationTrigger);

    super.dispose();
  }

  /// Initializes the audio player and sets up listeners for playback events.
  ///
  /// This method creates an instance of [AudioPlayer], and sets up listeners
  /// to handle changes in the audio duration, playback position, and completion
  /// of playback. It updates the state to reflect these changes:
  ///
  /// - [onDurationChanged]: Updates the total duration of the audio.
  /// - [onPositionChanged]: Updates the current playback position.
  /// - [onPlayerComplete]: Resets the playback state and position when the audio finishes.
  Future<void> _initializePlayer() async {
    _audioPlayer = AudioPlayer();

    // Listener for changes in the total duration of the audio.
    _audioPlayer?.onDurationChanged.listen((Duration duration) {
      setState(() {
        _audioDuration = duration; // Sets the total duration of the audio.
      });
    });

    // Listener for changes in the current playback position.
    _audioPlayer?.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position; // Sets the current playback position.
      });
    });

    // Listener for when playback is completed.
    _audioPlayer?.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying =
            false; // Resets the playback state when the audio finishes.
        _currentPosition =
            Duration.zero; // Resets the current position to the start.
      });
    });
  }

  /// Loads the audio file for playback.
  ///
  /// This method checks if an audio file is available (`_audioFile` is not null),
  /// and if so, sets the source URL of the [AudioPlayer] to the path of the
  /// recorded audio file.
  ///
  /// **Note:** This method assumes that `_audioPlayer` is already initialized.
  ///
  /// **Usage:** This method is typically called before starting playback to ensure
  /// the audio file is ready to be played.
  Future<void> _loadAudioFile() async {
    if (_audioFile != null) {
      await _audioPlayer?.setSourceUrl(
          _audioFile!.path); // Set the source URL of the audio player.
    }
  }

  /// Handles audio playback by starting or pausing the playback.
  ///
  /// This method first checks if an audio file is available. If an audio file is
  /// present and the audio player is not initialized, it initializes the player.
  /// If the audio is not currently playing, it loads the audio file and starts
  /// playback. If the audio is already playing, it pauses the playback.
  ///
  /// **Note:** This method toggles the playback state between playing and paused.
  ///
  /// **Usage:** This method is called when the user interacts with playback controls,
  /// such as play or pause buttons.
  Future<void> _handlePlayback() async {
    if (_audioFile == null) {
      return; // Exit if no audio file is available.
    }

    if (_audioPlayer == null) {
      await _initializePlayer(); // Initialize the audio player if not already done.
    }

    if (!_isPlaying) {
      await _loadAudioFile(); // Load the audio file before starting playback.
      await _audioPlayer
          ?.play(DeviceFileSource(_audioFile!.path)); // Start playback.
      setState(() {
        _isPlaying =
            true; // Update the state to reflect that playback is active.
      });
    } else {
      await _audioPlayer?.pause(); // Pause playback if it is currently playing.
      setState(() {
        _isPlaying =
            false; // Update the state to reflect that playback is paused.
      });
    }
  }

  /// Stops audio playback and resets the playback state.
  ///
  /// This method stops the current audio playback if the [AudioPlayer] instance is
  /// not null. It also updates the state to indicate that playback has stopped and
  /// resets the current playback position to zero.
  ///
  /// **Usage:** This method is called when the user stops the audio playback, either
  /// manually or through a specific control in the UI.
  Future<void> _stopPlayback() async {
    if (_audioPlayer != null) {
      await _audioPlayer?.stop(); // Stop playback.
      setState(() {
        _isPlaying = false; // Update state to indicate playback has stopped.
        _currentPosition =
            Duration.zero; // Reset the playback position to zero.
      });
    }
  }

  /// Starts recording and initializes the timer for recording duration.
  ///
  /// This method first checks if the necessary permissions are granted by calling
  /// `_requestPermission`. If permissions are granted, it starts recording using
  /// `_audioRecorderHelper` and initializes a timer to track the duration of the
  /// recording. The state is updated to indicate that recording has started.
  ///
  /// **Usage:** This method is called when the user initiates a recording action,
  /// typically through a record button in the UI.
  Future<void> _startRecording() async {
    bool permissionGranted = await _requestPermission(context);
    if (!permissionGranted) return; // Exit if permission is not granted.

    await _audioRecorderHelper.startRecording(); // Start recording.
    setState(() {
      _isRecording = true; // Update state to indicate recording has started.
      _recordedSeconds = 0; // Reset the recorded duration to zero.
      _startTimer(); // Start the timer to track recording duration.
    });
  }

  /// Stops the recording, saves the recorded file, and stops the timer.
  ///
  /// This method cancels the recording timer and stops the recording using
  /// `_audioRecorderHelper`. If a recorded file is obtained, it saves the file and
  /// updates the form state with the file's path. The state is then updated to reflect
  /// that recording has stopped and a new audio file has been recorded.
  ///
  /// **Usage:** This method is called when the user stops a recording, typically
  /// through a stop button in the UI.
  Future<void> _stopRecording() async {
    _timer?.cancel(); // Cancel the recording timer.
    final XFile? recordedFile = await _audioRecorderHelper
        .stopRecording(); // Stop recording and get the recorded file.
    if (recordedFile != null && mounted) {
      final savedFilePath =
          await _saveRecordedFile(recordedFile); // Save the recorded file.
      if (savedFilePath != null) {
        _updateFormState(
            savedFilePath); // Update form state with the file path.
      }
      setState(() {
        _audioFile = recordedFile; // Update state with the recorded file.
        _hasRecorded = true; // Indicate that a recording has been made.
        _isRecording = false; // Update state to indicate recording has stopped.
      });
    }
  }

  /// Starts a timer to update the recording duration every second.
  ///
  /// This method initializes a periodic timer that updates the `_recordedSeconds`
  /// state every second to reflect the duration of the ongoing recording. The timer
  /// is only active while the widget is mounted.
  ///
  /// **Usage:** This method is called when recording starts to keep track of the
  /// recording duration.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordedSeconds++; // Increment recorded duration every second.
        });
      }
    });
  }

  /// Formats the given duration in seconds into a MM:SS string format.
  ///
  /// This method converts the provided duration in seconds into a string formatted
  /// as "MM:SS". It ensures that minutes and seconds are displayed as two-digit
  /// numbers, with leading zeros if necessary.
  ///
  /// **Parameters:**
  /// - `seconds`: The duration in seconds to be formatted.
  ///
  /// **Returns:** A string representing the formatted duration.
  ///
  /// **Usage:** This method is used to display the recording duration in a user-friendly
  /// format in the UI.
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Deletes the recorded audio file and resets relevant state.
  ///
  /// This method clears the recorded audio file and resets the recording-related
  /// state variables. It also updates the form state to reflect that the recording
  /// has been deleted.
  ///
  /// **Usage:** This method is called when the user decides to delete the recorded
  /// audio file, typically through a delete button in the UI.
  void _deleteAudio() {
    setState(() {
      _audioFile = null; // Clear the audio file.
      _hasRecorded = false; // Update state to reflect no recorded audio.
      _recordedSeconds = 0; // Reset the recorded duration.
    });
    widget.validationTriggerNotifier.value = widget.stepName;
  }

  /// Saves the recorded audio file to local storage.
  ///
  /// This method saves the provided recorded audio file to a directory in local
  /// storage. The file is saved with a timestamp to ensure a unique filename.
  ///
  /// **Parameters:**
  /// - `recordedFile`: The `XFile` instance representing the recorded audio file.
  ///
  /// **Returns:** A `Future<String?>` that resolves to the file path where the audio
  /// file was saved. Returns `null` if there was an error or the directory does not exist.
  ///
  /// **Usage:** This method is called to persist the recorded audio file to local storage
  /// and obtain the file path for further use.
  Future<String?> _saveRecordedFile(XFile recordedFile) async {
    Directory? directory =
        await _getSaveDirectory(); // Get the directory to save the file
    if (directory != null && await directory.exists()) {
      final filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a'; // Create a unique file path
      try {
        await recordedFile.saveTo(filePath); // Save the recorded file
        return filePath; // Return the file path if successful
      } catch (e) {
        print("Error saving audio file: $e"); // Log the error if saving fails
      }
    }
    return null; // Return null if directory does not exist or an error occurs
  }

  /// Gets the directory where the audio file will be saved.
  ///
  /// This method determines the appropriate directory for saving the audio file based
  /// on the platform.
  ///
  /// **Returns:** A `Future<Directory?>` representing the directory where the audio
  /// file will be saved. Returns `null` for web platforms.
  ///
  /// **Usage:** This method is used to obtain the correct directory for saving files
  /// depending on the platform (Android, iOS, or other).
  Future<Directory?> _getSaveDirectory() async {
    if (kIsWeb) return null; // Return null for web platforms
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Music'); // Directory for Android
    }
    if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory(); // Directory for iOS
    }
    return await getDownloadsDirectory(); // Directory for other platforms
  }

  /// Requests permission to access storage.
  ///
  /// This method requests storage permission from the user if it is not already granted.
  /// For Android and iOS platforms, it handles permission status and displays a dialog
  /// if permission is permanently denied.
  ///
  /// **Parameters:**
  /// - `context`: The `BuildContext` to show the permission dialog if needed.
  ///
  /// **Returns:** A `Future<bool>` that resolves to `true` if permission is granted
  /// or `false` if permission is denied and not granted permanently.
  ///
  /// **Usage:** This method is called before accessing storage to ensure that the
  /// application has the necessary permissions.
  Future<bool> _requestPermission(BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) {
      var status =
          await Permission.storage.status; // Check current permission status
      if (status.isGranted) {
        return true; // Return true if permission is already granted
      }

      if (status.isDenied) {
        final result = await Permission.storage.request(); // Request permission
        if (result.isGranted) {
          return true; // Return true if permission is granted after request
        }
        if (result.isPermanentlyDenied && context.mounted) {
          _showPermissionDialog(
              context); // Show dialog if permission is permanently denied
        }
      }
    }
    return true; // Return true if permission is not required for the current platform
  }

  /// Shows a dialog to inform the user to enable permissions.
  ///
  /// This method displays an `AlertDialog` that informs the user they need to grant
  /// storage permissions to save recorded audio files. The dialog provides options
  /// to open the app settings or cancel the action.
  ///
  /// **Parameters:**
  /// - `context`: The `BuildContext` used to show the dialog.
  ///
  /// **Usage:** This method is called when storage permissions are permanently denied,
  /// prompting the user to navigate to app settings and grant the necessary permissions.
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Permission Required"),
          content: const Text(
            "Storage permission required to save recorded audio file. To continue navigate to app settings and grant.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                openAppSettings(); // Open app settings for permissions
              },
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  /// Updates the form state with the audio file's path and validity.
  ///
  /// This method updates the form state with the path of the recorded audio file
  /// and its validity based on whether the file path is non-null and whether the
  /// field is required. If the file path is null and the field is required, an
  /// error message is set; otherwise, it is cleared.
  ///
  /// **Parameters:**
  /// - `filePath`: The file path of the recorded audio. Can be `null` if no file is recorded.
  ///
  /// **Usage:** This method is called to update the form's state with the new file path
  /// and to indicate whether the field is valid or invalid based on the presence of a file.
  void _updateFormState(String? filePath) {
    bool isValid = filePath != null ||
        widget.field.validation?.required !=
            true; // Determine if the field is valid
    if (isValid) {
      setState(() {
        _errorMessage = null; // Clear error message if valid
      });
    }
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName,
      fieldName: widget.field.name,
      value: filePath,
      isValid: isValid,
    ); // Update the form state notifier with the new value and validity
  }

  /// Listens for validation triggers from [ValidationTriggerNotifier] and validates the field.
  ///
  /// This method is invoked when a validation trigger occurs. It checks if the current
  /// step name matches the trigger value. If they match, it initiates validation by
  /// calling the `_validate` method.
  ///
  /// **Usage:** This method is used to respond to validation triggers and ensure that
  /// the field is validated according to the current validation state.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate(); // Validate when triggered
    }
  }

  /// Validates the field based on whether it's required and if an audio file is selected.
  ///
  /// This method checks if the field has a required validation rule and if an audio
  /// file has been recorded. If the field is required and no audio file is present,
  /// it sets an error message indicating that the field is required. Otherwise, it
  /// updates the form state with the audio file's path.
  ///
  /// **Usage:** This method is used to ensure that required fields have been filled out
  /// correctly and to update the form state with the current audio file's path.
  void _validate() {
    if (widget.field.validation?.required == true && _audioFile == null) {
      setState(() {
        _errorMessage =
            '${widget.field.label} is required.'; // Set validation error message
      });
    } else {
      _updateFormState(_audioFile?.path); // Update form state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context),
        const SizedBox(height: 8.0),
        _buildAudioContainer(),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8.0),
          _buildErrorMessage(),
        ],
      ],
    );
  }

  /// Builds the label for the audio field.
  Widget _buildLabel(BuildContext context) {
    return Text(
      "Audio", // Displays the label for the field
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  /// Builds the container that holds the audio controls and playback information.
  Widget _buildAudioContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Border styling
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 8),
      child: Column(
        children: [
          _buildAudioControls(),
          if (_isRecording) _buildRecordingProgress(),
          if (_isPlaying) _buildPlaybackSlider(),
        ],
      ),
    );
  }

  /// Builds the row of audio controls (record, stop, play, delete).
  Widget _buildAudioControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _isRecording
              ? "Recording..."
              : _hasRecorded
                  ? _isPlaying
                      ? _formatDuration(_currentPosition.inSeconds)
                      : _formatDuration(_recordedSeconds)
                  : 'Tap to record audio',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
        _buildPlaybackButton(),
        _buildDeleteButton(),
        _buildRecordingButton(),
      ],
    );
  }

  /// Builds the playback button, showing play/pause based on the playback state.
  Widget _buildPlaybackButton() {
    return _hasRecorded
        ? IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.green),
            onPressed: _handlePlayback,
          )
        : Container();
  }

  /// Builds the delete button for removing the recorded audio.
  Widget _buildDeleteButton() {
    return _hasRecorded
        ? IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteAudio,
          )
        : Container();
  }

  /// Builds the button for starting or stopping recording based on the recording state.
  Widget _buildRecordingButton() {
    return _isRecording
        ? IconButton(
            icon: const Icon(Icons.stop, color: Colors.red),
            onPressed: _stopRecording,
          )
        : IconButton(
            icon: const Icon(Icons.mic, color: Colors.blue),
            onPressed: _startRecording,
          );
  }

  /// Builds a linear progress indicator for recording progress.
  Widget _buildRecordingProgress() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: LinearProgressIndicator(), // Represents recording progress.
    );
  }

  /// Builds a slider for playback progress.
  Widget _buildPlaybackSlider() {
    return Slider(
      value: _currentPosition.inSeconds.toDouble(),
      max: _audioDuration.inSeconds.toDouble(),
      onChanged: (double value) async {
        final newPosition = Duration(seconds: value.toInt());
        await _audioPlayer?.seek(newPosition); // Seek to the new position
        setState(() {
          _currentPosition = newPosition;
        });
      },
    );
  }

  /// Builds the error message widget if an error message is present.
  Widget _buildErrorMessage() {
    return Text(
      _errorMessage!,
      style: const TextStyle(color: Colors.red),
    );
  }
}
