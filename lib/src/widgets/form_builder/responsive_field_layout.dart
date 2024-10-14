import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';

class ResponsiveFieldLayout extends StatelessWidget {
  final FormStepModel step;
  final ValidationTriggerNotifier validationTriggerNotifier;
  final FormStewardStateNotifier formStewardStateNotifier;

  const ResponsiveFieldLayout({
    super.key,
    required this.step,
    required this.formStewardStateNotifier,
    required this.validationTriggerNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate the number of columns based on screen width
    int numberOfColumns =
        (screenWidth ~/ 300).clamp(1, 3); // Minimum 1 column, maximum 4
    List<List<Widget>> columns =
        _distributeFields(step.fields, numberOfColumns);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        columns.length,
        (columnIndex) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns[columnIndex],
            ),
          );
        },
      ),
    );
  }

  /// Helper method to distribute fields into columns based on height.
  List<List<Widget>> _distributeFields(
      List<FieldModel> fields, int numberOfColumns) {
    // Initialize empty lists for each column
    List<List<Widget>> columns = List.generate(numberOfColumns, (_) => []);

    // Distribute fields to balance column height
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];

      // Use the shortest column for the next field to balance the layout
      int shortestColumnIndex = _findShortestColumnIndex(columns);
      columns[shortestColumnIndex].add(
        Padding(
          padding: const EdgeInsets.only(
            right: 8.0,
            left: 8.0,
            bottom: 8.0,
          ),
          child: FormFieldWidget(
            field: field,
            stepName: step.name,
            validationTriggerNotifier: validationTriggerNotifier,
            formStewardStateNotifier: formStewardStateNotifier,
          ),
        ),
      );
    }

    return columns;
  }

  /// Helper method to find the index of the shortest column
  int _findShortestColumnIndex(List<List<Widget>> columns) {
    int shortestIndex = 0;
    int shortestHeight = columns[0].length;

    for (int i = 1; i < columns.length; i++) {
      if (columns[i].length < shortestHeight) {
        shortestHeight = columns[i].length;
        shortestIndex = i;
      }
    }

    return shortestIndex;
  }
}
