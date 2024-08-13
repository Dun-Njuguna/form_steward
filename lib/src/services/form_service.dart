import '../models/form_step_model.dart';
import '../utils/json_parser.dart';

/// A service for loading form steps from JSON data.
///
/// The [FormService] class provides functionality to parse form step data from
/// a JSON string. It converts the JSON data into a list of [FormStepModel]
/// instances, which represent the individual steps and fields of a multi-step
/// form.
class FormService {
  /// Parses form step data from a JSON string.
  ///
  /// This method uses the [JsonParser] utility to convert a JSON string into
  /// a list of [FormStepModel] instances. Each [FormStepModel] represents a
  /// step in the form, including its title and associated fields.
  ///
  /// - Parameter jsonString: A JSON-encoded string representing the form steps
  /// and fields.
  ///
  /// - Returns: A [List<FormStepModel>] containing the parsed form steps.
  ///
  /// - Throws: An exception if the JSON string is invalid or cannot be parsed
  /// properly.
  List<FormStepModel> loadFormFromJson(String jsonString) {
    return JsonParser.parseForm(jsonString);
  }
}
