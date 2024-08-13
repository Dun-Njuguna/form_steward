import 'dart:convert';
import '../models/form_step_model.dart';

/// A utility for parsing JSON data into form step models.
///
/// The [JsonParser] class provides functionality to convert a JSON-encoded string
/// into a list of [FormStepModel] instances. It processes the JSON data to extract
/// and construct the form steps and their associated fields.
class JsonParser {
  /// Parses a JSON string into a list of form step models.
  ///
  /// This static method decodes the provided [jsonString] and extracts the form
  /// step data. It converts the JSON data into a list of [FormStepModel] instances,
  /// each representing a step in the multi-step form.
  ///
  /// - Parameter jsonString: A JSON-encoded string representing the form steps and
  /// fields.
  ///
  /// - Returns: A [List<FormStepModel>] containing the parsed form steps.
  ///
  /// - Throws: [FormatException] if the JSON string is invalid or cannot be decoded.
  static List<FormStepModel> parseForm(String jsonString) {
    final parsed = json.decode(jsonString);
    return (parsed['steps'] as List)
        .map((stepJson) => FormStepModel.fromJson(stepJson))
        .toList();
  }
}
