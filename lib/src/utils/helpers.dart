import 'package:flutter/material.dart';

/// Returns a custom [OutlineInputBorder] with a specific border radius.
///
/// The border radius is defined globally as [appBorderRadius].
OutlineInputBorder customeOutlineInputBorder(
  BuildContext context,
  String? errorText,
) {
  return OutlineInputBorder(
    borderRadius: appBorderRadius,
    borderSide: BorderSide(
      color: borderColor(
        errorText,
        context,
      ),
    ),
  );
}

/// A global [BorderRadius] used throughout the application for consistent UI.
///
/// This is set to a circular radius of 8.0.
BorderRadius appBorderRadius = BorderRadius.circular(8);

/// Determines the border color based on the presence of an error message.
///
/// If [errorText] is not null, the border color will be [Colors.redAccent].
/// Otherwise, it will use the primary color from the current theme.
///
/// - [errorText]: The error message string, if any.
/// - [context]: The [BuildContext] used to access theme data.
Color borderColor(String? errorText, BuildContext context) {
  return errorText != null
      ? Theme.of(context).colorScheme.error
      : Theme.of(context).colorScheme.primary;
}

/// Returns a custom [BoxDecoration] with a border color that depends on the presence of an error.
///
/// The border color is determined by the [borderColor] function. The decoration also
/// applies the global [appBorderRadius] for consistent styling.
///
/// - [errorText]: The error message string, if any.
/// - [context]: The [BuildContext] used to access theme data.
BoxDecoration customeBoxDecoration(String? errorText, BuildContext context) {
  return BoxDecoration(
    border: Border.all(color: borderColor(errorText, context)),
    borderRadius: appBorderRadius,
  );
}

/// Creates a custom [InputDecoration] for text fields with a label and optional error text.
///
/// The decoration uses the custom [customeOutlineInputBorder] for its border and
/// applies the provided [labelText]. If [errorText] is provided, it will be displayed
/// as well.
///
/// - [context]: The [BuildContext] used to access theme data.
/// - [labelText]: The label to be displayed inside the input field.
/// - [errorText]: The error message string, if any.
InputDecoration customInputDecoration(
  BuildContext context, {
  required String labelText,
  String? errorText,
}) {
  return InputDecoration(
    border: customeOutlineInputBorder(
      context,
      errorText,
    ),
    labelText: labelText,
    errorText: errorText,
  );
}

/// A global [EdgeInsets] used for padding elements with equal spacing.
///
/// This is set to 10.0 pixels on all sides.
EdgeInsets appEqualPadding = const EdgeInsets.all(10);

/// Displays an error message in a [Padding] widget if the message is not null.
///
/// If the [errorMessage] is null, it returns an empty widget. Otherwise, it returns
/// a [Padding] containing a [Text] widget with the error message, styled in red.
///
/// - [errorMessage]: The error message string, if any.
Widget displayErrorMessage(String? errorMessage, BuildContext context) {
  if (errorMessage == null) return const SizedBox.shrink();

  return Padding(
    padding: appEqualPadding,
    child: Text(
      errorMessage,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}
