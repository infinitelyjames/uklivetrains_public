class HHMMTime {
  final String rawTime; // Format HH:MM (colon is important)
  late int hours;
  late int mins;

  HHMMTime(this.rawTime) {
    List<String> rawTimeSplit = rawTime.split(":");
    if (rawTimeSplit.length != 2) {
      throw const FormatException(
          "Must only be two sections to the time, separated by a :");
    }
    int? tempHours = int.tryParse(rawTimeSplit[0]);
    int? tempMins = int.tryParse(rawTimeSplit[1]);
    if (tempHours == null || tempMins == null) {
      throw const FormatException(
          "Failed to parse time due to parameters not being integers");
    }
    hours = tempHours;
    mins = tempMins;
  }

  factory HHMMTime.fromDateTime(DateTime dateTime) {
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    return HHMMTime("$hour:$minute");
  }

  @override
  String toString() {
    return rawTime;
  }

  static String getCurrentStringTime() {
    DateTime now = DateTime.now();
    String hour = now.hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
