import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/form_steward.dart';

void formFieldWidgetTests() {
  testWidgets('FormFieldWidget displays text field and applies validation',
      (WidgetTester tester) async {
    // Create a FieldModel for a text field with validation
    final field = FieldModel(
      type: 'text',
      label: 'Username',
      name: 'username',
      validation: ValidationModel(required: true, minLength: 5),
    );

    // Create a GlobalKey for the Form widget
    final formKey = GlobalKey<FormState>();

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                FormFieldWidget(field: field),
                ElevatedButton(
                  onPressed: () {
                    formKey.currentState?.validate();
                  },
                  child: const Text('Validate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Check if the TextFormField is displayed with the correct label
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);

    // Enter a value that is too short
    await tester.enterText(find.byType(TextFormField), 'usr');
    await tester.pump(); // Rebuild the widget

    // Press the validate button to trigger validation
    await tester.tap(find.text('Validate'));
    await tester.pump(); // Rebuild the widget

    // Verify the validation message for too short input
    expect(find.text('Username must be at least 5 characters'), findsOneWidget);

    // Enter a valid value
    await tester.enterText(find.byType(TextFormField), 'user123');
    await tester.pump(); // Rebuild the widget

    // Press the validate button again
    await tester.tap(find.text('Validate'));
    await tester.pump(); // Rebuild the widget

    // Verify that no validation message is shown
    expect(find.text('Username must be at least 5 characters'), findsNothing);
  });

  testWidgets('FormFieldWidget displays number field and applies validation',
      (WidgetTester tester) async {
    // Create a FieldModel for a number field with validation
    final field = FieldModel(
      type: 'number',
      label: 'Age',
      name: 'age',
      validation: ValidationModel(required: true),
    );

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: FormFieldWidget(field: field),
          ),
        ),
      ),
    );

    // Check if the TextFormField is displayed with number keyboard
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);

    // Enter a value
    await tester.enterText(find.byType(TextFormField), '30');
    await tester.pump(); // Rebuild the widget

    // Verify that no validation message is shown for valid input
    expect(find.text('Age is required'), findsNothing);
  });

  testWidgets(
      'FormFieldWidget does not display anything for unknown field type',
      (WidgetTester tester) async {
    // Create a FieldModel with an unknown type
    final field = FieldModel(
      type: 'unknown',
      label: 'Unknown Field',
      name: 'unknown',
      validation: ValidationModel(required: true),
    );

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: FormFieldWidget(field: field),
          ),
        ),
      ),
    );

    // Check if nothing is displayed
    expect(find.byType(TextFormField), findsNothing);
  });
}
