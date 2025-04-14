import 'package:uklivetrains/structs/place.dart';

class CallingPoint extends Place {
  final String scheduledTime;
  String estimatedTime;
  final int? coaches; // The number of coaches at each stop
  bool departedYet;
  String? platform;
  String? delayCancelReason;

  @override
  String toString() {
    return "NAME: ${super.name}, STD: $scheduledTime, ETD: $estimatedTime, COACHES: $coaches, DEPARTED_YET: $departedYet, PLATFORM: $platform ";
  }

  CallingPoint({
    required String name,
    required String crs,
    required this.scheduledTime,
    required this.estimatedTime,
    this.coaches,
    this.departedYet = false,
    this.platform,
    this.delayCancelReason,
  }) : super(name: name, crs: crs);

  factory CallingPoint.fromJSON(Map<String, dynamic> json) {
    return CallingPoint(
      name: json['locationName'],
      crs: json['crs'],
      scheduledTime: json['st'],
      estimatedTime: json['et'].toString().toLowerCase() == "on time" ||
              json['at'].toString().toLowerCase() == "on time"
          ? json['st']
          : json['et'] ?? json['at'],
      coaches: json["length"] == null ? null : int.parse(json["length"]),
      departedYet: json['at'] != null,
      delayCancelReason: json["cancelReason"] ?? json["delayReason"],
    );
  }
}
