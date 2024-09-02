import 'dart:io';
import 'package:flutter/material.dart';
import 'package:form_steward/src/utils/audio_recording_controls.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AudioRecorderWidget extends StatefulWidget {
  final Function(String?) onAudioSaved;

  const AudioRecorderWidget({super.key, required this.onAudioSaved});

  @override
  AudioRecorderWidgetState createState() => AudioRecorderWidgetState();
}

class AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  late AudioRecordingControls _audioRecordingControls;

  @override
  void initState() {
    super.initState();
    _audioRecordingControls = AudioRecordingControls(
      onAudioRecorded: (XFile? recordedFile) async {
        if (recordedFile != null) {
          final savedFilePath = await _saveRecordedFile(context, recordedFile);
          widget.onAudioSaved(savedFilePath);
        }
      },
    );
  }

  Future<String?> _saveRecordedFile(BuildContext context, XFile recordedFile) async {
    if (context.mounted && await _requestPermission(context)) {
      Directory? directory = await _getSaveDirectory();
      if (directory != null && await directory.exists()) {
        final filePath =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

        try {
          await recordedFile.saveTo(filePath);
          print("Audio saved successfully at: $filePath");
          return filePath;
        } catch (e) {
          print("Error saving audio file: $e");
          return null;
        }
      } else {
        print("Error: Could not access the directory.");
        return null;
      }
    } else {
      print("Permission denied.");
      return null;
    }
  }

  Future<Directory?> _getSaveDirectory() async {
    if (kIsWeb) {
      // For web, files are handled differently, use in-memory storage or IndexedDB
      return null; // Modify this based on your web storage handling approach.
    } else if (Platform.isAndroid) {
      return Directory(
          '/storage/emulated/0/Music'); // Music directory on Android
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory(); // Documents directory on iOS
    } else if (Platform.isLinux || Platform.isWindows) {
      return await getDownloadsDirectory(); // Downloads directory on Desktop platforms
    } else {
      return await getApplicationDocumentsDirectory(); // Fallback for other platforms
    }
  }

Future<bool> _requestPermission(BuildContext context) async {
  if (Platform.isAndroid || Platform.isIOS) {
    var status = await Permission.storage.status;

    // Check if permission is already granted
    if (status.isGranted) {
      return true;
    }

    // Request permission if not granted
    if (status.isDenied) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else if (result.isPermanentlyDenied) {
        // Handle permanently denied permissions
        if (context.mounted) {
          _showPermissionDialog(context);
        }
        return false;
      }
    }
  }

  return true; // Assume permissions are granted for non-mobile platforms or if not applicable
}

void _showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Storage permission is required to save recorded audio. Please enable it in the app settings.",
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
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _audioRecordingControls,
      ],
    );
  }
}
