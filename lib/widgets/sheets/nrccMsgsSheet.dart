import 'package:flutter/material.dart';

class NrccMsgsSheet extends StatelessWidget {
  final List<Widget>
      nrccWidgets; // These are built in the trainlist class and passed

  const NrccMsgsSheet({super.key, required this.nrccWidgets});

  List<Widget> _buildSheetContents(BuildContext context) {
    List<Widget> widgets = [
      Text(
        "Service Disruption",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 15)
    ];
    for (Widget widget in nrccWidgets) {
      widgets.add(widget);
      widgets.add(const SizedBox(height: 5));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(15),
              children: _buildSheetContents(context),
            ));
  }
}
