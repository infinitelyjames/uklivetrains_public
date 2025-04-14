import 'package:uklivetrains/structs/place.dart';

class UniqueServiceIdentifier {
  /* 
  RSID can be used to uniquely identify a given service on a particular day

  At least one of schDepartureTime or schArrivalTime should be provided, which ensures that since trains can only be fetched +- 2 hour window from departing, that the train is
  only fetched when it can be.

  The query station needs to be supplied so that the station the user needs it from is found.
  A filter station should also be supplied to narrow the search results down (however, is not necessary).

  Notes on using this object:
  - This object designed to be easily serialised
  - Once you have found the serviceCode (unique to the day) of your particular service, you can use that for the rest of the day, and this object becomes redundant
    as you should use your serviceCode to find details about the object, since it does not require fetching of the departure board and hence uses fewer API queries.
  */
  final String rsid;
  final String? schDepartureTime;
  final String? schArrivalTime;
  final Place queryStation;
  final Place? filterStation;

  UniqueServiceIdentifier({
    required this.rsid,
    this.schDepartureTime,
    this.schArrivalTime,
    required this.queryStation,
    this.filterStation,
  });

  Map<String, dynamic> toJSON() {
    return {
      "rsid": rsid,
      "schDepartureTime": schDepartureTime,
      "schArrivalTime": schArrivalTime,
      "queryStation": queryStation.toSerializableJSON(),
      "filterStation": filterStation?.toSerializableJSON(),
    };
  }
}
