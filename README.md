
---

# form_steward Documentation

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
  const MyCustomStepperWidget({
    super.key,
    required super.steps,
    required super.titles,
    required super.currentStep,
    required super.stepperType,
  });

  @override
  void onNextStep() {
    // Custom implementation for the next step
  }

  @override
  void onPreviousStep() {
    // Custom implementation for the previous step
  }

  @override
  void onSubmit() {
    // Custom implementation for submission
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

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(12),
        child: MyCustomStepperWidget(
          stepperType: StewardStepperType.vertical,
          steps: _formSteps!.map((step) {
            return FormBuilder(steps: [step]);
          }).toList(),
          titles: _formSteps!.map((step) => step.title).toList(),
          currentStep: _stepController.currentStep,
        ),
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
  "steps": [
    {
      "title": "Personal Information",
      "fields": [
        {
          "type": "text",
          "label": "First Name",
          "name": "first_name",
          "validation": {
            "required": true,
            "minLength": 2
          }
        },
        {
          "type": "text",
          "label": "Last Name",
          "name": "last_name",
          "validation": {
            "required": true,
            "minLength": 2
          }
        }
      ]
    },
    {
      "title": "Contact Information",
      "fields": [
        {
          "type": "number",
          "label": "Phone Number",
          "name": "phone_number",
          "validation": {
            "required": true,
            "minLength": 10
          }
        }
      ]
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