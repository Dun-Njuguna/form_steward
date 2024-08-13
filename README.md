## form_steward
form_steward is a dynamic form builder package that allows you to create and manage multi-step forms in Flutter based on JSON configuration. It supports custom form validation, stepper navigation, and flexible form field types, making it a powerful tool for building complex forms with ease.

## Features
    - Dynamic Form Building: Create forms dynamically from JSON configurations.
    - Multi-step Navigation: Support for multi-step forms with customizable step titles and navigation controls.
    - Custom Form Validation: Define validation rules in the JSON configuration for each field.
    - Extensible Form Fields: Supports a variety of form field types, including text, number, and more.
G
## Getting Started
To start using the form_steward package, ensure you have the following prerequisites:
    - Flutter SDK installed.
    - Basic knowledge of Flutter and JSON.

Add form_steward to your pubspec.yaml:
 dependencies:
  form_steward: ^0.0.1
  
Then, run flutter pub get to install the package.

## Usage

Below is a basic example of how to use form_steward in your Flutter project:

    import 'package:flutter/material.dart';
    import 'package:form_steward/form_steward.dart';

    class DynamicFormPage extends StatefulWidget {
    const DynamicFormPage({super.key});

    @override
    DynamicFormPageState createState() => DynamicFormPageState();
    }

    class DynamicFormPageState extends State<DynamicFormPage> {
    List<FormStepModel>? _formSteps;
    late FormController _formController;
    late StepController _stepController;

    @override
    void initState() {
        super.initState();
        _formController = FormController();
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
      appBar: AppBar(
        title: const Text('Dynamic Form'),
      ),
      body: Form(
        key: _formController.formKey,
        child: Column(
          children: [
            Expanded(
              child: StepperWidget(
                steps: _formSteps!.map((step) {
                  return FormBuilder(steps: [step]);
                }).toList(),
                titles: _formSteps!
                    .map((step) => step.title)
                    .toList(), // Pass the titles here
                currentStep: _stepController.currentStep,
                onStepContinue: () {
                  if (_stepController.isLastStep(_formSteps!.length)) {
                    if (_formController.validateForm()) {
                      _formController.saveForm();
                      // Handle form submission here
                    }
                  } else {
                    _stepController.nextStep();
                    setState(() {});
                  }
                },
                onStepCancel: () {
                  _stepController.previousStep();
                  setState(() {});
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formController.validateForm()) {
                  _formController.saveForm();
                  // Handle form submission here
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}


## Example JSON Configuration

The following JSON configuration defines a simple two-step form with fields for personal and contact information:

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

Additional Information

For more details on how to use form_steward, including advanced features and customization options, please refer to the documentation in the /docs directory. Contributions, issues, and feature requests are welcome.
