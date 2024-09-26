import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/utils/interfaces/stepper_navigation.dart';
import 'package:form_steward/src/widgets/steppers/horizontal_stepper.dart';
import 'package:form_steward/src/widgets/steppers/tablet_stepper.dart';
import 'package:form_steward/src/widgets/steppers/vertical_stepper.dart';

/// A customizable stepper widget that enables navigation through multiple steps.
/// It supports vertical, horizontal, and tablet layouts.
///
/// The widget handles navigation between steps and allows custom behaviors through
/// the `onNextStep`, `onPreviousStep`, and `onSubmit` methods. You can customize
/// the layout and behavior of the stepper by providing different stepper types
/// and overriding the default behavior of step transitions.
class StepperWidget extends StatefulWidget implements StepperNavigation {
  /// Creates an instance of [StepperWidget].
  ///
  /// Requires a list of [FormStepModel] objects for the content of each step,
  /// the current step index, the layout type, and notifiers for form state and validation.
  StepperWidget({
    super.key,
    required this.formSteps,
    required this.currentStep,
    required this.stepperType,
    required this.formStewardNotifier,
    required this.formStewardStateNotifier,
  });

  /// A list of [FormStepModel] objects, each representing a step in the stepper.
  ///
  /// Each [FormStepModel] should include the content and validation requirements
  /// for the specific step.
  final List<FormStepModel> formSteps;

  /// A list of [Widget]s where each widget is a [FormBuilder] instance.
  ///
  /// This list is created by mapping over [formSteps], where each step is used
  /// to instantiate a [FormBuilder] widget. Each [FormBuilder] is configured
  /// with the following parameters:
  /// - `steps`: A list containing a single [FormStepModel] representing the current step.
  /// - `validationTriggerNotifier`: A notifier used to trigger validation for the form.
  /// - `formStewardStateNotifier`: A notifier managing the state of the form.
  ///
  /// The resulting list of [FormBuilder] widgets corresponds to each step in the
  /// form, with each widget handling its specific step's content and validation.
  ///
  /// The list is populated by transforming the [formSteps] into [FormBuilder] widgets
  /// and then converting the iterable to a list.
  ///
  /// This list is used to display the form steps in the [StepperWidget], with each
  /// step's content and validation being managed by its respective [FormBuilder] instance.
  late final List<Widget> stepWidgets = formSteps.map((step) {
    return FormBuilder(
      steps: [step],
      validationTriggerNotifier: formStewardNotifier,
      formStewardStateNotifier: formStewardStateNotifier,
    );
  }).toList();

  /// The index of the currently active step.
  ///
  /// This determines which step is currently visible and active.
  final int currentStep;

  /// The type of stepper layout to use.
  ///
  /// Defines the layout style of the stepper. Possible values are:
  /// - [StewardStepperType.vertical]
  /// - [StewardStepperType.horizontal]
  /// - [StewardStepperType.tablet]
  final StewardStepperType stepperType;

  /// Notifier for triggering form validation.
  final ValidationTriggerNotifier formStewardNotifier;

  /// Notifier for managing the form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  @override
  StepperWidgetState createState() => StepperWidgetState();

  @override
  void onNextStep({required Map<String, dynamic>? previousStepData}) {}

  @override
  void onPreviousStep() {}

  @override
  void onSubmit({required Map<String, Map<String, dynamic>> formData}) {}
}

class StepperWidgetState extends State<StepperWidget> {

  @override
  Widget build(BuildContext context) {
    switch (widget.stepperType) {
      case StewardStepperType.vertical:
        return VerticalStepper(
          formSteps: widget.formSteps,
          formStewardNotifier: widget.formStewardNotifier,
          formStewardStateNotifier: widget.formStewardStateNotifier,
          onSubmit: (formData) {
            widget.onNextStep(previousStepData: formData);
          },
        );
      case StewardStepperType.horizontal:
        return HorizontalStepper(
          formSteps: widget.formSteps,
          formStewardNotifier: widget.formStewardNotifier,
          formStewardStateNotifier: widget.formStewardStateNotifier,
          onSubmit: (formData) {
            widget.onSubmit(formData: formData);
          },
        );
      case StewardStepperType.tablet:
        return TabletStepperWidget(
          formSteps: widget.formSteps,
          formStewardNotifier: widget.formStewardNotifier,
          formStewardStateNotifier: widget.formStewardStateNotifier,
          onNext: (formData) {
            widget.onNextStep(previousStepData: formData);
          },
          onPrevious: () {},
          onSubmit: (formData) {
            widget.onSubmit(formData: formData);
          },
        );
    }
  }
}


// class StepperWidgetState extends State<StepperWidget> {
//   late final ValueNotifier<int> _currentStepNotifier;
//   late final ScrollController _scrollController;
//   final double _itemHeight = 62; // Height of each item in the scrollable list

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _currentStepNotifier = ValueNotifier(widget.currentStep);
//   }

//   @override
//   void didUpdateWidget(covariant StepperWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.currentStep != oldWidget.currentStep) {
//       _currentStepNotifier.value = widget.currentStep;
//       _scrollToActiveStep();
//     }
//   }

//   @override
//   void dispose() {
//     _currentStepNotifier.dispose();
//     super.dispose();
//   }

//   /// Scrolls to the active step if the layout type is [StewardStepperType.tablet].
//   void _scrollToActiveStep() {
//     if (widget.stepperType != StewardStepperType.tablet) return;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final stepIndex = _currentStepNotifier.value;
//       final itemOffset = _itemHeight * stepIndex;

//       if (_isStepVisible(stepIndex)) {
//         return;
//       }
//       _scrollController.animateTo(
//         itemOffset,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     });
//   }

//   /// Checks if a step at the given index is visible within the viewport.
//   bool _isStepVisible(int index) {
//     final viewport = _scrollController.position;
//     final itemOffset = _itemHeight * index;
//     final itemEndOffset = itemOffset + _itemHeight;

//     return itemOffset >= viewport.pixels &&
//         itemEndOffset <= viewport.pixels + viewport.viewportDimension;
//   }

//   /// Navigates to the next step, optionally setting the position.
//   void _goToNextStep(int? position) {
//     final data = widget.formStewardStateNotifier.getCurrentStepData(
//       currentStepName: widget.formSteps[_currentStepNotifier.value].name,
//     );
//     setState(() {
//       position != null
//           ? _currentStepNotifier.value = position
//           : _currentStepNotifier.value++;
//       _scrollToActiveStep();
//     });
//     widget.onNextStep(previousStepData: data);
//   }

//   /// Navigates to the previous step, optionally setting the position.
//   void _goToPreviousStep(int? position) {
//     widget.formStewardNotifier.triggerValidation(
//       widget.formSteps[_currentStepNotifier.value].name,
//     );

//     if (_currentStepNotifier.value > 0) {
//       setState(() {
//         position != null
//             ? _currentStepNotifier.value = position
//             : _currentStepNotifier.value--;
//         _scrollToActiveStep();
//       });
//     }
//   }

//   /// Submits the form and calls the `onSubmit` method with the collected form data.
//   void _submitForm() {
//     final data = widget.formStewardStateNotifier.getFormData();
//     widget.onSubmit(formData: data);
//   }

//   @override
//   Widget build(BuildContext context) {
//     switch (widget.stepperType) {
//       case StewardStepperType.vertical:
//         return VerticalStepper(
//           formSteps: widget.formSteps,
//           formStewardNotifier: widget.formStewardNotifier,
//           formStewardStateNotifier: widget.formStewardStateNotifier,
//           onSubmit: (formData) {
//             widget.onNextStep(previousStepData: formData);
//           },
//         );
//       case StewardStepperType.horizontal:
//         return HorizontalStepper(
//           formSteps: widget.formSteps,
//           formStewardNotifier: widget.formStewardNotifier,
//           formStewardStateNotifier: widget.formStewardStateNotifier,
//           onSubmit: (formData) {
//             widget.onSubmit(formData: formData);
//           },
//         );
//       case StewardStepperType.tablet:
//         return _buildTabletStepper(context);
//     }
//   }

//   /// Builds the tablet layout for the stepper.
//   Widget _buildTabletStepper(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//           width: MediaQuery.of(context).size.width * 0.30,
//           child: Scrollbar(
//             controller: _scrollController,
//             thumbVisibility: true,
//             interactive: true,
//             thickness: 1.2,
//             child: Padding(
//               padding: const EdgeInsets.only(right: 7),
//               child: ListView.builder(
//                 controller: _scrollController,
//                 itemCount: widget.formSteps.length,
//                 itemBuilder: (context, index) {
//                   final theme = Theme.of(context);
//                   final isActive = index == _currentStepNotifier.value;

//                   return ListTile(
//                     leading: CircleAvatar(
//                       radius: 14,
//                       backgroundColor: isActive
//                           ? theme.colorScheme.primary
//                           : theme.colorScheme.onSurface.withOpacity(0.1),
//                       foregroundColor: isActive
//                           ? theme.colorScheme.onPrimary
//                           : theme.colorScheme.onSurface,
//                       child: Text(
//                         '${index + 1}',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     title: Text(
//                       widget.formSteps[index].title,
//                       style: isActive
//                           ? TextStyle(color: theme.colorScheme.primary)
//                           : null,
//                     ),
//                     selected: isActive,
//                     onTap: () {
//                       setState(() {
//                         _currentStepNotifier.value = index;
//                         _scrollToActiveStep();
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 15),
//                 Expanded(
//                   child: IndexedStack(
//                     index: _currentStepNotifier.value,
//                     children: widget.stepWidgets,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       if (_currentStepNotifier.value > 0)
//                         ElevatedButton(
//                           onPressed: () {
//                             _goToPreviousStep(null);
//                           },
//                           child: const Text('Back'),
//                         )
//                       else
//                         const Spacer(flex: 3),
//                       Text(
//                           '${_currentStepNotifier.value + 1}/${widget.stepWidgets.length}'),
//                       if (_currentStepNotifier.value == 0)
//                         const Spacer(flex: 2),
//                       _currentStepNotifier.value ==
//                               widget.stepWidgets.length - 1
//                           ? ElevatedButton(
//                               onPressed: () => _submitForm(),
//                               child: const Text('Submit'),
//                             )
//                           : ElevatedButton(
//                               onPressed: () {
//                                 _goToNextStep(null);
//                               },
//                               child: const Text('Next'),
//                             ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
