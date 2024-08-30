class OptionModel {
  final int id;
  final String value;

  OptionModel({
    required this.id,
    required this.value,
  });

  // Factory method to create an OptionModel from a map
  factory OptionModel.fromMap(Map<String, dynamic> map) {
    return OptionModel(
      id: map['id'] as int,
      value: map['value'] as String,
    );
  }

  // Convert OptionModel to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
    };
  }
}
