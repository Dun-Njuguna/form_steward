
---

# form_steward  Documentation

`form_steward` is a dynamic form builder package that allows you to create and manage multi-step forms in Flutter based on JSON configuration. It supports custom form validation, stepper navigation, and flexible form field types, making it a powerful tool for building complex forms with ease.

## Features

- **Dynamic Form Building**: Create forms dynamically from JSON configurations.
- **Multi-step Navigation**: Support for multi-step forms with customizable step titles and navigation controls.
- **Custom Form Validation**: Define validation rules in the JSON configuration for each field.
- **Extensible Form Fields**: Supports a variety of form field types, including text, number, and more.

## Getting Started

To start using the `form_steward` package, ensure you have the following prerequisites:

- Flutter SDK installed.
- Basic knowledge of Flutter and JSON.

Add `form_steward` to your `pubspec.yaml`:

```yaml
dependencies:
  form_steward: ^0.0.1
```

Then, run `flutter pub get` to install the package.

## Usage

Below is an example of how to use `form_steward` in your Flutter project:

```dart
import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

class MyCustomStepperWidget extends StepperWidget {
  MyCustomStepperWidget({
    super.key,
    required super.currentStep,
    required super.stepperType,
    required super.formStewardNotifier,
    required super.formStewardStateNotifier, 
    required super.formSteps,
  });

  @override
  void onNextStep({required Map<String, dynamic>? previousStepData}) {
    print("previous step data...... ${previousStepData?.entries}");
  }

  @override
  void onPreviousStep() {
    // Custom implementation for the previous step
  }

  @override
  void onSubmit({required Map<String, Map<String, dynamic>> formData}) {
    print("form data.....  ${formData.entries}");
  }
}

class DynamicFormPage extends StatefulWidget {
  const DynamicFormPage({super.key});

  @override
  DynamicFormPageState createState() => DynamicFormPageState();
}

class DynamicFormPageState extends State<DynamicFormPage> {
  List<FormStepModel>? _formSteps;
  late StepController _stepController;

  @override
  void initState() {
    super.initState();
    _stepController = StepController();
    _loadForm();
  }

  void _loadForm() async {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/form_config.json');
    setState(() {
      _formSteps = FormService().loadFormFromJson(jsonString);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_formSteps == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final validationTriggerNotifier = ValidationTriggerNotifier();
    final formStewardStateNotifier = FormStewardStateNotifier();
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(12),
      child: _formSteps != null
          ? MyCustomStepperWidget(
              stepperType: StewardStepperType.vertical,
              formStewardNotifier: validationTriggerNotifier,
              formStewardStateNotifier: formStewardStateNotifier,
              formSteps: _formSteps!,
              currentStep: _stepController.currentStep,
            )
          : const Text("Steps not available"),
      ),
    );
  }
}

```

## Example JSON Configuration

The following JSON configuration defines a simple two-step form with fields for personal and contact information. For detailed descriptions of field types, refer to the [field documentation](guides/fields.md).

```json
{
  "formName": "User Information Form",
  "formConfig": {
    "defaultValues": {
      "vehicle_make": 1,
      "vehicle_model": 1
    }
  },
  "steps": [
    {
      "id": 1,
      "title": "Personal Information",
      "name": "personal_information",
      "fields": [
        {
          "id": 1,
          "type": "text",
          "label": "First Name",
          "name": "first_name",
          "validation": {
            "required": true,
            "minLength": 2,
            "maxLength": 50
          },
          "value": "John" 
        },
        {
          "id": 2,
          "type": "text",
          "label": "Last Name",
          "name": "last_name",
          "validation": {
            "required": true,
            "minLength": 2,
            "maxLength": 50
          },
          "value": "Doe"
        },
        {
          "id": 3,
          "type": "date",
          "label": "Date of Birth",
          "name": "date_of_birth",
          "validation": {
            "required": true
          },
          "value": "1990-01-01"
        },
        {
          "id": 4,
          "type": "radio",
          "label": "Gender",
          "name": "gender",
          "validation": {
            "required": true
          },
          "options": [
            {"id": 1, "value": "Male"},
            {"id": 2, "value": "Female"},
            {"id": 3, "value": "Other"}
          ],
          "value": 1
        }
      ]
    }
  ],
  "dependencies": [
    {
      "fieldId": 9,
      "dependsOnFieldId": 8,
      "stepId": 3
    }
  ]
}

```

## Dynamic Options and URL Parameters

For fields that require fetching options dynamically, you can specify a URL with placeholders for query parameters. For details, refer to the [field documentation](guides/fields.md).

### Example of Dynamic URL with Parameters

```json
{
  "id": 7,
  "type": "select",
  "label": "Vehicle Model",
  "name": "vehicle_model",
  "dependsOnFieldId": 6,
  "validation": {
    "required": true
  },
  "multi_select": false,
  "fetchOptionsUrl": "https://example.com/api/vehicle-models?makeId={makeId}",
  "value": 1
}
```

## Additional Information

For more details on how to use `form_steward`, including advanced features and customization options, please refer to the documentation in the `/docs` directory. Contributions, issues, and feature requests are welcome.

---