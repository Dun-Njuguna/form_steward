import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class AudioRecorderHelper {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordPath;
  bool _isRecording = false;

  /// Initializes the audio recorder helper.
  AudioRecorderHelper();

  /// Starts recording audio.
  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      _recordPath = await _getRecordPath();
      await _audioRecorder.start(
        const RecordConfig(),
        path: _recordPath!
      );
      _isRecording = true;
    } else {
      // Handle permission not granted
    }
  }

  /// Stops recording audio and returns the path of the recorded file.
  Future<XFile?> stopRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      return path != null ? XFile(path) : null;
    }
    return null;
  }

  /// Resets the recording process, stopping any ongoing recording.
  Future<void> resetRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      _isRecording = false;
    }
    _recordPath = await _getRecordPath();
  }

  /// Checks if the recording is currently active.
  bool isRecording() => _isRecording;

  /// Gets a unique path for recording or saving files across all platforms.
  Future<String> _getRecordPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${directory.path}/recording_$timestamp.m4a';
  }
}
