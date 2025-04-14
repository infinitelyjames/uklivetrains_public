import 'package:flutter/material.dart';
import 'package:uklivetrains/data/station_codes.dart';
import 'package:uklivetrains/modules/utils.dart' as utils;
import 'package:uklivetrains/modules/api.dart' as api;
import 'package:uklivetrains/pages/routes/train.dart';
import 'package:uklivetrains/structs/callingpoint.dart';
import 'package:uklivetrains/structs/place.dart';
import 'package:uklivetrains/structs/service.dart';
import 'package:uklivetrains/structs/stationboardquery.dart';
import 'package:uklivetrains/widgets/service/attribute.dart';
import 'package:uklivetrains/widgets/general/checkboxpopup.dart';
import 'package:uklivetrains/widgets/textboxes/infobox.dart' as infobox;
import 'package:uklivetrains/widgets/textboxes/errorbox.dart' as errorbox;
import 'package:uklivetrains/widgets/textboxes/loadingbox.dart';
import 'package:uklivetrains/widgets/notification/notificationblob.dart';
import 'package:uklivetrains/widgets/notification/notificationicon.dart';
import 'package:uklivetrains/widgets/sheets/nrccMsgsSheet.dart';
import 'package:uklivetrains/widgets/general/segmentedbuttonselection.dart';
import 'package:uklivetrains/widgets/user-input/stationentrydropdown.dart';
import 'package:uklivetrains/widgets/textboxes/warningbox.dart';

/* ToDo
-> Service disruption area
-> Dropdown list of stations, validating the name
-> All interactivity
-> Make the UI look better: 
  - Make Train widget more attractive - move text-based stuff into individual icons with a number next to them

*/

const int MAX_DETAILED_SERVICES_RETURNED =
    10; // the maximum number of details services that can be returned

const textFieldStyle = TextStyle(fontFamily: 'Roboto', fontSize: 15);

// Wrapper class as a return type to just hold data about a train
class UserTrainStopsDetails {
  UserTrainStopsDetails(this.timeTaken, this.stopNumber, this.arrivalTime);

  final int stopNumber;
  final int timeTaken;
  final String arrivalTime;
}

// Gets the details to do with a live journey from point A to point B
// Note: subsequentCallingPoints may have multiple lists of calling points due to trains dividing
UserTrainStopsDetails? getTrainJourneyDetails(
    String startTime,
    List<List<CallingPoint>> subsequentCallingPoints,
    String destinationCRSCode) {
  // NOTE: startTime MUST BE the estimated departure time, not the scheduled departure time
  if (startTime.toLowerCase() == "delayed" ||
      startTime.toLowerCase() == "cancelled") return null;
  int stopNumber = 0;
  // Iterate through calling point lists (for train split)
  for (List<CallingPoint> callingPointList in subsequentCallingPoints) {
    for (CallingPoint callingPoint in callingPointList) {
      stopNumber++;
      if (callingPoint.crs.toLowerCase() == destinationCRSCode.toLowerCase()) {
        // Found the destination, but we still need to check an edge case if the train has been cancelled and the destination is not reached
        if (callingPoint.estimatedTime.toLowerCase() == "cancelled" ||
            callingPoint.estimatedTime.toLowerCase() == "delayed" ||
            callingPoint.estimatedTime.length != 5) {
          // The train has been cancelled, so we can't get the time taken, or the train is simply "delayed"
          return null;
        }
        // The train has not been cancelled (etc), so we can get the time taken
        int journeyTime = utils.getMinutesTimeDifference(
            startTime, callingPoint.estimatedTime);
        // If the journey takes place overnight, the time delta will be negative so needs fixing
        if (journeyTime < 0) journeyTime += 1440;

        return UserTrainStopsDetails(
            journeyTime, stopNumber, callingPoint.estimatedTime);
      }
    }
  }
  return null;
}

class IndividualServiceSummary extends StatelessWidget {
  // Properties set from the constructor
  // ToDo - train delay and cancellation reasons
  final Service service;
  // final PlaceList?
  //     destination; // The train's destination(s), not the user's (train may split)
  // final String? platform;
  // final String scheduledDepartureTime;
  // final Place userStartStation;
  // final Place?
  //     userDestinationStation; // User may not have specified a destination, instead, just requesting all trains from a station
  // final String estDepartureTime;
  // final String operator;
  // final String? coaches;
  // final List<List<CallingPoint>>? callingPoints;
  List<Widget> descriptionWidgets =
      []; // Description is displayed on the left side of the train summary container
  List<Widget> timesWidgets =
      []; // Times are displayed on the right side of the train summary container
  final EdgeInsets widgetMargin;
  //final String? serviceCode;
  // Properties calculated from the constructor
  String? _estArrivalTime;
  int? _numberOfStops;
  int? _timeTaken;
  // ToDO - will need trainID to be passed in, but functionality not implemented yet
  /* IMPORTANT
  -> This widget will change if the user specifies a destination or not. If they do, then the calling points will be displayed, otherwise they won't.
  -> This widget will be modified depending on the BuildContext - route buttons cannot be added in the constructor
  */

  // Repackage an api.ServiceSummary object into this. This object additionaly contains start and destination CRS codes.
  factory IndividualServiceSummary.fromAPIServiceSummary(
      api.ServiceSummary serviceSummary,
      Place userStartStation,
      Place? userDestinationStation) {
    Service service = Service.fromAPIServiceSummary(serviceSummary);
    service.userStartStation = userStartStation;
    service.userDestinationStation = userDestinationStation;
    return IndividualServiceSummary(service: service);
  }

  IndividualServiceSummary({
    Key? key,
    required this.service,
    this.widgetMargin = const EdgeInsets.fromLTRB(0, 4, 0, 4),
  }) : super(key: key) {
    // Get some more summary details by analysing the calling points
    //print("Getting train journey details");
    if (service.subsequentCallingPoints != null &&
        service.userDestinationStation != null &&
        service.estDepartureTime != null) {
      final trainJourneyDetails = getTrainJourneyDetails(
          service.estDepartureTime!,
          service.subsequentCallingPoints!,
          service.userDestinationStation!.crs);
      if (trainJourneyDetails != null) {
        //print("Train journey details not null");
        //print("Time taken: ${trainJourneyDetails.timeTaken}");
        _timeTaken = trainJourneyDetails.timeTaken;
        _numberOfStops = trainJourneyDetails.stopNumber;
        _estArrivalTime = trainJourneyDetails.arrivalTime;
      }
    }
  }

  Widget _getAttributeContainer(BuildContext context, String label) {
    return AttributeWidget(label: label);
  }

  void _setTrainDescription(BuildContext context) {
    // Important: This accounts only for what is the left side of the train summary container (destination, operator, etc) which DOES NOT include the times
    descriptionWidgets = [];
    descriptionWidgets.add(Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (service.doesTerminateHere())
          const Text(
            "from",
            style: TextStyle(fontSize: 14, height: 1.0),
          ),
        if (service.doesTerminateHere()) const SizedBox(width: 3),
        Text(
            service.doesTerminateHere()
                ? service.origin != null
                    ? service.origin!.name
                    : 'unknown'
                : service.destination == null
                    ? "unknown"
                    : service.destination!.name,
            style: const TextStyle(fontSize: 18, height: 1.0)),
        if (service.platform != null ||
            (service.serviceType != "train" && service.serviceType != null))
          Container(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: NotificationBlob(
                label:
                    service.platform != null && service.serviceType == "train"
                        ? "Platform ${service.platform}"
                        : service.serviceType != null
                            ? utils.capitalizeFirstLetter(service.serviceType!)
                            : "Service"),
          ),
        if (service.destination != null && service.destination!.via != null)
          const SizedBox(
              width: double.infinity), // force the via onto a newline
        if (service.destination != null && service.destination!.via != null)
          Text(
            service.destination!.via!,
            style: TextStyle(fontSize: 14, height: 1.0),
          ),
      ],
    ));
    List<Widget> attributeWidgets = [];
    // Calling points
    if (_numberOfStops != null && _timeTaken != null) {
      // If the user has specified a destination, then details about the calling points and the time taken for the journey will be displayed
      attributeWidgets.add(_getAttributeContainer(context,
          "$_numberOfStops ${_numberOfStops == 1 ? 'stop' : 'stops'}"));
      attributeWidgets.add(_getAttributeContainer(context, "$_timeTaken mins"));
      /*print("Getting train journey details");
      final trainJourneyDetails = getTrainJourneyDetails(
          estDepartureTime, callingPoints!, userDestinationStationCRS!);
      if (trainJourneyDetails != null) {
        descriptionWidgets.add(Text(
            "${trainJourneyDetails.stopNumber} stops, ${trainJourneyDetails.timeTaken} minutes"));
      }*/
    }
    // Operator and coaches
    if (service.operator != null) {
      attributeWidgets.add(_getAttributeContainer(context, service.operator!));
    }
    if (service.coaches != null) {
      attributeWidgets
          .add(_getAttributeContainer(context, "${service.coaches} coaches"));
    }
    // Arrivals
    if (service.doesTerminateHere()) {
      attributeWidgets.add(_getAttributeContainer(context, "Terminates here"));
    }
    // Add them all
    descriptionWidgets.add(const SizedBox(height: 2.5));
    descriptionWidgets.add(Wrap(
      children: attributeWidgets,
    ));
  }

  // For departure and arrival times on the right side of the train summary container
  void _setTimesWidgets(BuildContext context) {
    timesWidgets = [];
    timesWidgets.add(_getDepartureTimesWidget(context));
    if (_estArrivalTime != null) {
      //("adding arrival time");
      timesWidgets.add(Text("arrives $_estArrivalTime"));
    }
  }

  // Function for when the widget is tapped
  Function()? _getOnTapFunction(BuildContext context) {
    return () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TrainRoute(
                    service: service,
                  )));
    };
  }

  // Setup the routing for a new page of train details when the train is clicked on
  @Deprecated("Deprecated upon entire widget migration to clickable")
  TextButton _getClickRouteButton(BuildContext context) {
    return TextButton(
        onPressed: _getOnTapFunction(context), child: const Text("More info"));
  }

  // This is part of the right side of the train summary container, and displays the departure times, but NOT responsible for the arrival time
  Widget _getDepartureTimesWidget(BuildContext context) {
    /* Note: isArrivalOnly determines if the train arrives and terminates
    It will not trigger if a departure time is not specified. Therefore, you still need to do null checks on the departure time.
    This is because a train may stop to drop-off passengers only, ie. Watford Junction.
    */
    // if (((service.scheduledDepartureTime == null ||
    //             service.estDepartureTime == null) ) ||
    //     ((service.scheduledArrivalTime == null ||
    //             service.estArrivalTime == null))) {
    //   throw Exception("Cannot generate when associated variables are null");
    // }
    String schTime, estTime;
    if (service.doesTerminateHere()) {
      schTime = service.scheduledArrivalTime ?? "--:--";
      estTime = service.estArrivalTime ?? "--:--";
    } else {
      schTime = service.scheduledDepartureTime ?? (service.scheduledArrivalTime != null ? "${service.scheduledArrivalTime}a": "--:--");
      estTime = service.estDepartureTime ?? (service.estArrivalTime != null ? "${service.estArrivalTime}a": "--:--");
    }
    // Controls whether the departure time has been changed from the scheduled time - if it has, then it will be displayed in red with a strikethrough
    if (schTime != estTime) {
      return Row(children: [
        Text(schTime,
            style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(0, 0, 0, 0.7): const Color.fromRGBO(255, 255, 255, 0.7) )),
        Text(estTime, style: TextStyle(fontSize: 23, color: Colors.red)),
      ]);
    } else {
      return Text(schTime, style: TextStyle(fontSize: 23));
    }
  }

  // Todo - implement counter for number of stops between start and destination of where the user is travelling between
  @override
  Widget build(BuildContext context) {
    _setTimesWidgets(context);
    _setTrainDescription(context);
    return GestureDetector(
      onTap: _getOnTapFunction(context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        margin: widgetMargin,
        decoration: BoxDecoration(
          border: service.departedYet == true
              ? Border.all(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  width: 1.5)
              : Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              bottomRight: Radius.circular(15)),
          color: service.departedYet == true
              ? (Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(228, 228, 228, 0.5): const Color.fromRGBO(32, 32, 32, 0.5))
              : (Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(228, 228, 228, 0.69): const Color.fromRGBO(32, 32, 32, 0.69)),
        ),
        child: Row(children: [
          // Left side of the train summary container
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: descriptionWidgets,
            ),
          ),
          // Right side of the train summary container, button addded for new train
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  timesWidgets), // children: [...timesWidgets, _getClickRouteButton(context)]),
        ]),
      ),
    );
  }
}

// Todo - convert to stateful widget
class LiveTrainsRoutePage extends StatefulWidget {
  LiveTrainsRoutePage({
    super.key,
    required this.startStationCRS,
    this.destinationStationCRS,
  });
  String startStationCRS;
  String? destinationStationCRS;

  @override
  State<LiveTrainsRoutePage> createState() => _LiveTrainsRoutePageState();
}

class _LiveTrainsRoutePageState extends State<LiveTrainsRoutePage>
    with AutomaticKeepAliveClientMixin<LiveTrainsRoutePage> {
  // ToDo - work on keeping the page state when switching between tabs
  @override
  bool get wantKeepAlive => true;

  late final String _startStationCRS;
  late final String? _destinationStationCRS;
  // V2 - Using board
  api.LiveStationBoard? _liveDepartureBoard;
  List<Widget>? _liveTrainsWidgets;
  List<Widget>? _liveBusesWidgets;
  List<Widget>? _liveFerriesWidgets;
  List<Widget>? _liveNrccMessagesWidgets; // ToDo implement loader
  @Deprecated(
      "Used by old methodology (before implementation of pageview for scrolling between different service types).")
  Widget?
      _liveServicesWidget; // contains liveTrains, buses and ferries + nrcc messages (TODO - or maybe separately)
  int _serviceTypeDisplayed =
      0; // determines if it is diplaying live trains, live buses, or live ferries: CONSTRAINT 0-2
  bool earlierServicesFetchable =
      true; // Denotes if any earlier services can be fetched (set to false when travelled far enough in the past)
  bool laterServicesFetchable = true;
  final PageController _serviceTypePageController = PageController();
  List<bool> _serviceTypesFiltered = [true, true]; // Departures, Arrivals
  // TODO - make above load from saved, and option in initial search

  @override
  void initState() {
    super.initState();
    _startStationCRS = widget.startStationCRS;
    _destinationStationCRS = widget.destinationStationCRS;

    _setAndBuildServicesContainer(
        _startStationCRS, _destinationStationCRS, true);

    // add a listener for the pageview being swiped L/R since segmented buttons need to be updated
    _serviceTypePageController.addListener(() => _onPageViewSwiped());
  }

  bool showArrivals() {
    return _serviceTypesFiltered[1];
  }

  bool showDepartures() {
    return _serviceTypesFiltered[0];
  }

  StationBoardQuery _getStationBoardQuery() {
    return StationBoardQuery(
        startStation: Place(
            crs: _startStationCRS,
            name: STATION_CODES_INVERTED[_startStationCRS] ?? "??"),
        destinationStation: _destinationStationCRS == null
            ? null
            : Place(
                crs: _destinationStationCRS!,
                name: STATION_CODES_INVERTED[_destinationStationCRS!] ?? "??"),
        serviceTypesFiltered: _serviceTypesFiltered);
  }

  void _goToServiceTypePage(int pageIndex) {
    /* 
    0: trains
    1: buses
    2: ferries
    */
    if (pageIndex < 0 || pageIndex > 2) {
      throw Exception("Invalid pageIndex argument: must be between 0 and 2");
    }

    // Go to the page
    _serviceTypePageController.animateToPage(pageIndex,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

    _serviceTypeDisplayed = pageIndex;
  }

  void _onPageViewSwiped() {
    int newPageIndex = _serviceTypePageController.page!.round();
    if (newPageIndex != _serviceTypeDisplayed) {
      setState(() {
        //print("Setting _serviceTypeDisplayed to $newPageIndex");
        _serviceTypeDisplayed = newPageIndex;
      });
    }
  }

  Future<api.LiveStationBoard>? _fetchDepartureBoard(
      String startStationCRS, String? destinationStationCRS) async {
    return await api.LiveStationBoard.fetchLiveDepartureBoard(
        startStationCRS, destinationStationCRS);
  }

  List<Widget> _buildServiceContainer(Place userStartStation,
      Place? userDestinationStation, List<api.ServiceSummary> services) {
    List<Widget> widgets = [];
    for (var service in services) {
      if (service.isArrivalOnly(userStartStation, userDestinationStation) &&
              showArrivals() ||
          !service.isArrivalOnly(userStartStation, userDestinationStation) &&
              showDepartures()) {
        widgets.add(IndividualServiceSummary.fromAPIServiceSummary(
            service, userStartStation, userDestinationStation));
      }
    }
    return widgets;
  }

  List<Widget> _buildTrainServicesContainer(
      Place userStartStation, Place? userDestinationStation) {
    if (_liveDepartureBoard == null) return [];
    return _buildServiceContainer(
        userStartStation, userDestinationStation, _liveDepartureBoard!.trains);
  }

  List<Widget> _buildBusServicesContainer(
      Place userStartStation, Place? userDestinationStation) {
    if (_liveDepartureBoard == null) return [];
    return _buildServiceContainer(
        userStartStation, userDestinationStation, _liveDepartureBoard!.buses);
  }

  List<Widget> _buildFerryServicesContainer(
      Place userStartStation, Place? userDestinationStation) {
    if (_liveDepartureBoard == null) return [];
    return _buildServiceContainer(
        userStartStation, userDestinationStation, _liveDepartureBoard!.ferries);
  }

  List<Widget> _buildNRCCMessagesContainer() {
    if (_liveDepartureBoard == null) return [];
    List<Widget> widgets = [];
    for (var msg in _liveDepartureBoard!.nrccMessages) {
      widgets.add(WarningBox(
        text: msg.textMessage,
        links: msg.links,
      ));
    }
    return widgets;
  }

  // Build the services / departureboard container; set the attributes of this page
  Future<void> _setAndBuildServicesContainer(String startStationCRS,
      String? destinationStationCRS, bool refreshWhenDone,
      {bool refetchAPIData = true}) async {
    try {
      if (refetchAPIData) {
        // The reason why this is toggleable is that we need to be able to reset and add trains to these widgets when earlier and later services are navigated to
        // If we refresh the board from the API then we lose the earlier/later services
        earlierServicesFetchable = true;
        _liveDepartureBoard =
            await _fetchDepartureBoard(startStationCRS, destinationStationCRS);
      }
      if (_liveDepartureBoard == null) {
        throw Exception("Live departure board is null");
      }
      _liveTrainsWidgets = _buildTrainServicesContainer(
          _liveDepartureBoard!.station, _liveDepartureBoard!.destination);
      _liveBusesWidgets = _buildBusServicesContainer(
          _liveDepartureBoard!.station, _liveDepartureBoard!.destination);
      _liveFerriesWidgets = _buildFerryServicesContainer(
          _liveDepartureBoard!.station, _liveDepartureBoard!.destination);
      _liveNrccMessagesWidgets = _buildNRCCMessagesContainer();
      // Set the value of the services container
      _updateServicesContainer();
    } catch (e) {
      print(e);
      _liveTrainsWidgets = [
        const errorbox.ErrorBox(
            text:
                "Failed to search. Check your connection, and that the CRS codes of the stations entered are valid.")
      ];
    }
    if (refreshWhenDone) setState(() {});
  }

  // Update services showing, ie. different service type filter selected
  void _updateServicesContainer() {
    // ToDo - make below conditional on the existence in each category
    List<Widget> children = [
      _liveTrainsWidgets!,
      _liveBusesWidgets!,
      _liveFerriesWidgets!
    ][_serviceTypeDisplayed];
    _liveServicesWidget = Column(children: children);

    // Below is deprecated and replaced somewhere else. Reason: below would only display on initial API data fetch for first service type displayed.
    // // However, if it is empty, display info
    // if (children.isEmpty) {
    //   // Todo - show timeframe for services to appear here (base on time range of all services)
    //   _liveServicesWidget = const infobox.InfoBox(
    //     text: "No services within the timeframe were found.",
    //   );
    // }

    setState(() {}); // refresh
  }

  void _setServicesListLoading() {
    _liveServicesWidget = Column(
      children: const [LoadingBox()],
    );
  }

  Widget _buildLoading() {
    // WIdget for when no trains are available as no places have been selected
    return const LoadingBox();
  }

  void _loadTrainList() {
    _setServicesListLoading();
    _setAndBuildServicesContainer(
        _startStationCRS!, _destinationStationCRS, true);
  }

  @Deprecated(
      "Merge with _refreshServicesAsync (keep async) for reduced code duplication")
  void _refreshServices() {
    setState(() {
      // If start station is null, then no search has been performed yet
      _setAndBuildServicesContainer(
          _startStationCRS, _destinationStationCRS, true);
    });
  }

  Future<void> _refreshServicesAsync({bool refetchAPIData = true}) async {
    await _setAndBuildServicesContainer(
        _startStationCRS, _destinationStationCRS, true,
        refetchAPIData: refetchAPIData);
  }

  // Function must be called after NCRCC widgets are built
  List<Widget> _buildAppBarActions() {
    List<Widget> actionWidgets = [
      IconButton(
          onPressed: () => {},
          icon: const Icon(Icons.star_border)), // TODO implement functionality
    ];
    if (_liveNrccMessagesWidgets != null &&
        _liveNrccMessagesWidgets!.isNotEmpty) {
      actionWidgets.add(IconButton(
          onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) =>
                  NrccMsgsSheet(nrccWidgets: _liveNrccMessagesWidgets!)),
          icon: NotificationIcon(
            icon: Icons.warning_rounded,
            label: _liveNrccMessagesWidgets!.length.toString(),
          )));
    }
    actionWidgets.add(IconButton(
        onPressed: () => _refreshServices(), icon: const Icon(Icons.refresh)));
    return actionWidgets;
  }

  Widget _buildServiceTypeSelector() {
    return SegmentedButtonSelection(
        selection: _serviceTypeDisplayed,
        buttonData: [
          ButtonMapper(
            callback: (BuildContext context) => _goToServiceTypePage(0),
            buttonLabel: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Trains"),
                const SizedBox(width: 5),
                NotificationBlob(
                    label: _liveTrainsWidgets != null
                        ? _liveTrainsWidgets!.length.toString()
                        : "0"),
              ],
            ),
            buttonIcon: Icons.train,
          ),
          ButtonMapper(
            callback: (BuildContext context) => _goToServiceTypePage(1),
            buttonLabel: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Buses"),
                const SizedBox(width: 5),
                NotificationBlob(
                    label: _liveBusesWidgets != null
                        ? _liveBusesWidgets!.length.toString()
                        : "0"),
              ],
            ),
            buttonIcon: Icons.directions_bus,
          ),
          ButtonMapper(
            callback: (BuildContext context) => _goToServiceTypePage(2),
            buttonLabel: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Ferries"),
                const SizedBox(width: 5),
                NotificationBlob(
                    label: _liveFerriesWidgets != null
                        ? _liveFerriesWidgets!.length.toString()
                        : "0"),
              ],
            ),
            buttonIcon: Icons.directions_ferry,
          ),
        ]);
  }

  Future<void> _loadEarlierServices() async {
    if (_liveDepartureBoard == null) return;
    try {
      await _liveDepartureBoard!.addEarlierServices(
          _startStationCRS, _destinationStationCRS,
          minutes: 30);
    } catch (e) {
      if (e is api.ServicesOutOfSearchableBoundsException) {
        earlierServicesFetchable = false;
      } else {
        print("failed to update: $e");
      }
    }

    //print("Number of trains: ${_liveDepartureBoard!.trains.length}");
    await _refreshServicesAsync(refetchAPIData: false);
  }

  Future<void> _loadLaterServices() async {
    if (_liveDepartureBoard == null) return;
    try {
      laterServicesFetchable = await _liveDepartureBoard!
          .addLaterServices(_startStationCRS, _destinationStationCRS);
      // TODO: use result of above var
    } catch (e) {
      print("Failed to fetch later services: $e");
    }
    await _refreshServicesAsync(refetchAPIData: false);
  }

  String _getStartTimeWindow() {
    if (_liveDepartureBoard == null) return "??:??";
    return _liveDepartureBoard!.getTimeRangeStart();
  }

  String _getEndTimeWindow() {
    if (_liveDepartureBoard == null) return "??:??";
    String? res = _liveDepartureBoard!.getTimeRangeEnd();
    res ??= "??:??";
    return res;
  }

  Widget _buildServiceListView(List<Widget>? servicesWidgets) {
    return RefreshIndicator(
      onRefresh: _refreshServicesAsync,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        children: [
          if (earlierServicesFetchable)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              FilledButton.tonalIcon(
                onPressed: () =>
                    _loadEarlierServices(), // TODO - implement front & backend
                label: const Text("Earlier Services"),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ]),
          Container(
            child: (servicesWidgets == null)
                ? _buildLoading()
                : Column(
                    children: servicesWidgets.isEmpty
                        ? [
                            infobox.InfoBox(
                                text:
                                    "No services found between ${_getStartTimeWindow()} and ${_getEndTimeWindow()}")
                          ]
                        : servicesWidgets,
                  ),
          ),
          if (laterServicesFetchable)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              FilledButton.tonalIcon(
                onPressed: () =>
                    _loadLaterServices(), // TODO - implement front & backend
                label: const Text("Later Services"),
                icon: const Icon(Icons.arrow_downward_rounded),
              ),
            ]),
        ],
      ),
    );
  }

  Widget _buildServiceFilterCheckboxButtonPopup() {
    // TODO: clarify how the state can be null
    List<CheckboxButtonPopupMenuItem> items = [
      CheckboxButtonPopupMenuItem(
          widget: Text("Departures"),
          callback: (bool? state) {
            _serviceTypesFiltered[0] = state ?? false;
            _refreshServicesAsync(refetchAPIData: false);
          },
          selected: _serviceTypesFiltered[0]),
      CheckboxButtonPopupMenuItem(
          widget: Text("Arrivals"),
          callback: (bool? state) {
            _serviceTypesFiltered[1] = state ?? false;
            _refreshServicesAsync(refetchAPIData: false);
          },
          selected: _serviceTypesFiltered[1]),
    ];
    return CheckboxButtonPopup(
      items: items,
      buttonIcon: const Icon(Icons.filter_alt_rounded),
    );
  }

  // ToDo - make this cleaner
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _liveDepartureBoard != null
                  ? _liveDepartureBoard!.station.name +
                      (_destinationStationCRS == null ||
                              _destinationStationCRS == ""
                          ? ""
                          : " to ${STATION_CODES_INVERTED[_destinationStationCRS] ?? "*"}")
                  : "$_startStationCRS to ${_destinationStationCRS == null || _destinationStationCRS == '' ? '*' : _destinationStationCRS}",
              style: const TextStyle(height: 1.0),
            ),
            Text(
              _liveDepartureBoard != null
                  ? "Last updated at ${_liveDepartureBoard!.generatedAt.hour}:${_liveDepartureBoard!.generatedAt.minute.toString().length == 1 ? '0${_liveDepartureBoard!.generatedAt.minute}' : _liveDepartureBoard!.generatedAt.minute.toString()}"
                  : "Loading...",
              style: Theme.of(context).textTheme.labelSmall,
            )
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: _buildAppBarActions(),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset("assets/background1.jpeg", fit: BoxFit.cover),
            ),
          ),
          // Tint
          Positioned.fill(
              child: Container(
            color: Color.alphaBlend(
                Theme.of(context).primaryColor.withOpacity(0.2),
                Colors.black.withOpacity(0.05)),
          )),
          Column(
            children: [
              _buildServiceTypeSelector(),
              Expanded(
                child: PageView(
                  controller: _serviceTypePageController,
                  children: [
                    _buildServiceListView(_liveTrainsWidgets),
                    _buildServiceListView(_liveBusesWidgets),
                    _buildServiceListView(_liveFerriesWidgets),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: _buildServiceFilterCheckboxButtonPopup(),
      ),
    );
  }
}

/*
PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem(
                      child: CheckboxListTile(
                          value: true,
                          onChanged: (bool? value) {
                            print("New checkbox state: $value");
                          },
                          title: const Text("Option 1")))
                ],
            icon: const Icon(Icons.filter_alt_rounded)),
            */