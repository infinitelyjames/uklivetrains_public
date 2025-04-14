import 'package:flutter/material.dart';
import 'package:uklivetrains/modules/api.dart';
import 'package:uklivetrains/structs/callingpoint.dart';
import 'package:uklivetrains/widgets/sheets/callingpointsheet.dart';

enum DelayType { onTime, delayed, cancelled }

class ColourSet {
  final Color foregroundColour;
  final Color backgroundColour;

  const ColourSet(this.foregroundColour, this.backgroundColour);
}

final Map<DelayType, ColourSet> COLOUR_SCHEME = {
  DelayType.onTime: ColourSet(
      Color.fromRGBO(0, 129, 32, 0.91), Color.fromRGBO(145, 221, 152, 0.8)),
  DelayType.delayed: ColourSet(
      Color.fromRGBO(240, 144, 0, 0.91), Color.fromRGBO(236, 202, 173, 0.8)),
  DelayType.cancelled: ColourSet(
      Color.fromRGBO(216, 35, 3, 0.91), Color.fromRGBO(219, 109, 89, 0.8)),
};

final ColourSet DEPARTED_COLOUR_SCHEME = ColourSet(
    Color.fromRGBO(39, 39, 39, 0.91), Color.fromRGBO(151, 151, 151, 0.75));

class CallingPointWidget extends StatelessWidget {
  final CallingPoint callingPoint;
  final DelayType delayType;
  final ColourSet colourScheme;
  bool selected; // Station selected as start or end by user
  bool trainDividesHere;
  bool trainStartsHere;
  bool trainEndsHere;

  CallingPointWidget({
    super.key,
    required this.callingPoint,
    required this.delayType,
    required this.colourScheme,
    this.selected = false,
    this.trainDividesHere = false,
    this.trainStartsHere = false,
    this.trainEndsHere = false,
  });

  factory CallingPointWidget.fromRaw(
      CallingPoint callingPoint, bool selected, bool trainDividesHere,
      {bool trainStartsHere = false, bool trainEndsHere = false}) {
    DelayType delayType =
        callingPoint.estimatedTime == callingPoint.scheduledTime
            ? DelayType.onTime
            : (callingPoint.estimatedTime.toLowerCase() == "cancelled"
                ? DelayType.cancelled
                : DelayType.delayed);
    return CallingPointWidget(
      callingPoint: callingPoint,
      delayType: delayType,
      colourScheme: callingPoint.departedYet
          ? DEPARTED_COLOUR_SCHEME
          : COLOUR_SCHEME[delayType]!,
      selected: selected,
      trainDividesHere: trainDividesHere,
      trainStartsHere: trainStartsHere,
      trainEndsHere: trainEndsHere,
    );
  }

  void setSelected(bool selected) {
    this.selected = selected;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> timeComparison = [
      Text(
        callingPoint.estimatedTime,
        style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal),
      )
    ];
    if (callingPoint.estimatedTime != callingPoint.scheduledTime) {
      timeComparison.insert(
          0,
          Text(
            callingPoint.scheduledTime,
            style: TextStyle(
                decoration: TextDecoration.lineThrough,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal),
          ));
    }
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => CallingPointSheet(
              callingPoint: callingPoint, dividesHere: trainDividesHere),
        );
      },
      child: Row(
        children: [
          Image.asset(
            "assets/callingPoint${delayType == DelayType.onTime ? 'OnTime' : delayType == DelayType.delayed ? 'Delayed' : 'Cancelled'}${callingPoint.departedYet ? 'Departed' : ''}${trainStartsHere ? 'Starts' : ''}${trainEndsHere && !trainStartsHere ? 'Ends' : ''}.png",
            height: 44, // TODO - fix hardcoding here
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                //border:
                //    Border.all(color: colourScheme.foregroundColour, width: 1),
                color: Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(240, 240, 240, 0.698):const Color.fromRGBO(15, 15, 15, 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(129, 129, 129, 0.7) : const Color.fromRGBO(129, 129, 129, 0.3),
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(
                        callingPoint.platform == null
                            ? callingPoint.name
                            : "${callingPoint.name} (Platform ${callingPoint.platform})",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ),
                  ...timeComparison,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* old icons 
Icon(
                trainDividesHere
                    ? Icons.double_arrow
                    : selected
                        ? Icons.flag
                        : (delayType == DelayType.onTime
                            ? Icons.check_circle_outline
                            : Icons.error_outline_rounded),
                color: colourScheme.foregroundColour)


*/

/* 2nd theming 
return Row(
      children: [
        Icon(
            selected
                ? Icons.flag
                : (delayType == DelayType.onTime
                    ? Icons.check_circle_outline
                    : Icons.error_outline_rounded),
            color: colourScheme.foregroundColour),
        SizedBox(width: 5),
        Expanded(
          child: Container(
            child: Row(
              children: [
                Expanded(
                  child: Text(callingPoint.name,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal)),
                ),
                ...timeComparison,
              ],
            ),
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border:
                  Border.all(color: colourScheme.foregroundColour, width: 1),
              color: colourScheme.backgroundColour,
            ),
          ),
        ),
      ],
    );

*/