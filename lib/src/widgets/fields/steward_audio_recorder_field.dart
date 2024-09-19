import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/audio_recorder/audio_recorder_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:media_kit/media_kit.dart';

/// A widget that allows users to record audio within a form field.
///
/// The [AudioRecorderWidget] is designed to be integrated within a form
/// managed by [FormStewardStateNotifier] and validated through
/// [ValidationTriggerNotifier]. It provides the ability to start, stop,
/// and delete audio recordings, and it updates the form state with the
/// recorded file path.
///
/// This widget is typically used in forms where an audio recording is a
/// required or optional field, and it ensures that the recording process
/// is handled smoothly within the form flow.
class AudioRecorderWidget extends StatefulWidget {
  /// Creates an [AudioRecorderWidget].
  ///
  /// The [field], [stepName], [formStewardStateNotifier], and
  /// [validationTriggerNotifier] parameters are required to manage the form field,
  /// its state, and validation. These parameters must be provided.
  AudioRecorderWidget({
    super.key,
    required BaseFieldWidget fieldParams,
  })  : field = fieldParams.field,
        stepName = fieldParams.stepName,
        formStewardStateNotifier = fieldParams.formStewardStateNotifier,
        validationTriggerNotifier = fieldParams.validationTriggerNotifier;

  /// The model that represents the form field associated with this widget.
  ///
  /// This [FieldModel] provides the necessary information for the field,
  /// such as its name, label, and validation rules.
  final FieldModel field;

  /// The name of the form step that this widget is part of.
  ///
  /// The [stepName] is used to identify which step of the form the widget
  /// belongs to, helping to manage the state and validation specific to that
  /// step.
  final String stepName;

  /// The notifier used to manage the form state for the associated step.
  ///
  /// The [formStewardStateNotifier] is responsible for updating the form's
  /// state, including the values of fields and their validation status.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// The notifier used to trigger validation for this widget.
  ///
  /// The [validationTriggerNotifier] listens for changes in the validation
  /// state and triggers validation checks for the form fields, ensuring that
  /// the form remains in a valid state as the user interacts with it.
  final ValidationTriggerNotifier validationTriggerNotifier;

  @override
  AudioRecorderWidgetState createState() => AudioRecorderWidgetState();
}

class AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  /// An instance of [AudioRecorderHelper] used to manage the audio recording process.
  ///
  /// [_audioRecorderHelper] provides methods to start, stop, and manage
  /// audio recordings, ensuring that the recording process is handled correctly
  /// within the widget.
  final AudioRecorderHelper _audioRecorderHelper = AudioRecorderHelper();

  /// A flag indicating whether the audio recording is currently in progress.
  ///
  /// [_isRecording] is `true` when the user is actively recording audio, and `false`
  /// when recording is stopped or has not yet started.
  bool _isRecording = false;

  /// A flag indicating whether an audio recording has been completed.
  ///
  /// [_hasRecorded] is `true` if an audio recording has been successfully completed
  /// and saved. It is used to manage the state of the widget and determine whether
  /// to display playback controls or allow the user to delete the recording.
  bool _hasRecorded = false;

  /// The recorded audio file.
  ///
  /// [_audioFile] holds the recorded audio as an [XFile] object once the recording
  /// has been completed. It is used to play back the recording or to upload the file
  /// as part of the form submission.
  XFile? _audioFile;

  /// A timer used to track the duration of the recording session.
  ///
  /// [_timer] is used to update the recording time display and to ensure that the
  /// recording is stopped after a certain duration if needed.
  Timer? _timer;

  /// The number of seconds that have been recorded so far.
  ///
  /// [_recordedSeconds] tracks the total duration of the recording in seconds. This
  /// is used to display the recording time to the user.
  int _recordedSeconds = 0;

  /// An instance of the [Player] used for playing back the recorded audio.
  ///
  /// [_player] is responsible for handling the playback of the recorded audio file,
  /// allowing the user to listen to the recording before saving or re-recording.
  Player? _player; // MediaKit Player

  /// A flag indicating whether the recorded audio is currently being played back.
  ///
  /// [_isPlaying] is `true` when the audio is being played and `false` when playback
  /// is paused or stopped.
  bool _isPlaying = false;

  /// The total duration of the recorded audio.
  ///
  /// [_audioDuration] represents the length of the audio file and is used to display
  /// the duration during playback or to provide playback controls.
  Duration _audioDuration = Duration.zero;

  /// The current playback position within the audio file.
  ///
  /// [_currentPosition] tracks the current position of the audio playback, allowing
  /// the user to seek within the recording and providing an accurate progress display.
  Duration _currentPosition = Duration.zero;

  /// A message indicating any errors that occurred during the recording or playback process.
  ///
  /// [_errorMessage] stores error messages related to the recording or playback process,
  /// providing feedback to the user if something goes wrong.
  String? _errorMessage;

  /// Called when this widget is inserted into the widget tree.
  ///
  /// The [initState] method is responsible for initializing state variables
  /// and setting up any necessary listeners or controllers. In this case,
  /// it adds a listener to the [ValidationTriggerNotifier] to handle validation
  /// events and initializes the audio player for playback functionality.
  @override
  void initState() {
    super.initState();
    widget.validationTriggerNotifier.addListener(_onValidationTrigger);
    _initializePlayer();
  }

  /// Called when this widget is removed from the widget tree permanently.
  ///
  /// The [dispose] method is responsible for cleaning up any resources used by
  /// this widget, such as timers, listeners, or controllers. In this case, it
  /// cancels any active timers, disposes of the audio player, and removes the
  /// validation listener to prevent memory leaks.
  @override
  void dispose() {
    _timer?.cancel();
    _player?.dispose();
    widget.validationTriggerNotifier.removeListener(_onValidationTrigger);
    super.dispose();
  }

  /// Initializes the audio player for managing playback of recorded audio files.
  ///
  /// [_initializePlayer] sets up the [Player] instance to handle audio playback
  /// by listening to the position, duration, and completion events of the audio
  /// file. These events are used to update the UI with the current playback state,
  /// such as the current position within the audio file, the total duration, and
  /// whether the playback has completed.
  Future<void> _initializePlayer() async {
    _player = Player();

    // Listen to changes in the playback position and update the UI accordingly.
    _player?.stream.position.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // Listen to changes in the audio duration and update the UI accordingly.
    _player?.stream.duration.listen((duration) {
      setState(() {
        _audioDuration = duration;
      });
    });

    // Listen for the completion of audio playback and reset the playback state.
    _player?.stream.completed.listen((_) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
    });
  }

  /// Loads the recorded audio file into the player for playback.
  ///
  /// The [_loadAudioFile] method checks if there is an existing audio file.
  /// If a file exists, it opens the file using the [Player] instance for playback.
  Future<void> _loadAudioFile() async {
    if (_audioFile != null) {
      await _player?.open(Media(_audioFile!.path));
    }
  }

  /// Handles the playback and pausing of the audio file.
  ///
  /// The [_handlePlayback] method manages the audio playback state. If there is no
  /// audio file, the method returns early. If the audio is not currently playing,
  /// it loads the audio file (if not already loaded) and starts playback.
  /// If the audio is already playing, it pauses the playback. The method updates
  /// the [_isPlaying] state to reflect the current playback status.
  Future<void> _handlePlayback() async {
    if (_audioFile == null) return;

    if (!_isPlaying) {
      await _loadAudioFile();
      _player?.play();
      setState(() {
        _isPlaying = true;
      });
    } else {
      _player?.pause();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  /// Stops the playback of the audio file and resets the playback state.
  ///
  /// The [_stopPlayback] method stops the audio playback and resets the current
  /// playback position to the beginning. It also updates the [_isPlaying] state
  /// to `false` and resets [_currentPosition] to [Duration.zero].
  Future<void> _stopPlayback() async {
    await _player?.stop();
    setState(() {
      _isPlaying = false;
      _currentPosition = Duration.zero;
    });
  }

  /// Starts recording audio if the necessary permissions are granted.
  ///
  /// The [_startRecording] method first checks for necessary permissions using
  /// [_requestPermission]. If permission is granted, it initiates the recording
  /// process via [_audioRecorderHelper]. The recording state is updated to reflect
  /// that recording has started, the recorded seconds counter is reset, and a timer
  /// is started to track the recording duration.
  Future<void> _startRecording() async {
    bool permissionGranted = await _requestPermission(context);
    if (!permissionGranted) return;

    await _audioRecorderHelper.startRecording();
    setState(() {
      _isRecording = true;
      _recordedSeconds = 0;
      _startTimer();
    });
  }

  /// Stops the current recording session and saves the recorded audio file.
  ///
  /// The [_stopRecording] method stops the recording process by cancelling the
  /// ongoing timer and calling [AudioRecorderHelper.stopRecording] to finalize the
  /// recording. If a valid recorded file is returned, it saves the file using
  /// [_saveRecordedFile] and updates the form state with the saved file path.
  /// The method then updates the widget's state to reflect that recording has stopped,
  /// the file has been saved, and the recording session is no longer active.
  Future<void> _stopRecording() async {
    _timer?.cancel();
    final XFile? recordedFile = await _audioRecorderHelper.stopRecording();
    if (recordedFile != null && mounted) {
      final savedFilePath = await _saveRecordedFile(recordedFile);
      if (savedFilePath != null) {
        _updateFormState(savedFilePath);
      }
      setState(() {
        _audioFile = recordedFile;
        _hasRecorded = true;
        _isRecording = false;
      });
    }
  }

  /// Starts a timer to track the duration of the recording session.
  ///
  /// The [_startTimer] method initializes a periodic [Timer] that increments the
  /// [_recordedSeconds] state every second. The timer continues to run until the
  /// recording is stopped. The state is updated on each tick to reflect the current
  /// recording duration.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordedSeconds++;
        });
      }
    });
  }

  /// Formats the recorded duration into a string representation of minutes and seconds.
  ///
  /// The [_formatDuration] method takes the total recorded duration in seconds and
  /// converts it into a string format of `MM:SS` (minutes and seconds). It ensures that
  /// both the minutes and seconds are always displayed with two digits by padding with
  /// leading zeros if necessary.
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Deletes the recorded audio file and resets the related state.
  ///
  /// The [_deleteAudio] method clears the [_audioFile], resets the [_hasRecorded]
  /// flag to false, and sets [_recordedSeconds] back to zero. After deleting the
  /// audio, it triggers validation by updating the [validationTriggerNotifier] with
  /// the current step name, ensuring that the form is revalidated in response to the
  /// deletion.
  void _deleteAudio() {
    setState(() {
      _audioFile = null;
      _hasRecorded = false;
      _recordedSeconds = 0;
    });
    widget.validationTriggerNotifier.value = widget.stepName;
  }

  /// Saves the recorded audio file to the designated directory.
  ///
  /// The [_saveRecordedFile] method saves the provided [recordedFile] to a directory
  /// obtained via [_getSaveDirectory]. It constructs a unique file path based on the
  /// current timestamp and saves the audio file in `.m4a` format. If the file is saved
  /// successfully, the method returns the file path; otherwise, it returns null and logs
  /// an error message.
  Future<String?> _saveRecordedFile(XFile recordedFile) async {
    Directory? directory = await _getSaveDirectory();
    if (directory != null && await directory.exists()) {
      final filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      try {
        await recordedFile.saveTo(filePath);
        return filePath;
      } catch (e) {
        print("Error saving audio file: $e");
      }
    }
    return null;
  }

  /// Retrieves the appropriate directory for saving the recorded audio file.
  ///
  /// The [_getSaveDirectory] method returns a [Directory] where the recorded audio
  /// files should be saved based on the platform:
  /// - On Android, it saves to the `/storage/emulated/0/Music` directory.
  /// - On iOS, it saves to the application documents directory.
  /// - On other platforms, it defaults to the downloads directory.
  /// - On web, it returns null since directory access is not supported.
  Future<Directory?> _getSaveDirectory() async {
    if (kIsWeb) return null;
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Music');
    }
    if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return await getDownloadsDirectory();
  }

  /// Requests storage permission on Android and iOS platforms.
  ///
  /// The [_requestPermission] method checks whether storage permissions have been
  /// granted on Android or iOS. If permissions are granted, it returns true; otherwise,
  /// it requests the necessary permissions. If permission is denied and permanently
  /// denied, it displays a dialog to inform the user. On other platforms, the method
  /// returns true by default since permissions are not required.
  Future<bool> _requestPermission(BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.storage.status;
      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.storage.request();
        if (result.isGranted) {
          return true;
        }
        if (result.isPermanentlyDenied && context.mounted) {
          _showPermissionDialog(context);
        }
      }
    }
    return true;
  }

  /// Displays a dialog to inform the user about the required storage permission.
  ///
  /// The [_showPermissionDialog] method creates an [AlertDialog] that informs the user
  /// that storage permission is required to save the recorded audio file. It provides two
  /// options:
  /// - **Open Settings**: Navigates the user to the app settings to grant the required
  ///   permission.
  /// - **Cancel**: Closes the dialog without taking any action.
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
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  /// Updates the form state with the provided file path.
  ///
  /// The [_updateFormState] method checks if the provided [filePath] is not null or if
  /// the field is not marked as required. If valid, it clears any existing error message.
  /// It then updates the [formStewardStateNotifier] with the current step name, field
  /// name, file path, and validity status, allowing the form to reflect the new state.
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

  /// Listens for validation triggers from the [validationTriggerNotifier].
  ///
  /// The [_onValidationTrigger] method checks if the current validation trigger's value
  /// matches the [stepName] of the widget. If they match, it calls the [_validate] method
  /// to perform validation on the audio recording.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate();
    }
  }

  /// Validates the audio recording based on the required field status.
  ///
  /// The [_validate] method checks if the associated field is marked as required. If the
  /// field is required and no audio file has been recorded, it sets an error message
  /// indicating that the audio is required. If the validation passes, it calls the
  /// [_updateFormState] method with the path of the recorded audio file.
  void _validate() {
    if (widget.field.validation?.required == true && _audioFile == null) {
      setState(() {
        _errorMessage = '${widget.field.label} is required.';
      });
    } else {
      _updateFormState(_audioFile?.path);
    }
  }

  /// Builds the widget's UI.
  ///
  /// The [build] method constructs the UI for the audio recorder, including:
  /// - A label for the audio field.
  /// - An audio container for recording controls and playback.
  /// - An error message if validation fails.
  ///
  /// Returns a [Column] widget that organizes the elements vertically.
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

  /// Builds the label for the audio recording field.
  ///
  /// The [_buildLabel] method returns a [Text] widget with the label "Audio".
  /// It uses the body medium text style from the current theme context.
  ///
  /// Returns a [Text] widget displaying the audio label.
  Widget _buildLabel(BuildContext context) {
    return Text(
      "Audio",
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  /// Constructs the container for the audio recording controls.
  ///
  /// The [_buildAudioContainer] method creates a [Container] widget that includes:
  /// - A grey border and rounded corners.
  /// - Padding for internal spacing.
  /// - A column containing audio controls, and optionally shows recording progress
  ///   or playback slider depending on the current state (recording or playing).
  ///
  /// Returns a [Container] widget that houses the audio controls and additional UI elements.
  Widget _buildAudioContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
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

  /// Constructs the row of audio controls for playback and recording.
  ///
  /// The [_buildAudioControls] method returns a [Row] widget containing:
  /// - A [Text] widget that displays the current recording status or duration.
  /// - Buttons for playback, deletion, and starting/stopping recording.
  ///
  /// Returns a [Row] widget that aligns audio control elements horizontally.
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

  /// Builds the playback button for audio playback controls.
  ///
  /// The [_buildPlaybackButton] method returns an [IconButton] that toggles
  /// between play and pause icons based on the current playback state.
  /// If no audio has been recorded, it returns an empty container.
  ///
  /// Returns an [IconButton] widget for playback control or an empty [Container] if not applicable.
  Widget _buildPlaybackButton() {
    return _hasRecorded
        ? IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.green),
            onPressed: _handlePlayback,
          )
        : Container();
  }

  /// Builds the delete button for removing recorded audio.
  ///
  /// The [_buildDeleteButton] method returns an [IconButton] for deleting
  /// the recorded audio file. If no audio has been recorded, it returns
  /// an empty container.
  ///
  /// Returns an [IconButton] widget for deletion control or an empty [Container] if not applicable.
  Widget _buildDeleteButton() {
    return _hasRecorded
        ? IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteAudio,
          )
        : Container();
  }

  /// Builds the recording button to start or stop audio recording.
  ///
  /// The [_buildRecordingButton] method returns an [IconButton] that toggles
  /// between a stop icon when recording is active and a microphone icon when
  /// idle.
  ///
  /// Returns an [IconButton] widget for recording control.
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

  /// Builds a linear progress indicator to show recording progress.
  ///
  /// The [_buildRecordingProgress] method returns a [LinearProgressIndicator]
  /// widget, indicating that recording is in progress.
  ///
  /// Returns a [Padding] widget containing a [LinearProgressIndicator].
  Widget _buildRecordingProgress() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: LinearProgressIndicator(),
    );
  }

  /// Builds a slider for controlling audio playback position.
  ///
  /// The [_buildPlaybackSlider] method returns a [Slider] that allows users
  /// to seek through the audio track based on the current playback position.
  /// It ensures the slider value is clamped within the valid range.
  ///
  /// Returns a [Slider] widget for playback position control.
  Widget _buildPlaybackSlider() {
    final double max = _audioDuration.inSeconds.toDouble();
    final double value = _currentPosition.inSeconds.toDouble();

    // Ensure the value is within the valid range
    final double clampedValue = value.clamp(0.0, max);

    return Slider(
      value: clampedValue,
      max: max,
      onChanged: (max > 0)
          ? (double value) async {
              final newPosition = Duration(seconds: value.toInt());
              await _player?.seek(newPosition);
              setState(() {
                _currentPosition = newPosition;
              });
            }
          : null,
    );
  }

  /// Builds an error message widget for displaying validation errors.
  ///
  /// The [_buildErrorMessage] method returns a [Text] widget that shows
  /// an error message in red, if present.
  ///
  /// Returns a [Text] widget for displaying the error message.
  Widget _buildErrorMessage() {
    return Text(
      _errorMessage!,
      style: const TextStyle(color: Colors.red),
    );
  }
}
