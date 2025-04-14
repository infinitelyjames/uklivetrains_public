// Represents a singular timeframe daily that repeats
import 'package:uklivetrains/structs/timeformats.dart';

const List<String> DAYS_OF_WEEK = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];

class RepeatingTimeSelection {
  List<bool> onDaysOfWeek;
  List<TimeWindow> timeWindows;

  void _validateDaysOfWeek() {
    if (onDaysOfWeek.length != 7) {
      throw Exception("Must have 7 items representing the 7 days of the week");
    }
  }

  RepeatingTimeSelection(
      {required this.onDaysOfWeek, required this.timeWindows}) {
    _validateDaysOfWeek();
  }

  factory RepeatingTimeSelection.everyDay(List<TimeWindow> timeWindows) {
    return RepeatingTimeSelection(
      onDaysOfWeek: [true, true, true, true, true, true, true],
      timeWindows: timeWindows,
    );
  }

  factory RepeatingTimeSelection.fromJSON(Map<String, dynamic> json) {
    return RepeatingTimeSelection(
        onDaysOfWeek: List<bool>.from(json["onDaysOfWeek"]),
        timeWindows: (json["timeWindows"] as List<dynamic>)
            .map((timeWindowJSON) =>
                TimeWindow.fromJSON(Map<String, String>.from(timeWindowJSON)))
            .toList());
  }

  // Returns true if the time now is within the current selection
  bool isValidWhen(DateTime dateTime) {
    /* DateTime.now().weekday returns 1 for monday and so on, whereas the list starts at 0 for monday, etc...
     Maps each timewindow to boolean value which determines if the current time is within the window
    Then, if one or more of them is true, the entire list will reduce to true.
    */
    return (onDaysOfWeek[dateTime.weekday - 1] &&
        timeWindows
            .map((timeWindow) =>
                timeWindow.isWithinWindow(HHMMTime.fromDateTime(dateTime)))
            .reduce((value, element) => value || element));
  }

  Map<String, dynamic> toJSON() {
    return {
      "onDaysOfWeek": onDaysOfWeek,
      "timeWindows": timeWindows
          .map((TimeWindow timeWindow) => timeWindow.toJSON())
          .toList(),
    };
  }

  @override
  String toString() {
    String text = "on ";
    String textToAdd = "";
    for (int i = 0; i < 7; i++) {
      if (onDaysOfWeek[i]) {
        textToAdd += "${DAYS_OF_WEEK[i]}, ";
      }
    }
    if (textToAdd == "") {
      return "Never";
    } else {
      text += textToAdd;
      // Remove last ", "
      text = text.substring(0, text.length - 2);
    }
    text += " at times ";
    textToAdd = "";
    for (TimeWindow timeWindow in timeWindows) {
      textToAdd += "${timeWindow.startTime}-${timeWindow.endTime}, ";
    }
    if (textToAdd == "") {
      return "Never";
    } else {
      text += textToAdd;
      // Remove last ", "
      text = text.substring(0, text.length - 2);
    }
    return text;
  }
}

// Assumed to be on same day
class TimeWindow {
  HHMMTime startTime;
  HHMMTime endTime;

  TimeWindow({required this.startTime, required this.endTime});

  factory TimeWindow.allDay() {
    return TimeWindow(startTime: HHMMTime("00:00"), endTime: HHMMTime("23:59"));
  }

  factory TimeWindow.fromJSON(Map<String, String> json) {
    if (json["startTime"] == null || json["endTime"] == null) {
      throw const FormatException("Missing required fields start & end time");
    }
    return TimeWindow(
        startTime: HHMMTime(json["startTime"]!),
        endTime: HHMMTime(json["endTime"]!));
  }

  // Is the query time within the time window
  bool isWithinWindow(HHMMTime queryTime) {
    // Time is before start
    if (queryTime.hours < startTime.hours ||
        (queryTime.hours == startTime.hours &&
            queryTime.mins < startTime.mins)) {
      return false;
    }
    // Time is beyond end
    if (queryTime.hours > endTime.hours ||
        (queryTime.hours == endTime.hours && queryTime.mins > endTime.mins)) {
      return false;
    }
    // else, hehe :)
    return true;
  }

  Map<String, String> toJSON() {
    return {
      "startTime": startTime.toString(),
      "endTime": endTime.toString(),
    };
  }
}
