/* A departure board query that is used between a certain time only 
Ie. for a departure board widget that only shows on the home page between certain times
*/
import 'package:uklivetrains/structs/homescreenwidgetdetails.dart';
import 'package:uklivetrains/structs/repeatingtimeselection.dart';
import 'package:uklivetrains/structs/stationboardquery.dart';

/* 
This is important to have in the resulting JSON.
When the home screen is built, and the details retrieved from storage, it is a list of widget details.
Widget details JSON do not follow any discernible pattern - to be built, it must know what widget type it is.
*/
const String DEPARTURE_BOARD_WIDGET_TYPE = "departureBoard";

class DepartureBoardQueryTimed extends HomeScreenWidgetDetails {
  RepeatingTimeSelection repeatingTimeSelection;
  StationBoardQuery stationBoardQuery;

  DepartureBoardQueryTimed({
    required this.repeatingTimeSelection,
    required this.stationBoardQuery,
  });

  factory DepartureBoardQueryTimed.fromJSON(Map<String, dynamic> json) {
    return DepartureBoardQueryTimed(
      repeatingTimeSelection:
          RepeatingTimeSelection.fromJSON(json["repeatingTimeSelection"]),
      stationBoardQuery: StationBoardQuery.fromJSON(json["stationBoardQuery"]),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "widgetType": DEPARTURE_BOARD_WIDGET_TYPE,
      "repeatingTimeSelection": repeatingTimeSelection.toJSON(),
      "stationBoardQuery": stationBoardQuery.toJSON(),
    };
  }
}
