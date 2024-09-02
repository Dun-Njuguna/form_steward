import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'audio_recorder_helper.dart';

class AudioRecordingControls extends StatefulWidget {
  final Function(XFile?) onAudioRecorded;

  const AudioRecordingControls({required this.onAudioRecorded, super.key});

  @override
  AudioRecordingControlsState createState() => AudioRecordingControlsState();
}

class AudioRecordingControlsState extends State<AudioRecordingControls> {
  final AudioRecorderHelper _audioRecorderHelper = AudioRecorderHelper();
  bool _isRecording = false;

  /// Starts or stops the recording based on the current state.
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final XFile? recordedFile = await _audioRecorderHelper.stopRecording();
      widget.onAudioRecorded(recordedFile);
    } else {
      await _audioRecorderHelper.startRecording();
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  /// Resets the recording process.
  Future<void> _resetRecording() async {
    await _audioRecorderHelper.resetRecording();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(_isRecording ? Icons.stop : Icons.mic,
              color: _isRecording ? Colors.red : Colors.green),
          onPressed: _toggleRecording,
          tooltip: _isRecording ? 'Stop Recording' : 'Start Recording',
        ),
        const SizedBox(
          width: 40,
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.blue),
          onPressed: _resetRecording,
          tooltip: 'Reset Recording',
        ),
      ],
    );
  }
}
