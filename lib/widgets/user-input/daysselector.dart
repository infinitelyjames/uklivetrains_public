import 'package:flutter/material.dart';

typedef ToggleButtonCallback = void Function(bool newState);
typedef OnChangedCallback = void Function(List<bool> newStates);

class DaysOfWeekSelector extends StatefulWidget {
  final List<bool> initialSelection;
  final OnChangedCallback onChangedCallback;

  DaysOfWeekSelector(
      {super.key,
      required this.initialSelection,
      required this.onChangedCallback}) {
    if (initialSelection.length != 7) {
      throw Exception("Must be a value for every day of the week");
    }
  }

  @override
  State<DaysOfWeekSelector> createState() => _DaysOfWeekSelectorState();
}

class _DaysOfWeekSelectorState extends State<DaysOfWeekSelector> {
  late List<bool> selection;

  @override
  void initState() {
    super.initState();
    selection = List.from(widget.initialSelection);
  }

  List<Widget> _buildDaysOfWeekButtons() {
    const List<String> labels = ["M", "T", "W", "T", "F", "S", "S"];
    List<Widget> widgets = [];
    for (int i = 0; i < labels.length; i++) {
      widgets.add(DayOfWeekButton(
          label: labels[i],
          callback: (bool state) {
            selection[i] = state;
            widget.onChangedCallback(selection);
          },
          initialSelection: selection[i]));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      runSpacing: -5,
      spacing: 3,
      children: _buildDaysOfWeekButtons(),
    );
  }
}

class DayOfWeekButton extends StatefulWidget {
  final String label;
  final ToggleButtonCallback callback;
  final bool initialSelection;

  const DayOfWeekButton(
      {super.key,
      required this.label,
      required this.callback,
      required this.initialSelection});

  @override
  State<DayOfWeekButton> createState() => _DayOfWeekButtonState();
}

class _DayOfWeekButtonState extends State<DayOfWeekButton> {
  late bool selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        widget.callback(!selected);
        setState(() {
          selected = !selected;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? Theme.of(context).colorScheme.secondaryContainer
            : Colors.white,
        side: selected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2.0)
            : const BorderSide(
                color: Color.fromRGBO(194, 194, 194, 0.575), width: 1.0),
      ),
      child: Text(widget.label, style: const TextStyle(height: 1.00)),
    );
  }
}
