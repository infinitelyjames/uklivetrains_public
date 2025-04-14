import 'package:flutter/material.dart';

class SettingsCategoryContainer extends StatelessWidget {
  final String categoryName;
  final List<Widget>
      settingsActionWidgets; // This may be a tile and a toggle, or a link to another page, etc

  const SettingsCategoryContainer(
      {super.key,
      required this.categoryName,
      required this.settingsActionWidgets});

  List<Widget> _buildColumnWidgets() {
    if (settingsActionWidgets.isEmpty) {
      return [
        const ListTile(
            title: Text("No items to display"),
            subtitle: Text("Add items for them to show up here"))
      ];
    }
    List<Widget> widgets = [];
    for (Widget widget in settingsActionWidgets) {
      widgets.add(widget);
      widgets.add(const Divider(height: 1));
    }
    widgets.removeLast();
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Container(
            decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), 
                  color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black.withOpacity(0.95),
              ),
            child: Column(
              children: _buildColumnWidgets(),
            ))
      ],
    );
  }
}
