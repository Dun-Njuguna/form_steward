import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_steward/src/widgets/stepper_widget.dart';

void main() {
  stepperWidgetTests();
}

void stepperWidgetTests() {
  testWidgets('StepperWidget displays step titles and content',
      (WidgetTester tester) async {
    // Define the steps and titles
    final steps = [
      const Text('Step 1 Content'),
      const Text('Step 2 Content'),
      const Text('Step 3 Content'),
    ];
    final titles = ['Step 1', 'Step 2', 'Step 3'];

    // Create a callback function
    void onStepContinue() {}
    void onStepCancel() {}

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepperWidget(
            steps: steps,
            titles: titles,
            onStepContinue: onStepContinue,
            onStepCancel: onStepCancel,
            currentStep: 0,
          ),
        ),
      ),
    );

    // Check if the titles are displayed correctly
    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Step 2'), findsOneWidget);
    expect(find.text('Step 3'), findsOneWidget);

    // Check if the content for the first step is displayed
    expect(find.text('Step 1 Content'), findsOneWidget);

    // Create a Key for the Stepper to identify it
    const stepperKey = Key('stepper');

    // Build the widget again with different currentStep
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepperWidget(
            key: stepperKey,
            steps: steps,
            titles: titles,
            onStepContinue: onStepContinue,
            onStepCancel: onStepCancel,
            currentStep: 1,
          ),
        ),
      ),
    );

    // Check if the content for the second step is displayed
    expect(find.text('Step 2 Content'), findsOneWidget);

    // Build the widget again with different currentStep
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StepperWidget(
            key: stepperKey,
            steps: steps,
            titles: titles,
            onStepContinue: onStepContinue,
            onStepCancel: onStepCancel,
            currentStep: 2,
          ),
        ),
      ),
    );

    // Check if the content for the third step is displayed
    expect(find.text('Step 3 Content'), findsOneWidget);
  });
}
