import 'package:flutter/material.dart';

typedef Callback = void Function();

final class BasicPopupMenuEntry {
  final String label;
  final Callback? callback;

  const BasicPopupMenuEntry({required this.label, this.callback});
}

// A button, which loads the desired popup menu
class BasicPopupMenuButton extends StatelessWidget {
  final List<BasicPopupMenuEntry> entries;
  final Widget child;

  const BasicPopupMenuButton(
      {super.key, required this.entries, required this.child});

  List<PopupMenuItem> _buildItems() {
    List<PopupMenuItem> popupMenuItems = [];
    for (BasicPopupMenuEntry entry in entries) {
      popupMenuItems
          .add(PopupMenuItem(child: Text(entry.label), onTap: entry.callback));
    }
    return popupMenuItems;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        child: child, itemBuilder: (BuildContext context) => _buildItems());
  }
}
