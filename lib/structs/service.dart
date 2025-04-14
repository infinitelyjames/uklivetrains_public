import 'package:uklivetrains/modules/api.dart' as api;
import 'package:uklivetrains/structs/callingpoint.dart';
import 'package:uklivetrains/structs/coach.dart';
import 'package:uklivetrains/structs/place.dart';
import 'package:uklivetrains/structs/placelist.dart';

class Service {
  // IMPORTANT: When adding attributes, make sure to add them to the UPDATE function as well
  // Service details
  DateTime lastUpdated;
  String? serviceCode;
  String? serviceType;
  PlaceList? origin;
  PlaceList? destination;
  String? operator;
  String? coaches;
  List<List<CallingPoint>>?
      subsequentCallingPoints; // subsequentCallingPoints will be null for arrivals at a terminus station
  List<List<CallingPoint>>?
      previousCallingPoints; // previousCallingPoints will be null for departures from a terminus station
  String? delayCancelReason;
  List<Coach>? formation;
  // User-route dependent objects
  String? platform;
  String? scheduledDepartureTime;
  String? scheduledArrivalTime;
  String? estDepartureTime;
  String? estArrivalTime;
  bool? departedYet; // Has the service departed the user's start station yet?
  // User-route places
  Place? userStartStation;
  Place? userDestinationStation;
  // User-route dependent calculatable objects
  int? journeyDuration;
  int? numberOfStops;

  Service({
    required this.lastUpdated,
    this.serviceCode,
    this.serviceType,
    this.origin,
    this.destination,
    this.operator,
    this.coaches,
    this.subsequentCallingPoints,
    this.previousCallingPoints,
    this.delayCancelReason,
    this.formation,
    this.platform,
    this.scheduledArrivalTime,
    this.scheduledDepartureTime,
    this.estDepartureTime,
    this.estArrivalTime,
    this.departedYet,
    this.userStartStation,
    this.userDestinationStation,
    this.journeyDuration,
    this.numberOfStops,
  });

  factory Service.fromAPIServiceSummary(api.ServiceSummary s) {
    return Service(
      lastUpdated: s.lastUpdated,
      serviceCode: s.serviceCode,
      serviceType: s.serviceType,
      origin: s.origin,
      destination: s.destination,
      platform: s.platform,
      scheduledDepartureTime: s.scheduledDepartureTime,
      scheduledArrivalTime: s.scheduledArrivalTime,
      estDepartureTime: s.estDepartureTime,
      estArrivalTime: s.estArrivalTime,
      departedYet: s.departed,
      operator: s.operator,
      coaches: s.coaches,
      subsequentCallingPoints: s.callingPoints,
      previousCallingPoints: s.previousCallingPoints,
      delayCancelReason: s.delayCancelReason,
      formation: s.formation,
    );
  }

  // Update changed details for the same service, but from a later API call. Does not override properties if they are now null.
  void update(Service s) {
    // Note, for calling points, you need to check if they are empty lists ([]) as sometimes this may be returned instead of null
    lastUpdated = s.lastUpdated;
    serviceCode = s.serviceCode ?? serviceCode;
    serviceType = s.serviceType ?? serviceType;
    origin = s.origin ?? origin;
    destination = s.destination ?? destination;
    operator = s.operator ?? operator;
    coaches = s.coaches ?? coaches;
    subsequentCallingPoints =
        s.subsequentCallingPoints == null || s.subsequentCallingPoints == []
            ? subsequentCallingPoints
            : s.subsequentCallingPoints;
    previousCallingPoints =
        s.previousCallingPoints == null || s.previousCallingPoints == []
            ? previousCallingPoints
            : s.previousCallingPoints;
    delayCancelReason = s.delayCancelReason ?? delayCancelReason;
    platform = s.platform ?? platform;
    scheduledDepartureTime = s.scheduledDepartureTime ?? scheduledDepartureTime;
    scheduledArrivalTime = s.scheduledArrivalTime ?? scheduledArrivalTime;
    estDepartureTime = s.estDepartureTime ?? estDepartureTime;
    estArrivalTime = s.estArrivalTime ?? estArrivalTime;
    departedYet = s.departedYet ?? departedYet;
    userStartStation = s.userStartStation ?? userStartStation;
    userDestinationStation = s.userDestinationStation ?? userDestinationStation;
    journeyDuration = s.journeyDuration ?? journeyDuration;
    numberOfStops = s.numberOfStops ?? numberOfStops;
  }

  bool doesTerminateHere() {
    /* 
    Returns true if the service arrives and terminates at the current station, hence will have no departure attributes
    Note: due to a limitation of api service summary currently, departure times will have placeholders and not be null
    */
    return (subsequentCallingPoints == null ||
            (subsequentCallingPoints != null &&
                subsequentCallingPoints!.isEmpty)) &&
        (destination != null &&
            userStartStation != null &&
            destination!.crsInPlaces(userStartStation!.crs));
  }

  bool passengerDropoffOnly() {
    /* 
    When a train is scheduled to dropoff passengers at a station, but you cannot buy a ticket to board the train at this station.
    Note: This function will also return true for trains that terminate at a station.
    */
    return scheduledDepartureTime == null && scheduledArrivalTime != null;
  }
}
