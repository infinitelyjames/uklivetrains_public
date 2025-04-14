import 'package:flutter/material.dart';

typedef CheckboxCallback = void Function(bool? newState);

class CheckboxButtonPopupMenuItem {
  final Widget widget;
  final CheckboxCallback callback;
  bool selected;
  final Icon? icon;

  CheckboxButtonPopupMenuItem(
      {required this.widget,
      required this.callback,
      required this.selected,
      this.icon});
}

class CheckboxButtonPopup extends StatefulWidget {
  final List<CheckboxButtonPopupMenuItem> items;
  final Icon? buttonIcon;

  const CheckboxButtonPopup({super.key, required this.items, this.buttonIcon});

  @override
  State<CheckboxButtonPopup> createState() => _CheckboxButtonPopupState();
}

class _CheckboxButtonPopupState extends State<CheckboxButtonPopup> {
  late final List<CheckboxButtonPopupMenuItem> items;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.items);
  }

  // New function to show the popup menu
  void _showPopupMenu(BuildContext context) async {
    // Calculate the position of the button to place the popup menu correctly
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    // Use the calculated position to show the menu
    await showMenu(
      context: context,
      position: position,
      items: _getPopupMenuEntries(),
    );
    setState(() {});
  }

  List<PopupMenuEntry> _getPopupMenuEntries() {
    List<PopupMenuEntry> entries = [];

    for (int i = 0; i < items.length; i++) {
      CheckboxButtonPopupMenuItem item = items[i];
      entries.add(PopupMenuItem(
        child: StatefulBuilder(
          // Use StatefulBuilder to ensure the checkboxes update correctly
          builder: (BuildContext context, StateSetter setState) {
            return CheckboxListTile(
              value: items[i].selected,
              onChanged: (bool? state) {
                item.callback(state);
                setState(() {
                  items[i].selected = state ?? false;
                });
              },
              title: item.widget,
              contentPadding: EdgeInsets.zero,
            );
          },
        ),
      ));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: widget.buttonIcon ?? Icon(Icons.more_vert),
      onPressed: () {
        _showPopupMenu(
            context); // Show the popup menu when the button is pressed
      },
    );
  }
}
