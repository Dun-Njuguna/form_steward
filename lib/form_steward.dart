/// A library for creating and managing dynamic forms.
///
/// The [form_steward] library provides components and utilities for building
/// and managing dynamic forms in a Flutter application. It includes models,
/// widgets, controllers, services, and utilities to facilitate the creation
/// of forms that can be dynamically generated based on configuration data.
///
/// The library exports:
///
/// - **Models:**
///   - [FormStepModel]: Defines the structure of a form step including its title and fields.
///   - [FieldModel]: Represents a form field with its type, label, name, and validation rules.
///   - [ValidationModel]: Specifies validation rules for form fields such as required status and length constraints.
///
/// - **Widgets:**
///   - [StepperWidget]: A custom stepper widget that displays steps with custom titles and handles navigation between steps.
///   - [FormFieldWidget]: A widget that builds form fields based on the specified [FieldModel] and its validation rules.
///   - [FormBuilder]: A widget that dynamically generates a form based on a list of [FormStepModel] instances.
///
/// - **Utils:**
///   - [JsonParser]: Provides functionality to parse form configuration from JSON strings into [FormStepModel] instances.
///   - [Validators]: Contains static methods for common form validation tasks such as checking required fields and minimum length.
///
/// - **Controllers:**
///   - [FormController]: Manages form state, including validation and saving form data.
///   - [StepController]: Handles step navigation within a stepper, including moving to the next and previous steps and checking if the current step is first or last.
///
/// - **Services:**
///   - [FormService]: Provides functionality to load form configuration from JSON strings and parse it into [FormStepModel] instances.
///   - [ApiService]: Handles fetching form configuration from a remote server using HTTP requests.
library form_steward;

// Exporting models
export 'src/models/form_step_model.dart';
export 'src/models/field_model.dart';
export 'src/models/validation_model.dart';

// Exporting widgets
export 'src/widgets/stepper_widget.dart';
export 'src/widgets/form_field_widget.dart';
export 'src/widgets/form_builder.dart';

// Exporting utils
export 'src/utils/json_parser.dart';
export 'src/utils/validators.dart';

// Exporting controllers
export 'src/controllers/form_controller.dart';
export 'src/controllers/step_controller.dart';

// Exporting services
export 'src/services/form_service.dart';
export 'src/services/api_service.dart';
