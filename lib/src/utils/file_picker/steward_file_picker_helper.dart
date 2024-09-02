import 'package:form_steward/src/models/file_result_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class FilePickerHelper {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery or captures a new image, handling platform-specific logic.
  Future<StewardFilePickerResult> pickOrCaptureImage({bool capture = false}) async {
    XFile? file;
    if (kIsWeb) {
      file = await _picker.pickImage(source: ImageSource.gallery);
    } else {
      file = await _picker.pickImage(
        source: capture ? ImageSource.camera : ImageSource.gallery,
      );
    }
    return StewardFilePickerResult(file: file, error: file == null ? 'NO_FILE_SELECTED' : null);
  }

  /// Picks a video from the gallery or captures a new video, handling platform-specific logic.
  Future<StewardFilePickerResult> pickOrCaptureVideo({bool capture = false}) async {
    XFile? file;
    if (kIsWeb) {
      file = await _picker.pickVideo(source: ImageSource.gallery);
    } else {
      file = await _picker.pickVideo(
        source: capture ? ImageSource.camera : ImageSource.gallery,
      );
    }
    return StewardFilePickerResult(file: file, error: file == null ? 'NO_FILE_SELECTED' : null);
  }

  /// Picks an audio file or records new audio, handling platform-specific logic.
  Future<StewardFilePickerResult> pickAudio() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      return result != null && result.files.isNotEmpty
          ? StewardFilePickerResult(file: XFile(result.files.single.path!))
          : StewardFilePickerResult(error: 'NO_FILE_SELECTED');
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      return result != null && result.files.isNotEmpty
          ? StewardFilePickerResult(file: XFile(result.files.single.path!))
          : StewardFilePickerResult(error: 'NO_FILE_SELECTED');
    }
  }

  /// Picks a generic file, handling platform-specific logic.
  Future<StewardFilePickerResult> pickFile() async {
    if (kIsWeb) {
      return StewardFilePickerResult(error: 'NOT_SUPPORTED_ON_WEB');
    } else {
      final result = await FilePicker.platform.pickFiles();
      return result != null && result.files.isNotEmpty
          ? StewardFilePickerResult(file: XFile(result.files.single.path!))
          : StewardFilePickerResult(error: 'NO_FILE_SELECTED');
    }
  }

  /// Reads file bytes for web (web only).
  Future<Uint8List?> readFileBytes(XFile file) async {
    if (kIsWeb) {
      return await file.readAsBytes();
    }
    return null;
  }
}
