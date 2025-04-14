import 'package:uklivetrains/modules/api.dart';
import 'package:uklivetrains/structs/place.dart';

class StationBoardQuery {
  final Place startStation;
  final Place? destinationStation;
  final List<bool> serviceTypesFiltered;

  const StationBoardQuery(
      {required this.startStation,
      required this.destinationStation,
      required this.serviceTypesFiltered});

  factory StationBoardQuery.fromJSON(Map<String, dynamic> json) {
    //print(json);
    //print(json["serviceTypesFiltered"]);
    return StationBoardQuery(
      startStation: Place.fromSerializableJSON(json["start"]),
      destinationStation: json["destination"] != null
          ? Place.fromSerializableJSON(json["destination"])
          : null,
      serviceTypesFiltered: List<bool>.from(json["serviceTypesFiltered"]),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "start": startStation.toSerializableJSON(),
      "destination": destinationStation?.toSerializableJSON(),
      "serviceTypesFiltered": serviceTypesFiltered,
    };
  }
}
