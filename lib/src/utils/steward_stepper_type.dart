/// Defines the layout types for stepper widgets.
///
/// The [StewardStepperType] enum allows for different layout styles for stepper widgets,
/// enabling customization of how steps are displayed and navigated within a form.
///
/// - [vertical]: Renders steps in a vertical sequence, with the stepper's content stacked vertically.
/// - [horizontal]: Displays steps in a horizontal sequence, with the stepper's content arranged horizontally.
/// - [tablet]: Optimized for tablet screens, showing a list of steps on the left side and the content of the active step on the right side.
enum StewardStepperType {
  /// A vertical stepper that displays steps in a vertical list.
  vertical,

  /// A horizontal stepper that displays steps in a horizontal list.
  horizontal,

  /// A tablet-optimized horizontal stepper with the step list on the left
  /// and the content of the active step on the right.
  tablet,
}
