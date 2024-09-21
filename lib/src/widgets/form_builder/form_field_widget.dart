import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/option_model.dart';
import 'package:form_steward/src/widgets/fields/steward_audio_recorder_field.dart';
import 'package:form_steward/src/widgets/fields/steward_email_field.dart';
import 'package:form_steward/src/widgets/fields/steward_file_picker_field.dart';
import 'package:form_steward/src/widgets/fields/steward_mobile_field.dart';
import 'package:form_steward/src/widgets/fields/steward_number_field.dart';
import 'package:form_steward/src/widgets/fields/steward_text_field.dart';
import 'package:form_steward/src/widgets/fields/steward_select_field.dart';
import 'package:form_steward/src/widgets/fields/steward_checkbox_field.dart';
import 'package:form_steward/src/widgets/fields/steward_radio_field.dart';
import 'package:form_steward/src/widgets/fields/steward_date_field.dart';
import 'package:form_steward/src/widgets/fields/steward_image_picker_field.dart';
import 'package:form_steward/src/widgets/fields/steward_video_picker_field.dart';

/// Abstract base class for all field widgets.
///
/// This class is meant to be extended by specific field widgets, providing
/// common properties such as `stepName`, `field`, `validationTriggerNotifier`,
/// `formStewardStateNotifier`, and `fetchOptions`.
abstract class BaseFieldWidget extends StatelessWidget {
  /// The name of the form step that this field belongs to.
  final String stepName;

  /// The model representing the field, containing its type, label, and other metadata.
  final FieldModel field;

  /// Notifier that triggers validation for the field when necessary.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// Notifier that tracks and updates the state of the form fields.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// Function to fetch options for fields that require a list of selectable items.
  final Future<List<OptionModel>> Function() fetchOptions;
  
  /// Creates an instance of [BaseFieldWidget].
  ///
  /// All parameters are required and should be passed down from the parent widget.
  const BaseFieldWidget({
    super.key,
    required this.stepName,
    required this.field,
    required this.validationTriggerNotifier,
    required this.formStewardStateNotifier,
    required this.fetchOptions,
  });
}

/// Factory class for creating field widgets.
///
/// This class contains a mapping of field types to their corresponding widget
/// constructors. It provides a method to create a widget based on the field type.
class FieldWidgetFactory {
  /// A mapping of field types to their corresponding widget constructors.
  static final Map<String, Widget Function(BaseFieldWidget)> _fieldWidgets = {
    'text': (params) => StewardTextFieldWidget(fieldParams: params),
    'textarea': (params) => StewardTextFieldWidget(fieldParams:params),
    'number': (params) => StewardNumberField(fieldParams:params),
    'email': (params) => StewardEmailField(fieldParams:params),
    'tel': (params) => StewardMobileField(fieldParams:params),
    'radio': (params) => StewardRadioField(fieldParams:params),
    'checkbox': (params) => StewardCheckboxField(fieldParams:params),
    'date': (params) => StewardDateField(fieldParams:params),
    'select': (params) => StewardSelectField(fieldParams:params),
    'file': (params) => StewardFilePickerField(fieldParams:params),
    'image': (params) => StewardImagePickerField(fieldParams:params),
    'audio': (params) => AudioRecorderWidget(fieldParams:params),
    'video': (params) => StewardVideoPickerField(fieldParams:params),
  };

  /// Creates a widget based on the provided field parameters.
  ///
  /// The widget is selected from the `_fieldWidgets` map based on the field type.
  /// If the field type is not found, an empty [SizedBox] is returned.
  ///
  /// - [params]: The parameters required to create the field widget.
  static Widget createFieldWidget(BaseFieldWidget params) {
    final widgetBuilder = _fieldWidgets[params.field.type];
    if (widgetBuilder != null) {
      return widgetBuilder(params);
    }
    return const SizedBox(height: 0,);
  }
}

/// A sample function to fetch options for selectable fields.
///
/// This function returns an empty list of options as a placeholder.
/// In a real application, this function would likely make a network request
/// or fetch data from a database.
Future<List<OptionModel>> fetchOptions() {
  return Future.value([]);
}

/// Main widget for rendering a form field.
///
/// This widget dynamically creates the appropriate field widget based on the
/// field type, using the [FieldWidgetFactory]. It is responsible for passing
/// the necessary parameters to the field widget, such as `stepName`, `field`,
/// `validationTriggerNotifier`, and `formStewardStateNotifier`.
class FormFieldWidget extends StatelessWidget {
  /// The name of the form step that this field belongs to.
  final String stepName;

  /// The model representing the field, containing its type, label, and other metadata.
  final FieldModel field;

  /// Notifier that triggers validation for the field when necessary.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// Notifier that tracks and updates the state of the form fields.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// Creates an instance of [FormFieldWidget].
  ///
  /// All parameters are required and should be passed down from the parent widget.
  const FormFieldWidget({
    super.key,
    required this.stepName,
    required this.field,
    required this.validationTriggerNotifier,
    required this.formStewardStateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return FieldWidgetFactory.createFieldWidget(
      _FieldParams(
        stepName: stepName,
        field: field,
        validationTriggerNotifier: validationTriggerNotifier,
        formStewardStateNotifier: formStewardStateNotifier,
        fetchOptions: fetchOptions,
      ),
    );
  }
}

/// Private class to encapsulate field parameters.
///
/// This class extends [BaseFieldWidget] and is used to pass the necessary
/// parameters to the field widgets created by the [FieldWidgetFactory].
class _FieldParams extends BaseFieldWidget {
  /// Creates an instance of [_FieldParams].
  ///
  /// All parameters are required and should be passed down from the parent widget.
  const _FieldParams({
    required super.stepName,
    required super.field,
    required super.validationTriggerNotifier,
    required super.formStewardStateNotifier,
    required super.fetchOptions,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
