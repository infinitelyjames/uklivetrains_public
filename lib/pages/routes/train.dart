// The page for the details of a specific train
import 'package:flutter/material.dart';
import 'package:uklivetrains/structs/callingpoint.dart';
import 'package:uklivetrains/structs/coach.dart';
import 'package:uklivetrains/structs/place.dart';
import 'package:uklivetrains/structs/placelist.dart';
import 'package:uklivetrains/structs/service.dart';
import 'package:uklivetrains/widgets/service/callingpoint.dart';
import 'package:uklivetrains/modules/api.dart' as api;
import 'package:uklivetrains/widgets/textboxes/errorbox.dart';
import 'package:uklivetrains/widgets/service/routedenoterbox.dart';
import 'package:uklivetrains/widgets/service/traincoach.dart';
import 'package:uklivetrains/widgets/service/trainsummarypaneattribute.dart';
import 'package:uklivetrains/widgets/textboxes/infobox.dart';
import 'package:uklivetrains/widgets/textboxes/warningbox.dart';

/* NOTE: Depending on if the trains are fetched from the API with details or without details
the calling point list and all the other available data to display here will be available
if not then this needs to fetched separately.,
*/

class TrainRoute extends StatefulWidget {
  // TODO: Encapsulate below?
  final Service service;
  TrainRoute({super.key, required this.service});

  @override
  State<TrainRoute> createState() => _TrainRouteState();
}

class _TrainRouteState extends State<TrainRoute> {
  late Service service;

  @override
  void initState() {
    super.initState();
    service = widget.service;
  }

  // Exclusive of board station
  bool get trainDividesBefore => service.previousCallingPoints == null
      ? false
      : service.previousCallingPoints!.length > 1;

  bool get trainDividesAfter => service.subsequentCallingPoints == null
      ? false
      : service.subsequentCallingPoints!.length > 1;
  // Update the service from a refresh
  void updateFromServiceSummary(api.ServiceSummary serviceSummary) {
    service.update(Service.fromAPIServiceSummary(serviceSummary));
  }

  // Update train route based on the saved service id. This will also find the previous Calling points
  Future<void> _updateTrainRoute(
      BuildContext context, bool refreshWidgets) async {
    if (service.serviceCode == null) return;
    try {
      api.ServiceSummary serviceSummary =
          await api.ServiceSummary.fetchServiceByID(service.serviceCode!);
      updateFromServiceSummary(serviceSummary);
      if (refreshWidgets) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Failed to update - check your connection. Trains may fail to update after 2 hours from their departure time.")));
    }

    // TODO state management here
  }

  PlaceList? _getStationsWhereTrainDividesAfter() {
    if (trainDividesAfter == false) return null;
    List<Place> places = [];
    for (List<CallingPoint> callingPointList
        in service.subsequentCallingPoints!.sublist(1)) {
      if (callingPointList.isEmpty) continue;
      places.add(callingPointList[0]);
    }
    return PlaceList.fromNoName(places);
  }

  Widget _buildTrainSummaryPane(BuildContext context) {
    List<Widget> children = [];
    // Train details
    children.add(TrainSummaryPaneAttribute(
        titleText: "Origin",
        trailingText:
            service.origin == null ? 'unknown' : service.origin!.name));
    children.add(const Divider(height: 1));
    if (!service.doesTerminateHere()) {
      children.add(TrainSummaryPaneAttribute(
          titleText: "Destination",
          trailingText: service.destination == null
              ? 'unknown'
              : service.destination!.name));
      children.add(const Divider(height: 1));
    }
    if (service.passengerDropoffOnly()) {
      // children.add(Text(
      //   "${service.scheduledArrivalTime!} from ${service.origin == null ? 'unknown' : service.origin!.name}",
      //   style: Theme.of(context).textTheme.titleLarge,
      // ));
      children.add(TrainSummaryPaneAttribute(
          titleText: "Arrives at", trailingText: service.scheduledArrivalTime));
      children.add(const Divider(height: 1));
    } else {
      children.add(const Divider(height: 1));
      children.add(TrainSummaryPaneAttribute(
          titleText: "Departs at",
          trailingText: service.scheduledDepartureTime));
      children.add(const Divider(height: 1));
    }
    // Operator
    if (service.operator != null) {
      children.add(TrainSummaryPaneAttribute(
          titleText: "Operator", trailingText: service.operator));
      children.add(const Divider(height: 1));
    }
    // Formation -moveed
    // if (service.formation != null) {
    //   //children.addAll([SizedBox(height: 5), _buildFormationWidget()!]);
    //   children.add(_buildFormationWidget()!);
    //   children.add(const Divider(height: 1));
    if (service.formation == null && service.coaches != null) {
      children.add(TrainSummaryPaneAttribute(
          titleText: "Coaches", trailingText: service.coaches));
      children.add(const Divider(height: 1));
    }
    if (children.isNotEmpty) children.removeLast();
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(228, 228, 228, 0.863) : const Color.fromRGBO(27, 27, 27, 0.863),
          border:
              Border.all(color: Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(156, 156, 156, 0.863): const Color.fromRGBO(100, 100, 100, 0.863), width: 1),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(4, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: children,
        ));
  }

  Widget _buildTrainServiceDetailsPane(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      children: [_buildTrainSummaryPane(context)],
    );
  }

  Widget _buildDropoffOnlyWarningWidget(BuildContext context) {
    /*
    For when passengers can leave the train, but not board it, and vice-versa. 
    Applies when buying tickets but not necessarily irl.
    Detected when arrival time or departure time is null, and train does not terminate or start.
    */
    return WarningBox(text: (service.previousCallingPoints != null && service.scheduledArrivalTime == null) ? 
    "Service stops here for passengers to board only" :
    (service.subsequentCallingPoints != null && service.scheduledDepartureTime == null) ? 
      "Service stops here for passengers to disembark only": "Error, this should not be displayed!"
    );
  }

  Widget _buildCallingPointsPage(BuildContext context) {
    // TODO - make button change / support no calling points loaded immediatrly - ie departure board fetched without details
    List<Widget> children = []; // children for the listview on the page
    // Train summary pane - NB: removed when splitting into tab view.
    //children.add(_buildTrainSummaryPane(context));
    // Train delay/cancellation reasoning
    if (service.delayCancelReason != null) {
      children.add(SizedBox(
        height: 8,
      ));
      children.add(ErrorBox(text: service.delayCancelReason!));
    }
    // Warning if no arrival or departure time available
    if (
      (service.previousCallingPoints != null && service.scheduledArrivalTime == null) ||
      (service.subsequentCallingPoints != null && service.scheduledDepartureTime == null)
    ) {
      children.add(const SizedBox(height: 8));
      children.add(_buildDropoffOnlyWarningWidget(context));
    }
    // Bus/ferry info
    if (service.serviceType != null &&
        (service.serviceType!.toLowerCase() == "bus" ||
            service.serviceType!.toLowerCase() == "ferry")) {
      children.addAll(const [
        SizedBox(height: 5),
        InfoBox(
            text:
                "Live tracking information is not available for bus and ferry services"),
      ]);
    }
    // Train divide alerts
    if (trainDividesAfter) {
      children.add(const SizedBox(height: 6));
      children.add(WarningBox(
          text:
              "This train divides at ${_getStationsWhereTrainDividesAfter()!.name}. See on-train announcements to ensure that you are travelling in the correct part of the train."));
    }
    // Calling points
    children.add(SizedBox(
      height: 8,
    ));
    //print("Origin: ${service.origin}");
    if (service.previousCallingPoints != null) {
      children.addAll(_buildPreviousCallingPoints(context));
    } else if (!(service.origin !=
            null && // only show previous stops when train doensn't start here
        service.userStartStation != null &&
        service.origin!.crsInPlaces(service.userStartStation!.crs))) {
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.tonalIcon(
                icon: Icon(Icons.arrow_upward_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Updating...")));
                  _updateTrainRoute(context, true);
                },
                label: Text("Show Previous Stops"))
          ],
        ),
      );
    }
    children.addAll(_buildSubsequentCallingPoints(context));
    return RefreshIndicator(
      onRefresh: () => _updateTrainRoute(context, true),
      child: ListView(
        padding: const EdgeInsets.all(5),
        children: children,
      ),
    );
  }

  Widget? _buildFormationWidget() {
    if (service.formation == null) return null; // No formation data present
    // Formation UI
    List<Widget> coachWidgets = [
      const InfoBox(text: "Train may travel in reverse to the order shown")
    ];
    for (Coach coach in service.formation!) {
      coachWidgets.add(TrainCoach(
        coach: coach,
        dense: false,
        formationLength: service.formation!.length,
      ));
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Wrap(
        runSpacing: 5,
        children: coachWidgets,
      ),
    );
  }

  Widget? _buildFormationPage() {
    if (service.formation == null) return null; // No formation data present
    return ListView(
      children: [_buildFormationWidget()!],
    );
  }

  @Deprecated(
      "Cannot be used when calling point icons need to join, implement within calling point widget for certain subwidgets")
  Widget _applyCallingPointMargin(Widget widget) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 1, 0, 1),
      child: widget,
    );
  }

  List<Widget> _buildPreviousCallingPoints(BuildContext context) {
    // TODO: properly support dividing trains
    if (service.previousCallingPoints == null)
      return [ErrorWidget("Error: called build before data processing")];
    List<Widget> callingPointWidgets = [];
    int i = 1;
    for (List<CallingPoint> callingPointList
        in service.previousCallingPoints!) {
      for (CallingPoint callingPoint in callingPointList) {
        callingPointWidgets.add(CallingPointWidget.fromRaw(
          callingPoint,
          false,
          false,
          trainStartsHere: i == 1,
        ));
        i++;
      }
    }
    return callingPointWidgets;
  }

  // Subsequent calling points including the current stop
  List<Widget> _buildSubsequentCallingPoints(BuildContext context) {
    if (service.userStartStation == null) {
      return [const ErrorBox(text: "Error in calling point data transfer.")];
    }
    List<Widget> callingPointWidgets = [];
    callingPointWidgets.addAll([
      CallingPointWidget.fromRaw(
        CallingPoint(
          name: service.userStartStation!.name,
          crs: service.userStartStation!.crs,
          scheduledTime: service.scheduledArrivalTime ??
              service.scheduledDepartureTime ??
              "??",
          estimatedTime:
              service.estArrivalTime ?? service.estDepartureTime ?? "??",
          platform: service.platform,
          departedYet: service.departedYet ?? false,
        ),
        true,
        trainDividesAfter &&
            _getStationsWhereTrainDividesAfter()!
                .crsInPlaces(service.userStartStation!.crs),
        trainStartsHere: service.origin != null &&
            service.userStartStation != null &&
            service.origin!.crsInPlaces(service.userStartStation!.crs),
        trainEndsHere: service.doesTerminateHere(),
      )
    ]);
    if (service.subsequentCallingPoints == null ||
        service.subsequentCallingPoints!.isEmpty) {
      return callingPointWidgets;
    }
    int routeCount = 1;
    Map<String, int> coachesUsed = {};
    for (List<CallingPoint> callingPointList
        in service.subsequentCallingPoints!) {
      int j = 1;
      for (var callingPoint in callingPointList) {
        //print(
        //    "${callingPoint.crs} : ${service.userDestinationStation == null ? null : service.userDestinationStation!}");
        if (trainDividesAfter &&
            _getStationsWhereTrainDividesAfter()!
                .crsInPlaces(callingPoint.crs)) {
          String text =
              "Route to ${callingPointList[callingPointList.length - 1].name}";
          // Figuring out what coach number for which routes
          // Assumes routes are gathered in chronological order from the train dividing
          if (callingPoint.coaches != null) {
            if (coachesUsed[callingPoint.crs] == null) {
              coachesUsed[callingPoint.crs] = 0;
            }
            text +=
                ". Travel in coaches ${coachesUsed[callingPoint.crs]! + 1}-${coachesUsed[callingPoint.crs]! + callingPoint.coaches!}.";
            coachesUsed[callingPoint.crs] =
                coachesUsed[callingPoint.crs]! + callingPoint.coaches!;
          }
          callingPointWidgets.add(RouteDenoter(text: text));
        }
        CallingPointWidget callingPointWidget = CallingPointWidget.fromRaw(
          callingPoint,
          service.userDestinationStation == null
              ? false
              : callingPoint.crs.toLowerCase() ==
                  service.userDestinationStation!.crs.toLowerCase(),
          trainDividesAfter &&
              _getStationsWhereTrainDividesAfter()!
                  .crsInPlaces(callingPoint.crs),
          trainEndsHere: j == callingPointList.length,
        );

        callingPointWidgets.add(callingPointWidget);
        j++;
      }
      routeCount++;
    }
    return callingPointWidgets;
  }

  Future<void> fetchData() async {
    if ((service.previousCallingPoints == null ||
            service.previousCallingPoints == []) &&
        (service.subsequentCallingPoints == null ||
            service.subsequentCallingPoints == [])) {
      await _updateTrainRoute(context,
          false); // Do not refresh widgets - setState cannot be called in build
      // await Future.delayed(Duration(seconds: 3)); // <-- Uncomment for debugging loading sreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: service.formation != null ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${service.scheduledArrivalTime ?? service.scheduledDepartureTime} Plat.${service.platform ?? "--"}",
                style: TextStyle(height: 1.0),
              ),
              Text(
                "Last updated at ${service.lastUpdated.hour}:${service.lastUpdated.minute.toString().length == 1 ? '0${service.lastUpdated.minute}' : service.lastUpdated.minute.toString()}",
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(onPressed: () => {}, icon: const Icon(Icons.share)),
            IconButton(
                onPressed: () => {},
                icon: const Icon(
                    Icons.star_border)), // TODO implement functionality
            IconButton(
                onPressed: () => _updateTrainRoute(context, true),
                icon: const Icon(Icons.refresh))
          ],
          bottom: TabBar(tabs: [
            Tab(
              icon: Icon(Icons.location_on_outlined),
              text: "Calling Points",
            ),
            if (service.formation != null)
              Tab(
                icon: Icon(Icons.train),
                text: "Coaches",
              ),
            Tab(
              icon: Icon(Icons.info),
              text: "Service Info",
            ),
          ]),
        ),
        body: FutureBuilder(
            future: fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox.expand(
                  child: Stack(
                    children: [
                      // Background image
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.2,
                          child: Image.asset("assets/background1.jpeg",
                              fit: BoxFit.cover),
                        ),
                      ),
                      // Tint
                      Positioned.fill(
                          child: Container(
                        color: Theme.of(context).primaryColor.withOpacity(
                            0.3), // Color.fromRGBO(26, 22, 255, 0.2)
                      )),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                );
              } else {
                return Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.05,
                        child: Image.asset("assets/background1.jpeg",
                            fit: BoxFit.cover),
                      ),
                    ),
                    // Tint
                    Positioned.fill(
                        child: Container(
                      color: Theme.of(context).primaryColor.withOpacity(
                          0.15), // Color.fromRGBO(26, 22, 255, 0.2)
                    )),
                    // Content
                    TabBarView(children: [
                      _buildCallingPointsPage(context),
                      if (service.formation != null)
                        _buildFormationPage()!, // _buildFormationWidget()!
                      _buildTrainServiceDetailsPane(context),
                    ]),
                  ],
                );
              }
            }), // TODO improve efficiency by storing as member variable?],,
      ),
    );
  }
}

/*
 FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox.expand(
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.2,
                        child: Image.asset("assets/background1.jpeg",
                            fit: BoxFit.cover),
                      ),
                    ),
                    // Tint
                    Positioned.fill(
                        child: Container(
                      color: Theme.of(context)
                          .primaryColor
                          .withOpacity(0.3), // Color.fromRGBO(26, 22, 255, 0.2)
                    )),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ),
              );
            } else {
              return Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: Image.asset("assets/background1.jpeg",
                          fit: BoxFit.cover),
                    ),
                  ),
                  // Tint
                  Positioned.fill(
                      child: Container(
                    color: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.3), // Color.fromRGBO(26, 22, 255, 0.2)
                  )),
                  // Content
                  _buildPage(context),
                ],
              );
            }
          }), // TODO improve efficiency by storing as member variable?
*/
