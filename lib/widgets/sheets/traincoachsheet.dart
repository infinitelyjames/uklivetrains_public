import 'package:uklivetrains/modules/api.dart';
import 'package:flutter/material.dart';
import 'package:uklivetrains/structs/coach.dart';

class TrainCoachSheet extends StatelessWidget {
  final Coach coach;

  const TrainCoachSheet({super.key, required this.coach});

  List<Widget> _buildContents(BuildContext context) {
    List<Widget> widgets = [];
    // Title
    widgets.add(Text("Coach ${coach.coachNumber ?? ''}",
        style: Theme.of(context).textTheme.headlineMedium));
    // Details
    widgets.addAll(_buildDetailsWidgets(context));
    return widgets;
  }

  TextSpan _buildIconWithText(
      BuildContext context, String text, IconData iconData) {
    return TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: <InlineSpan>[
          TextSpan(text: "$text ("),
          WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(iconData,
                  size: Theme.of(context).textTheme.bodyMedium!.fontSize)),
          const TextSpan(text: ")")
        ]);
  }

  List<Widget> _buildDetailsWidgets(BuildContext context) {
    List<Widget> widgets = [];
    // Seating
    if (coach.classSeating != null) {
      widgets.add(Text("${coach.classSeating} class seating"));
    }
    // Toilets
    if (coach.toiletType != null &&
        (coach.toiletType!.toLowerCase() == "accessible" ||
            coach.toiletType!.toLowerCase() == "standard")) {
      widgets.add(RichText(
          text: _buildIconWithText(
              context,
              "${coach.toiletType} toilet",
              coach.toiletType!.toLowerCase() == "accessible"
                  ? Icons.accessible
                  : Icons.wc)));
    }
    // Note about convention
    widgets.add(Text(
      "Note: numbering convention for coaches may differ than those used on station boards.",
      style: Theme.of(context).textTheme.bodySmall,
    ));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildContents(context),
        ),
      ),
    );
  }
}
