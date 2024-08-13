import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/form_steward.dart';

/// Unit tests for the `FormController` class.
///
/// This test suite ensures that the `FormController` class works as expected,
/// including form validation and saving of form data.
void formControllerTests() {
  group('FormController', () {
    late FormController formController;
    late GlobalKey<FormState> formKey;

    /// Sets up the necessary objects before each test.
    ///
    /// This includes initializing the `FormController` and its associated
    /// `GlobalKey<FormState>`.
    setUp(() {
      formController = FormController();
      formKey = formController.formKey;
    });

    /// Test to verify that `validateForm` returns true when the form is valid.
    ///
    /// This test creates a simple form with a valid text field and ensures that
    /// `validateForm` correctly returns `true`.
    testWidgets('validateForm returns true when form is valid',
        (WidgetTester tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TextFormField(
              initialValue: 'Valid Input',
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
          ),
        ),
      );

      // Build the widget and trigger the validators
      await tester.pumpWidget(widget);

      // Validate the form
      expect(formController.validateForm(), isTrue);
    });

    /// Test to verify that `validateForm` returns false when the form is invalid.
    ///
    /// This test creates a form with an invalid text field (empty value) and
    /// ensures that `validateForm` correctly returns `false`.
    testWidgets('validateForm returns false when form is invalid',
        (WidgetTester tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TextFormField(
              initialValue: '',
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
          ),
        ),
      );

      // Build the widget and trigger the validators
      await tester.pumpWidget(widget);

      // Validate the form
      expect(formController.validateForm(), isFalse);
    });

    /// Test to verify that `saveForm` calls the `onSaved` callback on each form field.
    ///
    /// This test creates a form with a text field and checks if the `saveForm`
    /// method triggers the `onSaved` callback correctly.
    testWidgets('saveForm calls save on each form field',
        (WidgetTester tester) async {
      bool saveCalled = false;

      final widget = MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TextFormField(
              onSaved: (value) {
                saveCalled = true;
              },
            ),
          ),
        ),
      );

      // Build the widget and call saveForm
      await tester.pumpWidget(widget);
      formController.saveForm();

      expect(saveCalled, isTrue);
    });
  });
}
