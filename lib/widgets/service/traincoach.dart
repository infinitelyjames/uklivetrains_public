import 'package:flutter/material.dart';
import 'package:uklivetrains/modules/api.dart';
import 'package:uklivetrains/structs/coach.dart';
import 'package:uklivetrains/widgets/sheets/traincoachsheet.dart';

// TODO - Fix dimension hardcoding here

class TrainCoach extends StatelessWidget {
  final int formationLength;
  final Coach coach;
  final double marginLR;
  final bool dense;
  const TrainCoach(
      {Key? key,
      required this.coach,
      required this.formationLength,
      this.marginLR = 2,
      this.dense = true})
      : super(key: key);

  // ToDo - make coach clickable to bring up a dialog with more information such as the number of available seats

  Widget? _buildClassWidget() {
    if (coach.classSeating == null) return null;
    return Container(
      margin: EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Text(
          coach.classSeating!.toLowerCase() == "first"
              ? "1st"
              : coach.classSeating!.toLowerCase() == "standard"
                  ? "Std"
                  : coach.classSeating!,
          style: TextStyle(fontSize: 20)),
    );
  }

  Widget? _buildCoachNumberWidget() {
    if (coach.coachNumber == null) return null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(coach.coachNumber!),
      ],
    );
  }

  Widget? _buildToiletsWidget() {
    if (coach.toiletType == null ||
        (coach.toiletType!.toLowerCase() != "accessible" &&
            coach.toiletType!.toLowerCase() != "standard")) return null;
    return Container(
      margin: EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: coach.toiletType!.toLowerCase() == "accessible"
          ? const Icon(Icons.accessible)
          : const Icon(Icons.wc),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (dense) {
      // old way when scrolling horizontally, may be deprecated soon
      List<Widget> widgets = [];
      if (_buildCoachNumberWidget() != null)
        widgets.add(_buildCoachNumberWidget()!);
      if (_buildClassWidget() != null) widgets.add(_buildClassWidget()!);
      if (_buildToiletsWidget() != null) widgets.add(_buildToiletsWidget()!);
      return GestureDetector(
        onTap: () => showModalBottomSheet(
            context: context,
            builder: (context) => TrainCoachSheet(coach: coach)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            color: Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(240, 240, 240, 0.4) : const Color.fromRGBO(15, 15, 15, 0.4),
          ),
          margin: EdgeInsets.fromLTRB(marginLR, 0, marginLR, 0),
          padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
          child: Row(
            children: widgets,
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(240, 240, 240, 0.4) : const Color.fromRGBO(15, 15, 15, 0.4),
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2.8),
          borderRadius: BorderRadius.only(
            topLeft: coach.indexInFormation == 0
                ? Radius.elliptical(60, 50)
                : Radius.circular(15),
            topRight: coach.indexInFormation == formationLength - 1
                ? Radius.elliptical(60, 50)
                : Radius.circular(15),
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child: ListTile(
          // TODO: replace "?" with numbering
          title: Text("Coach ${coach.coachNumber ?? "?"}"),
          subtitle: coach.classSeating != null
              ? Text("${coach.classSeating} class seating")
              : null,
          trailing: _buildToiletsWidget(),
          onTap: () => showModalBottomSheet(
              context: context,
              builder: (context) => TrainCoachSheet(coach: coach)),
          contentPadding: EdgeInsets.fromLTRB(
              coach.indexInFormation == 0 ? 30 : 15,
              0,
              coach.indexInFormation == formationLength - 1 ? 30 : 15,
              0),
        ),
      );
    }
  }
}
