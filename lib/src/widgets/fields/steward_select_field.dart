import 'package:flutter/material.dart';
import 'package:form_steward/form_steward.dart';
import 'package:form_steward/src/models/option_model.dart';

/// A custom form DropDown field for selecting an option from a list.
///
class StewardSelectField extends StatefulWidget {
  /// The model containing field properties and validation rules.
  final FieldModel field;

  /// The name of the step this field belongs to in a multi-step form.
  final String stepName;

  /// Notifier for triggering validation across form fields.
  final ValidationTriggerNotifier validationTriggerNotifier;

  /// Notifier for updating the overall form state.
  final FormStewardStateNotifier formStewardStateNotifier;

  /// Optional function to fetch options asynchronously.
  final Future<List<OptionModel>> Function()? fetchOptions;

  /// Creates a [StewardSelectField].
  ///
  /// Requires [BaseFieldWidget] parameters which include all necessary field information.
  StewardSelectField({
    super.key,
    required BaseFieldWidget fieldParams,
  })  : field = fieldParams.field,
        stepName = fieldParams.stepName,
        formStewardStateNotifier = fieldParams.formStewardStateNotifier,
        validationTriggerNotifier = fieldParams.validationTriggerNotifier,
        fetchOptions = fieldParams.fetchOptions;

  @override
  StewardSelectFieldState createState() => StewardSelectFieldState();
}

/// The state for [StewardSelectField].
class StewardSelectFieldState extends State<StewardSelectField> {
  OptionModel? _selectedOption;
  String? _errorMessage;
  late Future<List<OptionModel>> _optionsFuture;

  @override
  void initState() {
    super.initState();
    widget.validationTriggerNotifier.addListener(_onValidationTrigger);
    _optionsFuture = _getOptions();
  }

  @override
  void dispose() {
    widget.validationTriggerNotifier.removeListener(_onValidationTrigger);
    super.dispose();
  }

  /// Fetches the list of options for the select field.
  Future<List<OptionModel>> _getOptions() async {
    if (widget.field.options != null) {
      return widget.field.options!;
    } else if (widget.fetchOptions != null) {
      return await widget.fetchOptions!();
    }
    return [];
  }

  /// Shows the selection dialog when the field is tapped.
  void _showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SelectionDialog(
          options: _optionsFuture,
          onSelect: _handleOptionSelection,
        );
      },
    );
  }

  /// Handles the selection of an option from the dialog.
  void _handleOptionSelection(OptionModel option) {
    setState(() {
      _selectedOption = option;
      _validate();
      _updateFormState();
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = _errorMessage != null;
    const Color errorColor = Colors.red;
    final Color normalColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(hasError, errorColor),
        const SizedBox(height: 8),
        _buildSelectionContainer(hasError, errorColor, normalColor),
        if (hasError) _buildErrorMessage(errorColor),
      ],
    );
  }

  /// Builds the label for the select field.
  Widget _buildLabel(bool hasError, Color errorColor) {
    return Text(
      widget.field.label,
      style: hasError ? TextStyle(color: errorColor) : null,
    );
  }

  /// Builds the container that represents the select field.
  Widget _buildSelectionContainer(bool hasError, Color errorColor, Color normalColor) {
    return GestureDetector(
      onTap: _showSelectionDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasError ? errorColor : normalColor,
            width: hasError ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedOption?.value ?? 'Select an option',
              style: TextStyle(
                color: hasError ? errorColor : Colors.black87,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: hasError ? errorColor : normalColor,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error message display.
  Widget _buildErrorMessage(Color errorColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        _errorMessage!,
        style: TextStyle(color: errorColor, fontSize: 12),
      ),
    );
  }

  /// Validates the current selection.
  void _validate() {
    if (widget.field.validation?.required == true && _selectedOption == null) {
      setState(() {
        _errorMessage = 'Selection required';
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  /// Updates the overall form state based on the current selection.
  void _updateFormState() {
    widget.formStewardStateNotifier.updateField(
      stepName: widget.stepName,
      fieldName: widget.field.name,
      value: _selectedOption?.id,
      isValid: _errorMessage == null,
    );
  }

  /// Callback for when validation is triggered externally.
  void _onValidationTrigger() {
    if (widget.validationTriggerNotifier.value == widget.stepName) {
      _validate();
      _updateFormState();
    }
  }
}

/// A dialog for selecting an option from a list.
class SelectionDialog extends StatefulWidget {
  /// The future that resolves to the list of options.
  final Future<List<OptionModel>> options;

  /// Callback function when an option is selected.
  final Function(OptionModel) onSelect;

  /// Creates a [SelectionDialog].
  const SelectionDialog({
    super.key,
    required this.options,
    required this.onSelect,
  });

  @override
  SelectionDialogState createState() => SelectionDialogState();
}

/// The state for [SelectionDialog].
class SelectionDialogState extends State<SelectionDialog> {
  bool _showSearch = false;
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Toggles the search functionality.
  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        });
      } else {
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildDialogTitle(),
      content: _buildDialogContent(),
    );
  }

  /// Builds the title row for the dialog.
  Widget _buildDialogTitle() {
    return Row(
      children: [
        Text(
          'Select an option',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const Spacer(),
        _buildSearchToggle(),
      ],
    );
  }

  /// Builds the search toggle button with animation.
  Widget _buildSearchToggle() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _showSearch ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: IconButton(
        icon: Icon(Icons.search, size: 22, color: Theme.of(context).primaryColor.withOpacity(0.7)),
        onPressed: _toggleSearch,
        splashRadius: 20,
      ),
      secondChild: IconButton(
        icon: Icon(Icons.close, size: 22, color: Theme.of(context).primaryColor.withOpacity(0.7)),
        onPressed: _toggleSearch,
        splashRadius: 20,
      ),
    );
  }

  /// Builds the main content of the dialog.
  Widget _buildDialogContent() {
    return SizedBox(
      height: 200,
      width: double.maxFinite,
      child: FutureBuilder<List<OptionModel>>(
        future: widget.options,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Text('Error fetching options');
          }
          final options = snapshot.data ?? [];
          final filteredOptions = _filterOptions(options);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showSearch) _buildSearchField(),
              Expanded(child: _buildOptionsList(filteredOptions)),
            ],
          );
        },
      ),
    );
  }

  /// Builds the search input field.
  Widget _buildSearchField() {
    return TextField(
      focusNode: _searchFocusNode,
      decoration: const InputDecoration(
        hintText: 'Search...',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  /// Builds the list of options.
  Widget _buildOptionsList(List<OptionModel> options) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: options.length,
      itemBuilder: (context, index) => _buildOptionItem(options[index], index),
    );
  }

  /// Builds a single option item in the list.
  Widget _buildOptionItem(OptionModel option, int index) {
    return InkWell(
      onTap: () => widget.onSelect(option),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Text(
              "${index + 1}.",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filters the options based on the search query.
  List<OptionModel> _filterOptions(List<OptionModel> options) {
    return options
        .where((option) => option.value
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }
}