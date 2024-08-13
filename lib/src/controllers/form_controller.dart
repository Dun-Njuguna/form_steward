import 'package:flutter/material.dart';

/// A controller that manages form validation and saving for a Flutter form.
///
/// The [FormController] class provides methods to validate and save the form
/// fields in a Flutter [Form]. It uses a [GlobalKey] to reference the form's
/// state, enabling operations on the form from outside the widget tree.
class FormController {
  /// The [GlobalKey] used to access the state of the form.
  ///
  /// This key is required to validate and save the form, as it provides access
  /// to the internal state of the form widget.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Validates the form.
  ///
  /// This method calls `validate()` on the form's state, which in turn calls
  /// the `validator` function of each [FormField] in the form. If all fields
  /// return `null`, the form is considered valid.
  ///
  /// Returns `true` if the form is valid, otherwise returns `false`. If the
  /// form state is `null`, it returns `false` by default.
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Saves the form.
  ///
  /// This method calls `save()` on the form's state, which in turn calls the
  /// `onSaved` function of each [FormField] in the form. This is typically used
  /// to persist the form data.
  ///
  /// If the form state is `null`, this method does nothing.
  void saveForm() {
    formKey.currentState?.save();
  }
}
