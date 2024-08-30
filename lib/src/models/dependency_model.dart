/// A model representing a dependency between form fields.
///
/// The [DependencyModel] class encapsulates the information needed to manage
/// dependencies between fields. It includes the name of the dependent field,
/// the field it depends on, and optionally, a URL for fetching dynamic options.
class DependencyModel {
  /// The name of the dependent field.
  ///
  /// The [dependentField] is the field that relies on the value of another field
  /// for its options or visibility.
  final String dependentField;

  /// The name of the field that the dependent field relies on.
  ///
  /// The [parentField] is the field whose value will influence the options or
  /// behavior of the dependent field.
  final String parentField;

  /// URL to fetch options dynamically for the dependent field.
  ///
  /// The [fetchOptionsUrl] is used if the dependent field requires dynamic options
  /// that are fetched from a remote source. It may include placeholders for parameters
  /// (e.g., `{parentValue}`).
  final String? fetchOptionsUrl;

  /// Creates a new instance of the [DependencyModel] class.
  ///
  /// - [dependentField]: The name of the field that depends on another field.
  /// - [parentField]: The name of the field that influences the dependent field.
  /// - [fetchOptionsUrl]: URL for fetching dynamic options, if applicable.
  DependencyModel({
    required this.dependentField,
    required this.parentField,
    this.fetchOptionsUrl,
  });

  /// Creates a new [DependencyModel] instance from a JSON map.
  ///
  /// This factory constructor is used to deserialize a [DependencyModel] from a
  /// JSON object. It extracts the dependency information from the JSON and uses
  /// it to create a [DependencyModel] instance.
  ///
  /// - [json]: A map representing the JSON object with keys for `dependentField`,
  /// `parentField`, and `fetchOptionsUrl`.
  ///
  /// Returns a new [DependencyModel] instance populated with the values from the JSON map.
  factory DependencyModel.fromJson(Map<String, dynamic> json) {
    return DependencyModel(
      dependentField: json['dependentField'],
      parentField: json['parentField'],
      fetchOptionsUrl: json['fetchOptionsUrl'],
    );
  }
}
