import 'package:uklivetrains/data/station_codes.dart';
import 'package:uklivetrains/modules/web.dart' as web;
import 'package:http/http.dart' as http;
import 'package:uklivetrains/modules/utils.dart' as utils;
import 'package:uklivetrains/structs/callingpoint.dart';
import 'package:uklivetrains/structs/coach.dart';
import 'package:uklivetrains/structs/place.dart';
import 'package:uklivetrains/structs/placelist.dart';
import 'dart:convert';

import 'package:uklivetrains/structs/stationboardquery.dart'; // For JSON parsing

/*

Notes and words of warning:
- See breaking changes in the livetrainsapi repo for changes to the API
- Due to the api originally returning xml, anything that is a list, will be returned as a single item, not within a list, if only one item is present

*/

// The base url for the api: https://api.infinitydev.org.uk http://<local ip>:3001 (http://192.168.0.3:3001)
const String baseUrl = "https://api.infinitydev.org.uk";
const String API_KEY = "<YOUR_WRAPPER_API_KEY>";

// Max Number of services returned from a departure board call with no details
const int MAX_NUMBER_SERVICES_RETURNED_NO_DETAILS_DEPARTURE_BOARD = 150;

enum BoardType {
  arrivals,
  departures,
  arrivalsAndDepartures,
}

// Get livetrains data at a particular station
// CRS codes ONLY are accepted, which can be found at https://www.nationalrail.co.uk/stations_destinations/48541.aspx
Future<Map<String, dynamic>> _getLiveStationBoardJson(
    String startStationCRS, String? destinationCRS,
    {bool withDetails = true,
    int timeOffset = 0,
    BoardType boardType = BoardType.arrivalsAndDepartures}) async {
  http.Response response = await web.postRequest(
      "$baseUrl/api/v1/" +
          (boardType == BoardType.arrivals
              ? (withDetails ? "livearrivals" : "livearrivalsnodetails")
              : (boardType == BoardType.arrivalsAndDepartures
                  ? (withDetails
                      ? "livearrivalsdepartures"
                      : "livearrivalsdeparturesnodetails")
                  : (withDetails
                      ? "livedepartures"
                      : "livedeparturesnodetails"))),
      {
        "station": startStationCRS,
        "destination": destinationCRS,
        "timeOffset": timeOffset,
        "rows": withDetails ? 10 : 150,
      },
      {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        "authorization": API_KEY,
      });
  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body) as Map<String, dynamic>; // Decode JSON
  } else {
    throw Exception("Failed to get live trains data, status code: " +
        response.statusCode.toString());
  }
}

Future<Map<String, dynamic>> _getLiveServiceJson(String serviceID) async {
  http.Response response =
      await web.postRequest(baseUrl + "/api/v1/servicedetails", {
    "serviceID": serviceID
  }, {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    "authorization": API_KEY,
  });
  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception(
        "Failed to get service data, status code ${response.statusCode}: ${response.body}");
  }
}

class ServiceSummary {
  /*
  Note: This can represent trin services, bus services or ferry services.
  */
  DateTime lastUpdated;
  final String? serviceCode;
  final String serviceType;
  PlaceList? destination;
  PlaceList? origin;
  String? platform;
  String? scheduledDepartureTime;
  String? scheduledArrivalTime;
  String? estDepartureTime;
  String? estArrivalTime;
  String operator;
  String? coaches;
  List<List<CallingPoint>>?
      callingPoints; // subsequentCallingPoints will be null for arrivals at a terminus station
  List<List<CallingPoint>>?
      previousCallingPoints; // previousCallingPoints will be null for departures from a terminus station
  String? delayCancelReason;
  bool departed;
  List<Coach>? formation;

  ServiceSummary({
    required this.lastUpdated,
    required this.serviceCode,
    required this.serviceType,
    required this.destination,
    required this.origin,
    required this.platform,
    required this.scheduledDepartureTime,
    this.scheduledArrivalTime,
    required this.estDepartureTime,
    required this.estArrivalTime,
    required this.operator,
    required this.coaches,
    required this.callingPoints,
    this.previousCallingPoints,
    this.delayCancelReason,
    required this.departed,
    this.formation,
  });

  factory ServiceSummary.fromJson(Map<String, dynamic> json) {
    /*
    The following keys are (may be) present in the returned data:
    - std
    - etd OR atd
    - sta
    - eta OR ata
    - platform
    - operator
    - operatorCode (not used)
    - serviceType
    - length
    - serviceId or serviceID
    - rsid (not used)
    - origin (not used)
    - destination
    - previousCallingPoints
    - subsequentCallingPoints
    - currentDestinations (not used)
    - sta 
    - eta
    - isCircularRoute (not used)
    - isCancelled (not used)
    - filterLocationCancelled (not used)
    - delayReason (not used)
    - cancelReason (not used)
    - detachFront (not used)
    - isReverseFormation (not used)
    - adhocAlerts (not used)
    - uncertainty (not used)
    */
    return ServiceSummary(
      // TODO - implement flag for departed - known if ATA is present instead of ETA
      lastUpdated: DateTime.now(),
      serviceCode: json['serviceId'] ?? json['serviceID'],
      serviceType: json["serviceType"] ?? "train",
      destination: json['destination'] == null
          ? null
          : PlaceList.fromJson(json['destination']['location'] as List<
              dynamic>), // Location was added in breaking changes with the rollover to the new darwin api abstraction
      origin: json['origin'] == null
          ? null
          : PlaceList.fromJson(json['origin']['location'] as List<dynamic>),
      platform: json['platform'],
      scheduledDepartureTime: json['std'], // TODO: make this nullable
      scheduledArrivalTime: json['sta'],
      // We don't want the estimated departure time to be "On Time", we simply want it to match the scheduled departure time if it is on time
      estDepartureTime: json['etd'].toString().toLowerCase() == "on time" ||
              json['atd'].toString().toLowerCase() == "on time"
          ? json['std']
          : json['etd'] ?? json['atd'], // TODO: make this nullable
      estArrivalTime: json["eta"].toString().toLowerCase() == "on time"
          ? json["sta"]
          : json[
              "eta"], // TODO: Remove this property and replace with a function that calculates the arrival time from the calling points
      operator: json['operator'],
      coaches: json['length'] ??
          (json.containsKey("formation") &&
                  json["formation"]["coaches"] != null &&
                  json["formation"]["coaches"]["coach"] != null
              ? (json["formation"]["coaches"]["coach"] as List<dynamic>)
                  .length
                  .toString()
              : null), // Formation can be stated even if total number of coaches is left blank
      // Additional service key was added in breaking changes with the rollover to the new darwin api abstraction
      callingPoints: json.containsKey('subsequentCallingPoints')
          ? (json['subsequentCallingPoints']['callingPointList']
                  as List<dynamic>)
              .map((list) => (list['callingPoint'] as List<dynamic>)
                  .map((e) => CallingPoint.fromJSON(e))
                  .toList())
              .toList()
          : null,
      previousCallingPoints: json.containsKey('previousCallingPoints')
          ? (json['previousCallingPoints']['callingPointList'] as List<dynamic>)
              .map((list) => (list['callingPoint'] as List<dynamic>)
                  .map((e) => CallingPoint.fromJSON(e))
                  .toList())
              .toList()
          : null,
      delayCancelReason: json["cancelReason"] ?? json["delayReason"],
      departed: hasDepartedYet(
          json['std'] ?? json["sta"] ?? "00:00",
          json['etd'] ??
              json['atd'] ??
              json["eta"] ??
              "00:00"), // TODO: fix (not correct) - Departed the concerned station, json.containsKey('atd')
      formation: json.containsKey("formation") &&
              json["formation"]["coaches"] != null &&
              json["formation"]["coaches"]["coach"] != null
          ? (json["formation"]["coaches"]["coach"] as List<dynamic>)
              .asMap()
              .entries
              .map((entry) {
              int index = entry.key; // The index of the item
              var json = entry.value; // The JSON object

              // Now you can use both the index and the JSON object
              return Coach.fromJSON(json, index);
            }).toList()
          : null,
    );
  }

  bool? scheduledToDepartBeforeOtherService(ServiceSummary otherService) {
    /* Returns true if this service's scheduled departure time is before otherService. Returns false if not. Returns null if unknown*/
    String? scheduledTime1 = scheduledArrivalTime ?? scheduledDepartureTime;
    String? scheduledTime2 = otherService.scheduledArrivalTime ??
        otherService.scheduledDepartureTime;
    if (scheduledTime1 == null || scheduledTime2 == null) return null;
    try {
      int? time1 = int.tryParse(scheduledTime1.replaceAll(":", ""));
      int? time2 = int.tryParse(scheduledTime2.replaceAll(":", ""));
      if (time1 == null || time2 == null) return null;
      return time1! < time2!;
    } catch (e) {
      return null;
    }
  }

  // Are the services the same service (HOWEVER, they may be updated at different points in time)
  bool? isSameService(ServiceSummary service) {
    return serviceCode == null ? null : service.serviceCode == serviceCode;
  }

  static bool hasDepartedYet(String scheduledTime, String estimatedTime) {
    /* 
    This function is SUS and under investigation for being incorrect
    ^ above hopefully fixed!
    */
    //print("Departed yet: $scheduledTime, $estimatedTime");
    int? startTime = int.tryParse(scheduledTime.replaceAll(":", ""));
    int? estTime = (estimatedTime.toLowerCase() == "cancelled" ||
            estimatedTime.toLowerCase() ==
                "on time") // do not use "delayed" here - delayed has 100% not departed
        ? startTime
        : int.tryParse(estimatedTime.replaceAll(":", ""));
    DateTime timestampNow = DateTime.now();
    int? timeNow = int.tryParse(
        "${timestampNow.hour}${timestampNow.minute.toString().padLeft(2, "0")}");
    if (estTime == null || timeNow == null) {
      return false; // Unable to determine since formats do not match expected (ie. likely one time is marked as unknown, not normal though)
    } else if (timeNow - estTime >= 2 && timeNow - estTime <= 1200) {
      return true; // Time now is 2 mins past the estimated departure time, (or timeNow is today and estTime is the day before, and max 4 hours difference)
    } else {
      return false; // endTime - startTime <= 1
    }
  }

  /* Update from the most recent version of this servide fetched from the API */
  void updateFromRecent(ServiceSummary recentService) {
    if (recentService.lastUpdated.millisecondsSinceEpoch <
        lastUpdated.millisecondsSinceEpoch) {
      throw Exception(
          "Service supplied is not more recent, so precedence is wrong");
    }
    // TODO: make efficient not hardcodeed
    callingPoints =
        recentService.callingPoints != null && recentService.callingPoints != []
            ? recentService.callingPoints
            : callingPoints;
    coaches = recentService.coaches ?? coaches;
    delayCancelReason = recentService.delayCancelReason ?? delayCancelReason;
    platform = recentService.platform ?? platform;
    scheduledDepartureTime = recentService.scheduledDepartureTime;
    estDepartureTime = recentService.estDepartureTime;
    estArrivalTime = recentService.estArrivalTime ?? estArrivalTime;
    operator = recentService.operator;
    previousCallingPoints = recentService.previousCallingPoints != null &&
            recentService.previousCallingPoints != []
        ? recentService.previousCallingPoints
        : previousCallingPoints;
    departed = recentService.departed;
    formation = recentService.formation ?? formation;
  }

  static Future<ServiceSummary> fetchServiceByID(String serviceID) async {
    try {
      Map<String, dynamic> json = await _getLiveServiceJson(serviceID);
      return ServiceSummary.fromJson(json);
    } catch (e, s) {
      print("Failed to fetch Service via ServiceID: $e: \n $s");
      throw Exception(
          "Failed to retrieve service data (is the service still able to be fetched?)");
    }
  }

  bool isArrivalOnly(Place userStartStation, Place? userDestinationStation) {
    /* 
    Returns true if the service arrives and terminates at the current station, hence will have no departure attributes
    Note: due to a limitation of api service summary currently, departure times will have placeholders and not be null
    TODO: check this function for problems with circular loop services
    function may not work as intended for splitting services
    */
    return (callingPoints == null ||
            (callingPoints != null && callingPoints!.isEmpty)) &&
        (destination != null && destination!.crsInPlaces(userStartStation.crs));
  }
}

// Exception for when trains are searched for out of the bounds of timeOffset
class ServicesOutOfSearchableBoundsException implements Exception {
  String cause;
  ServicesOutOfSearchableBoundsException(this.cause);
}

class NrccMessage {
  NrccMessage({required this.rawMessage})
      : textMessage = utils
            .stripHTMLTagsFromMessage(rawMessage)
            .replaceAll("&amp;", "&")
            .replaceAll("\n", ""),
        links = utils.returnHTMLLinkURLs(rawMessage).toList();

  final String
      rawMessage; // Raw message as delivered by the api, containing embedded html.

  final String textMessage;
  final List<String> links;
}

class LiveStationBoard {
  final String generatedAtServerSide; // timestamp sent by the server
  final DateTime generatedAt; // Milliseconds since Epoch client-side
  List<DateTime>
      boardGeneratedFrom; // Timestamps sent to the API for when the trains should be generated from (the start of the window)
  final Place station;
  final Place? destination;
  final bool isPlatformInformationAvailable;
  final List<NrccMessage> nrccMessages;
  // Bus, train, ferry services could not exist at a given station. However, the list returned should be empty, not null
  List<ServiceSummary> trains;
  List<ServiceSummary> buses;
  List<ServiceSummary> ferries;

  // Default constructor
  LiveStationBoard({
    required this.generatedAtServerSide,
    required this.generatedAt,
    required this.boardGeneratedFrom,
    required this.station,
    this.destination,
    required this.isPlatformInformationAvailable,
    required this.nrccMessages,
    required this.trains,
    required this.buses,
    required this.ferries,
  });

  factory LiveStationBoard.fromJson(Map<String, dynamic> json,
      {int timeOffset = 0}) {
    /* Where timeOffset is the timeOffset specified when generating the board*/
    return LiveStationBoard(
      generatedAtServerSide: json['generatedAt'],
      generatedAt: DateTime.now(),
      boardGeneratedFrom: [DateTime.now().add(Duration(minutes: timeOffset))],
      station: Place(name: json['locationName'], crs: json['crs']),
      destination: json['filtercrs'] == null
          ? null
          : Place(name: json['filterLocationName'], crs: json['filtercrs']),
      isPlatformInformationAvailable:
          json['isPlatformInformationAvailable'] ?? false,
      nrccMessages: parseNrccMessages(json),
      trains: parseLiveServicesData(json, "trainServices"),
      buses: parseLiveServicesData(json, "busServices"),
      ferries: parseLiveServicesData(json, "ferryServices"),
    );
  }

  int _calculateEarlierTimeOffset({int earlierShift = 30}) {
    /* 
    Calculates the time offset (-120 to 120) for the API call required to get trains the earlierShift from what's currently displayed on the board.
    */
    // Find the minimum time the board was generated for
    DateTime earlierTimestamp;
    if (boardGeneratedFrom.isEmpty) {
      throw Exception("boardGeneratedFrom cannot be empty");
    }
    earlierTimestamp = boardGeneratedFrom[0];
    if (boardGeneratedFrom.length > 1) {
      for (DateTime timestamp in boardGeneratedFrom.sublist(1)) {
        if (timestamp.millisecondsSinceEpoch <
            earlierTimestamp.millisecondsSinceEpoch) {
          earlierTimestamp = timestamp;
        }
      }
    }
    // Since we're in the future after it was generated, find the difference between now and the timestamps
    int millisecondsDifference = earlierTimestamp.millisecondsSinceEpoch -
        DateTime.now().millisecondsSinceEpoch;
    int timeOffset = (millisecondsDifference ~/ (1000 * 60)) -
        earlierShift; // ~/ integer division
    print("Time offset: $timeOffset");
    if (timeOffset <= -150) {
      throw ServicesOutOfSearchableBoundsException(
          "Departure board is already generated as early as possible");
    } else if (timeOffset < -120) {
      timeOffset =
          -120; // -120 is the lowest bound allowed for the timeOffset in the NRE API.
    } else if (timeOffset > 120) {
      throw ServicesOutOfSearchableBoundsException(
          "Departure board is stale, and generating earlier is too far in the future");
    }
    return timeOffset;
  }

  bool _isTimeGreater(String time1, String time2) {
    // Returns time1 > time2. note, do not use this function unless you intend for consec-day mignight detection to take place.
    // Times must be a maximum of 4 hours apart (using 5 in code for tolerance)
    int HOURS_TOLERANCE =
        5; // hours difference. If exceeded, assume they are on separate days
    List<String> hoursAndMins1 = time1.split(":");
    List<String> hoursAndMins2 = time2.split(":");
    // If it fails to parse, exit to avoid errors
    if (hoursAndMins1.length != 2 || hoursAndMins2.length != 2) {
      // "Scheduled departure time does not have correct fromat and could not be parsed"
      throw const FormatException("Time is in wrong format");
    }
    // Parse more
    int? hours1 = int.tryParse(hoursAndMins1[0]);
    int? mins1 = int.tryParse(hoursAndMins1[1]);
    int? hours2 = int.tryParse(hoursAndMins2[0]);
    int? mins2 = int.tryParse(hoursAndMins2[1]);
    // If it fails, string was used in time, so fail
    if (hours1 == null || mins1 == null || hours2 == null || mins2 == null) {
      throw const FormatException(
          "Time contains string characters aside from ':', rendering the format invalid.");
    }
    // TRUE: time1 greater (later), FALSE: time2 greater (later than or equal to)
    // midnight detection is sub <= 18
    // Hour 1 is greater AND hour1 and hour2 are in the same day (ie. not 23:59 and 00:01)
    if (hours1 > hours2 && hours1 - hours2 <= HOURS_TOLERANCE) return true;
    // Detected as not on same day: ie. 23:59 and 00:01
    if (hours1 > hours2 && hours1 - hours2 > HOURS_TOLERANCE) return false;
    // Same as above but swapped
    if (hours2 > hours1 && hours2 - hours1 <= HOURS_TOLERANCE) return false;
    // Same as above but swapped
    if (hours2 > hours1 && hours2 - hours1 > HOURS_TOLERANCE) return true;
    // Hours were equal, so we need to check the mins
    return mins1 > mins2;
  }

  DateTime _getLastGenerateStartWindow() {
    // Gets the latest time at which the board was generated from (the time at the start of the window, not the time the API call was made)
    if (boardGeneratedFrom.isEmpty) {
      throw Exception("boardGeneratedFrom cannot be empty");
    }
    if (boardGeneratedFrom.length == 1) {
      return boardGeneratedFrom[0];
    }

    DateTime lastDateTime = boardGeneratedFrom[0];
    for (DateTime dateTime in boardGeneratedFrom.sublist(1)) {
      if (dateTime.isAfter(lastDateTime)) {
        lastDateTime = dateTime;
      }
    }
    return lastDateTime;
  }

  String _dateTimeToHHMM(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String getTimeRangeStart() {
    /* 
    Gets the start of the time range for which services are displayed between, in format hh:mm
    */
    if (boardGeneratedFrom.isEmpty) {
      throw Exception("boardGeneratedFrom cannot be empty");
    }
    if (boardGeneratedFrom.length == 1) {
      return _dateTimeToHHMM(boardGeneratedFrom[0]);
    }

    DateTime earliestTime = boardGeneratedFrom[0];
    for (DateTime dateTime in boardGeneratedFrom.sublist(1)) {
      if (dateTime.isBefore(earliestTime)) {
        earliestTime = dateTime;
      }
    }
    return _dateTimeToHHMM(earliestTime);
  }

  String? getTimeRangeEnd() {
    /* Do not use this function for exact-use functionality. It is deemed for information only and not all edge-cases are guaranteed to be perfectly handled.
    It relies on assumptions based on other code logic functioning as when this function was tested, and the API also functioning as intended. 
    Known issues may cause errors. This function returns null if an error occurred and it cannot be calculated
    Returns the time at the end of the window for which services are displayed */
    try {
      List<String> lastServiceTimes =
          []; // Times in HH:MM at which the last service departs (of each type, where on station board)
      // Note, errors can be thrown below due to known issues
      void addToLastServiceTimes(List<ServiceSummary> services) {
        if (services.isNotEmpty &&
            (services.last.estArrivalTime != null ||
                services.last.estDepartureTime != null) &&
            (services.last.scheduledArrivalTime != null ||
                services.last.scheduledDepartureTime != null)) {
          lastServiceTimes.add(_isTimeGreater(
            (services.last.estArrivalTime ?? services.last.estDepartureTime)!,
            (services.last.scheduledArrivalTime ??
                services.last.scheduledDepartureTime)!,
          )
              ? (services.last.estArrivalTime ??
                  services.last.estDepartureTime)!
              : (services.last.scheduledArrivalTime ??
                  services.last.scheduledDepartureTime)!);
        }
      }

      addToLastServiceTimes(trains);
      addToLastServiceTimes(buses);
      addToLastServiceTimes(ferries);
      // if (trains.isNotEmpty &&
      //     (trains.last.estArrivalTime != null ||
      //         trains.last.estDepartureTime != null) &&
      //     (trains.last.scheduledArrivalTime != null ||
      //         trains.last.scheduledDepartureTime != null)) {
      //   lastServiceTimes.add(_isTimeGreater(
      //     (trains.last.estArrivalTime ?? trains.last.estDepartureTime)!,
      //     (trains.last.scheduledArrivalTime ??
      //         trains.last.scheduledDepartureTime)!,
      //   )
      //       ? (trains.last.estArrivalTime ?? trains.last.estDepartureTime)!
      //       : (trains.last.scheduledArrivalTime ??
      //           trains.last.scheduledDepartureTime)!);
      // }
      // if (buses.isNotEmpty) {
      //   lastServiceTimes.add(_isTimeGreater(
      //           buses.last.estArrivalTime ?? buses.last.estDepartureTime,
      //           buses.last.scheduledArrivalTime ??
      //               buses.last.scheduledDepartureTime)
      //       ? buses.last.estArrivalTime ?? buses.last.estDepartureTime
      //       : buses.last.scheduledArrivalTime ??
      //           buses.last.scheduledDepartureTime);
      // }
      // if (ferries.isNotEmpty) {
      //   lastServiceTimes.add(_isTimeGreater(
      //           ferries.last.estArrivalTime ?? ferries.last.estDepartureTime,
      //           ferries.last.scheduledArrivalTime ??
      //               ferries.last.scheduledDepartureTime)
      //       ? ferries.last.estArrivalTime ?? ferries.last.estDepartureTime
      //       : ferries.last.scheduledArrivalTime ??
      //           ferries.last.scheduledDepartureTime);
      // }
      // No services on the board
      if (lastServiceTimes.isEmpty) {
        // Get the last time the board was generated from, add 2 hours.
        // Note: This assumes the later services button was hidden if no services were returned.
        DateTime endWindowTimestamp = _getLastGenerateStartWindow()
            .add(const Duration(hours: 2)); // API time window is 2 hours
        return _dateTimeToHHMM(endWindowTimestamp);
      }
      // Only one set of services
      if (lastServiceTimes.length == 1) {
        return lastServiceTimes[0];
      }
      // Greater than one time;
      String lastTime = lastServiceTimes[0];
      for (String compareToTime in lastServiceTimes.sublist(1)) {
        if (_isTimeGreater(compareToTime, lastTime)) {
          lastTime = compareToTime;
        }
      }
      return lastTime;
    } catch (e) {
      print("getTimeRangeEnd() failed to calculate: $e");
      return null;
    }
  }

  int _calculateLaterTimeOffset() {
    /* 
    Calculates the time offset (-120 to 120) for the API call required to get trains after the last train on the board
    */
    int FALLBACK_IF_FAILS =
        0; // the fallback if this fails to calculate a reasonable number for no discernable reason
    List<ServiceSummary> services = mergeServiceLists(trains, buses);
    services = mergeServiceLists(services, ferries);
    if (services.isEmpty) {
      // If there are no trains in the next two hours, we can only load trains +- 2 hours. So, if there are none loaded from one initial API call, we can't load any more
      throw ServicesOutOfSearchableBoundsException(
          "There were no services originally within the specified time frame, and the API can be searched no later than that timeframe");
    }
    // Find the time of the latest train
    String lastTrainTime = trains[trains.length - 1].scheduledDepartureTime ??
        trains[trains.length - 1].scheduledArrivalTime ??
        "00:00"; // TODO: BUG where this is null in API and would default to Unknown or ?? in parsing
    List<String> hoursAndMins = lastTrainTime.split(":");
    // If it fails to parse, exit to avoid errors
    if (hoursAndMins.length != 2) {
      // "Scheduled departure time does not have correct fromat and could not be parsed"
      return FALLBACK_IF_FAILS; // Load from current time (default fallback option)
    }
    // Parse more
    int? hours = int.tryParse(hoursAndMins[0]);
    int? mins = int.tryParse(hoursAndMins[1]);
    // If this fails, exit again
    if (hours == null || mins == null) {
      // Strings supplied instead of ints
      return FALLBACK_IF_FAILS;
    }

    DateTime now = DateTime.now();
    // Finds a datetime object for the last train
    // Note: the day may be the wrong day here, so make sure to take this into account later (train lists going over midnight)
    DateTime trainTimeToday =
        DateTime(now.year, now.month, now.day, hours, mins);
    // Now calculate the difference
    int minsDifference =
        (trainTimeToday.millisecondsSinceEpoch - now.millisecondsSinceEpoch) ~/
            (1000 * 60);
    if (0 <= minsDifference && minsDifference <= 120) {
      return minsDifference;
    }
    // Fixes for assuming the times were on the same day
    if (minsDifference > 120) {
      // This occurs when the train time was ie 23:59, and the time now is 00:01
      minsDifference -= 1440;
    }
    if (minsDifference < 120) {
      // This occurs when the train time is ie. 00:01 and the current time is 23:59
      minsDifference += 1440;
    }
    if (0 <= minsDifference && minsDifference <= 120) {
      return minsDifference;
    } else {
      // Issue failed to be resolved
      print(
          "Warning: mins difference failed to be resolved so loading default value. Default fallbackL $FALLBACK_IF_FAILS, calculated value: $minsDifference");
      return FALLBACK_IF_FAILS;
    }
  }

  Future<void> addEarlierServices(String startStation, String? destination,
      {int minutes = 30}) async {
    /* Add services from mins before the departure board has been generated from 
    Setting minutes too high may result in services being missed due to the NRE cap of 150 servides for a departure board with no details
    Returns false if operation was unsuccessful 
    */
    int timeOffset = _calculateEarlierTimeOffset(earlierShift: minutes);

    LiveStationBoard board2 = await fetchLiveDepartureBoard(
      startStation,
      destination,
      timeOffset: timeOffset,
      withDetails: false,
    );
    mergeWith(board2);
  }

  Future<bool> addLaterServices(
      String startStation, String? destination) async {
    /* 
    Takes later services from the time of the last train departing on the board (loaded).
    If no. of services returned = max, then there are still future services which can be loaded, so function returns TRUE.
    If not, it returns FALSE.
    */
    int timeOffset = _calculateLaterTimeOffset();

    LiveStationBoard board2 = await fetchLiveDepartureBoard(
        startStation, destination,
        timeOffset: timeOffset,
        withDetails:
            false); // do not change with details (must be FALSE) otherwise the constants used here will breal
    mergeWith(board2);
    return board2.trains.length + board2.buses.length + board2.ferries.length >=
        MAX_NUMBER_SERVICES_RETURNED_NO_DETAILS_DEPARTURE_BOARD;
  }

  // debugging note to self: serviceToCheck is (normally) service with details, serviceList is the longer list, ie. one without details
  bool _listContainsService(
      List<ServiceSummary> serviceList, ServiceSummary serviceToCheck,
      {bool mergeServices = false}) {
    /* Note: services do not necessarily contain service codes, so it may be impossible to determine. If this is the case, false will be returned*/
    for (int i = 0; i < serviceList.length; i++) {
      // ServiceSummary service in serviceList
      if (serviceList[i].isSameService(serviceToCheck) == true) {
        if (mergeServices) {
          // TODO: check this actually works
          if (serviceList[i].lastUpdated.millisecondsSinceEpoch <
              serviceToCheck.lastUpdated.millisecondsSinceEpoch) {
            //print("A");
            serviceList[i].updateFromRecent(serviceToCheck);
          } else {
            //print("B");
            //print(
            //    "Service (BEFORE) - Time: ${serviceList[i].scheduledDepartureTime}, RecentCallingPoints: ${serviceList[i].callingPoints}, ExistingCallingPoints: ${serviceList[i].callingPoints}");
            serviceToCheck.updateFromRecent(serviceList[i]);
            serviceList[i] = serviceToCheck;
            //print(
            //    "Service (AFTER) - Time: ${serviceList[i].scheduledDepartureTime}, RecentCallingPoints: ${serviceList[i].callingPoints}, ExistingCallingPoints: ${serviceList[i].callingPoints}");
          }
        }
        return true;
      }
    }
    return false;
  }

  List<ServiceSummary> mergeServiceLists(
      List<ServiceSummary> serviceList1, List<ServiceSummary> serviceList2) {
    /* Merge services list in order 
    Do not use this function if you can guarantee both lists are sorted and do not overlap
    */
    List<ServiceSummary> shorterList;
    List<ServiceSummary> longerList;
    // Finding shorter and longer lists is key for efficiency of the merge
    if (serviceList1.length < serviceList2.length) {
      shorterList = List.from(serviceList1);
      longerList = List.from(serviceList2);
    } else {
      shorterList = List.from(serviceList2);
      longerList = List.from(serviceList1);
    }
    for (ServiceSummary serviceSummary in shorterList) {
      // Merge the services if multiple instances. Add if not.
      if (!_listContainsService(longerList, serviceSummary,
          mergeServices: true)) {
        bool inserted = false;
        for (int i = 0; i < longerList.length; i++) {
          if (serviceSummary
                  .scheduledToDepartBeforeOtherService(longerList[i]) ==
              true) {
            longerList.insert(i, serviceSummary);
            inserted = true;
            break;
          }
        }
        if (!inserted) {
          longerList.add(serviceSummary);
        }
      }
    }
    return longerList;
  }

  void mergeWith(LiveStationBoard departureBoard2, {int? precedenceOverride}) {
    /* Merge services with those on a second departure board. Must be from the same station (however an error WILL NOT be thrown if this is the case)
    Note: This supports both types of departure boards - with or without details. Services will therefore be a mix of both when merged.
    precedenceOverride determines which service's attributes are used in priority if two services of the same ID are present in both departure boards:
    - 1: Use the service from this departure board
    - 2: Use the service from departureBoard2
    If precedence override is not set, the precedence is determined by the service generated last.
     */
    if (precedenceOverride != null && ![1, 2].contains(precedenceOverride)) {
      throw Exception("Precedence must be null, 1 or 2");
    }
    int servicePrecedence = precedenceOverride ??
        (departureBoard2.generatedAt.millisecondsSinceEpoch >
                generatedAt.microsecondsSinceEpoch
            ? 2
            : 1);
    // TODO: bug with ordering when trains are different sides of midnight
    // TODO: better implementation in future, as described above. Below temporary solution for testing purposes
    trains = mergeServiceLists(trains, departureBoard2.trains);
    buses = mergeServiceLists(buses, departureBoard2.buses);
    ferries = mergeServiceLists(ferries, departureBoard2.ferries);
    // trains.addAll(departureBoard2.trains);
    // buses.addAll(departureBoard2.buses);
    // ferries.addAll(departureBoard2.ferries);
    boardGeneratedFrom.addAll(departureBoard2.boardGeneratedFrom);
  }

  static Future<LiveStationBoard> fetchLiveDepartureBoard(
      String startStation, String? destination,
      {bool withDetails = true, int timeOffset = 0}) async {
    try {
      Map<String, dynamic> json = await _getLiveStationBoardJson(
          startStation, destination,
          withDetails: withDetails, timeOffset: timeOffset);
      return LiveStationBoard.fromJson(json, timeOffset: timeOffset);
    } catch (e, s) {
      print("Error: ${e}\nStacktrace: ${s}");
      throw Exception("Failed to get live trains data, error: ${e}");
    }
  }
}

List<NrccMessage> parseNrccMessages(Map<String, dynamic> json) {
  /*
  Where json is the complete station board json
  */
  try {
    List<NrccMessage> messages = [];
    // Validation: If there are no nrccMessages, the api returns an empty object, so we need to check for this
    if (json["nrccMessages"] == null ||
        json["nrccMessages"] == {} ||
        json["nrccMessages"]["message"] == null ||
        json["nrccMessages"]["message"] == {}) {
      return messages;
    }

    // Additional service key was added in breaking changes with the rollover to the new darwin api abstraction
    for (var message in json['nrccMessages']['message']) {
      try {
        messages.add(NrccMessage(rawMessage: message));
      } catch (e, s) {
        print("Error, failed to add certain message: ${e}\nStacktrace: ${s}");
        print("Message: ${message}");
      }
    }
    return messages;
  } catch (e, s) {
    print("Error: ${e}\nStacktrace: ${s}");
    throw Exception("Failed to parse nrcc data, error: ${e}");
  }
}

List<ServiceSummary> parseLiveServicesData(
    Map<String, dynamic> json, String serviceDataKey) {
  /*
  Where json is the complete station board json, and the serviceDataKey is the key in the data that contains the relevant services, ie: trainServices, busServices, ferryServices
  */

  // Validation for invalid service data keys
  if (serviceDataKey != "trainServices" &&
      serviceDataKey != "busServices" &&
      serviceDataKey != "ferryServices") {
    throw Exception(
        "Invalid service data key provided for this endpoint, must be one of: trainServices, busServices, ferryServices");
  }
  // If there are no services of that type, the api returns an empty object, so we need to check for this
  if (json[serviceDataKey] == null ||
      json[serviceDataKey] == {} ||
      json[serviceDataKey]["service"] == null ||
      json[serviceDataKey]["service"] == {}) {
    return [];
  }

  try {
    List<ServiceSummary> services = [];
    // If there are no trains, the api returns an empty object, so we need to check for this
    if (json[serviceDataKey] == null ||
        json[serviceDataKey] == {} ||
        json[serviceDataKey]["service"] == null ||
        json[serviceDataKey]["service"] == {}) {
      return services;
    }
    // Additional service key was added in breaking changes with the rollover to the new darwin api abstraction
    for (var service in json[serviceDataKey]['service']) {
      try {
        services.add(ServiceSummary.fromJson(service));
      } catch (e, s) {
        print("(2) Error, failed to add certain train: ${e}\nStacktrace: ${s}");
        print("Train: ${service}");
      }
    }
    return services;
  } catch (e, s) {
    print("Error: ${e}\nStacktrace: ${s}");
    throw Exception("Failed to parse live trains data, error: ${e}");
  }
}

@Deprecated(
    "Fetch the entire departure board instead, and filter the results for public facing actions. To retrieve only the trains, use the new generic for all service types function")
Future<List<ServiceSummary>> getLiveTrainsData(
    String startStation, String? destination) async {
  try {
    Map<String, dynamic> json =
        await _getLiveStationBoardJson(startStation, destination);
    print(json);
    List<ServiceSummary> trains = [];
    // If there are no trains, the api returns an empty object, so we need to check for this
    if (json["trainServices"] == null ||
        json["trainServices"] == {} ||
        json["trainServices"]["service"] == null ||
        json["trainServices"]["service"] == {}) {
      return trains;
    }
    // Additional service key was added in breaking changes with the rollover to the new darwin api abstraction
    for (var train in json['trainServices']['service']) {
      try {
        trains.add(ServiceSummary.fromJson(train));
      } catch (e, s) {
        print("(1) Error, failed to add certain train: ${e}\nStacktrace: ${s}");
        print("Train: ${train}");
      }
    }
    return trains;
  } catch (e, s) {
    print("Error: ${e}\nStacktrace: ${s}");
    throw Exception("Failed to get live trains data, error: ${e}");
  }
}
