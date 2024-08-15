/// A library for creating and managing dynamic forms.
///
/// The [form_steward] library offers a comprehensive suite of tools for building
/// and managing dynamic forms within a Flutter application. It provides various
/// components and utilities to facilitate the creation of forms that are adaptable
/// based on configuration data.
///
/// The library is organized into several categories:
///
/// - **Models:** Define the structure and rules for form data.
///   - [FormStepModel]: Represents a single step in a multi-step form, including its title and associated fields.
///   - [FieldModel]: Describes a form field, including its type (e.g., text, checkbox), label, name, and validation rules.
///   - [ValidationModel]: Contains validation rules for form fields, such as whether a field is required and length constraints.
///
/// - **Widgets:** Build and display various parts of the form.
///   - [StepperWidget]: A customizable stepper widget for managing and displaying multiple steps in a form. Allows navigation between steps with custom titles and controls.
///   - [FormFieldWidget]: A widget that dynamically builds form fields based on the provided [FieldModel] and applies associated validation rules.
///   - [FormBuilder]: Generates a complete form based on a list of [FormStepModel] instances, allowing for dynamic form creation based on configuration.
///
/// - **Utils:** Provide helper functions for form processing and validation.
///   - [JsonParser]: Parses form configuration data from JSON strings into [FormStepModel] instances, enabling dynamic form creation from JSON.
///   - [Validators]: Includes static methods for common form validation tasks, such as checking for required fields and enforcing minimum length constraints.
///
/// - **Enums:** Defines various types of steppers to customize form navigation.
///   - [StewardStepperType]: Specifies different stepper layouts, allowing customization of how steps are displayed and navigated within the form.
///     - [vertical]: Displays the steps in a vertical layout. Navigation controls are located at the bottom of the stepper.
///     - [horizontal]: Shows steps in a horizontal layout. Navigation controls are positioned alongside the content.
///     - [tablet]: Optimized for tablet screens, displaying the list of steps on the left and the content of the active step on the right.
///
/// - **Controllers:** Manage the state and navigation of the form.
///   - [FormController]: Controls the form's state, including validation and saving data. Manages interactions between form fields and validation rules.
///   - [StepController]: Manages step navigation within a stepper, including advancing to the next step, going back to the previous step, and checking the current step's position.
///
/// - **Services:** Provide functionality for loading and fetching form configurations.
///   - [FormService]: Loads form configurations from JSON strings and parses them into [FormStepModel] instances, facilitating dynamic form creation.
///   - [ApiService]: Fetches form configurations from a remote server via HTTP requests, enabling integration with backend systems for form data retrieval.
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

// Exporting enums
export 'src/utils/steward_stepper_type.dart';

// Exporting controllers
export 'src/controllers/form_controller.dart';
export 'src/controllers/step_controller.dart';

// Exporting services
export 'src/services/form_service.dart';
export 'src/services/api_service.dart';
