import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/src/widgets/form_builder.dart';
import 'package:form_steward/src/models/form_step_model.dart';
import 'package:form_steward/src/models/field_model.dart';
import 'package:form_steward/src/models/validation_model.dart';
import 'package:form_steward/src/widgets/form_field_widget.dart';

void main() {
  formBuilderTests();
}

void formBuilderTests() {
  testWidgets('FormBuilder builds form with multiple steps and fields',
      (WidgetTester tester) async {
    // Create sample form steps and fields
    final steps = [
      FormStepModel(
        title: 'Personal Information',
        fields: [
          FieldModel(
            type: 'text',
            label: 'First Name',
            name: 'first_name',
            validation: ValidationModel(required: true, minLength: 2),
          ),
          FieldModel(
            type: 'text',
            label: 'Last Name',
            name: 'last_name',
            validation: ValidationModel(required: true, minLength: 2),
          ),
        ],
      ),
      FormStepModel(
        title: 'Contact Information',
        fields: [
          FieldModel(
            type: 'number',
            label: 'Phone Number',
            name: 'phone_number',
            validation: ValidationModel(required: true, minLength: 10),
          ),
        ],
      ),
    ];

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FormBuilder(steps: steps),
        ),
      ),
    );

    // Check for the presence of the form fields
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is FormFieldWidget &&
              (widget.field.label == 'First Name' ||
                  widget.field.label == 'Last Name' ||
                  widget.field.label == 'Phone Number'),
        ),
        findsNWidgets(3)); // Expect exactly 3 FormFieldWidget instances

    // Check the properties of the form fields
    expect(find.widgetWithText(FormFieldWidget, 'First Name'), findsOneWidget);
    expect(find.widgetWithText(FormFieldWidget, 'Last Name'), findsOneWidget);
    expect(
        find.widgetWithText(FormFieldWidget, 'Phone Number'), findsOneWidget);
  });

  testWidgets('FormBuilder renders empty form when no steps are provided',
      (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FormBuilder(steps: []),
        ),
      ),
    );

    // Assert
    // Check that no form fields or steps are rendered
    expect(find.byType(FormFieldWidget), findsNothing);
  });
}
