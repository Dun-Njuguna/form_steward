import 'package:image_picker/image_picker.dart';

/// A class representing the result of a file picking or recording operation.
///
/// [file] contains the picked or recorded file if the operation was successful.
/// [error] contains the error code if there was an issue during the operation.
class StewardFilePickerResult {
  final XFile? file;
  final String? error;

  StewardFilePickerResult({this.file, this.error});
}
