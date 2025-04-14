import 'package:flutter/material.dart';

typedef ButtonCallback = void Function(BuildContext context);

// Class that contains the widget contents of the segmented button and the callback
class ButtonMapper {
  final ButtonCallback callback;
  final Widget? buttonLabel;
  final IconData? buttonIcon;

  const ButtonMapper({
    required this.callback,
    this.buttonLabel,
    this.buttonIcon,
  });
}

class SegmentedButtonSelection extends StatefulWidget {
  final List<ButtonMapper> buttonData;
  final int selection;
  const SegmentedButtonSelection(
      {super.key, required this.buttonData, this.selection = 0});

  @override
  State<SegmentedButtonSelection> createState() =>
      _SegmentedButtonSelectionState();
}

class _SegmentedButtonSelectionState extends State<SegmentedButtonSelection> {
  //int? selected;
  List<ButtonSegment<int>> _buildSegments() {
    List<ButtonSegment<int>> segments = [];

    int i = 0;
    for (ButtonMapper buttonMapper in widget.buttonData) {
      segments.add(ButtonSegment(
        value: i,
        label: buttonMapper.buttonLabel,
        icon: buttonMapper.buttonIcon != null
            ? Icon(buttonMapper.buttonIcon)
            : null,
      ));
      i++;
    }

    return segments;
  }

  @override
  Widget build(BuildContext context) {
    int selected = widget.selection;
    return SegmentedButton<int>(
      segments: _buildSegments(),
      selected: {selected!},
      onSelectionChanged: (Set<int> newSelection) => setState(() {
        selected = newSelection.first;
        widget.buttonData[selected!].callback(context);
      }),
      style: SegmentedButton.styleFrom(
        backgroundColor: Theme.of(context).brightness == Brightness.light ? 
        Color.alphaBlend(Colors.white.withOpacity(0.55),Theme.of(context).colorScheme.inversePrimary).withOpacity(0.7)
         : Color.alphaBlend(Colors.black.withOpacity(0.55),Theme.of(context).colorScheme.inversePrimary).withOpacity(0.7),
        selectedBackgroundColor:
            Theme.of(context).colorScheme.inversePrimary.withOpacity(0.9),
      ),
    );
  }
}
