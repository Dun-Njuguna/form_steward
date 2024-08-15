import 'package:flutter/material.dart';
import '../models/field_model.dart';

/// A widget that builds a form field based on the specified field model.
///
/// The [FormFieldWidget] class creates a form field UI component based on the
/// type and validation rules specified in a [FieldModel] instance. It supports
/// different field types such as text and number, applying appropriate validation
/// logic for each type.
class FormFieldWidget extends StatelessWidget {
  /// The model that defines the properties and validation rules for the form field.
  ///
  /// The [field] parameter is a [FieldModel] instance that includes the type, label,
  /// and validation rules for the form field. It determines how the form field is
  /// rendered and validated.
  final FieldModel field;

  /// Creates a new instance of the [FormFieldWidget] class.
  ///
  /// The [field] parameter is required and should contain the model that defines
  /// the form field's properties and validation rules.
  ///
  /// - Parameter field: The model defining the form field properties and validation rules.
  const FormFieldWidget({
    super.key,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(labelText: field.label),
          validator: (value) {
            if (field.validation?.required == true && value!.isEmpty) {
              return '${field.label} is required';
            }
            if (field.validation?.minLength != null &&
                value!.length < field.validation!.minLength!) {
              return '${field.label} must be at least ${field.validation!.minLength} characters';
            }
            return null;
          },
        );
      case 'number':
        return TextFormField(
          decoration: InputDecoration(labelText: field.label),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (field.validation?.required == true && value!.isEmpty) {
              return '${field.label} is required';
            }
            return null;
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
