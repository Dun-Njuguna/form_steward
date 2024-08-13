## 0.0.1

The initial release of the `form_steward` package marks the introduction of a flexible dynamic form builder for Flutter applications. This version focuses on enabling developers to create multi-step forms dynamically from JSON configurations, simplifying the process of building complex forms.

### Key Features:
- **Dynamic Form Building:** Forms are generated on the fly based on JSON configuration files, allowing for rapid prototyping and easy adjustments without modifying the code.
- **Multi-Step Form Support:** The package supports the creation of multi-step forms with a `StepperWidget`, allowing users to navigate through different sections of the form seamlessly.
- **Custom Form Validation:** Developers can define validation rules directly in the JSON configuration, ensuring that each form field adheres to specific criteria such as required fields, minimum length, and more.
- **Extensible Form Fields:** The package includes support for various form field types (e.g., text, number), with the ability to easily extend and add new field types as needed.
- **Controllers for State Management:** `FormController` and `StepController` are included to manage form state and step navigation, making it easy to handle form submission and validation.

### Use Cases:
- **Surveys and Questionnaires:** Quickly build and deploy forms for collecting user feedback.
- **Registration Forms:** Create multi-step registration forms with field validation.
- **Data Collection:** Ideal for applications that require dynamic data input, where the form structure may change frequently based on user or business needs.

This initial release sets the foundation for a robust form management system in Flutter, with plans for future enhancements including more field types, custom styling options, and integration with backend services for dynamic form fetching.