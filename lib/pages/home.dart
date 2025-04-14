import 'package:flutter/material.dart';
import 'package:uklivetrains/modules/api.dart';
import 'package:uklivetrains/modules/persistentdata.dart';
import 'package:uklivetrains/pages/routes/trainlist.dart';
import 'package:uklivetrains/structs/departureboardquerytimed.dart';
import 'package:uklivetrains/structs/homescreenwidgetdetails.dart';
import 'package:uklivetrains/structs/timeformats.dart';
import 'package:uklivetrains/widgets/home/homewidgetcontainer.dart';
import 'package:uklivetrains/widgets/textboxes/loadingbox.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true; // keeps page alive
  bool alreadyLoaded = false;

  List<Widget> widgetsToDisplay = [];

  List<Widget> _buildServiceSummaryWidgets(
      DepartureBoardQueryTimed boardInfo, List<ServiceSummary> serviceSummaries,
      {int limit = 3}) {
    List<Widget> widgets = [];
    int i = 0;
    for (ServiceSummary serviceSummary in serviceSummaries) {
      if (i == limit) break;
      widgets.add(IndividualServiceSummary.fromAPIServiceSummary(
        serviceSummary,
        boardInfo.stationBoardQuery.startStation,
        boardInfo.stationBoardQuery.destinationStation,
      ));
      i++;
    }
    if (widgets.isEmpty) {
      widgets = [
        const Text(
          "No services found in the next two hours",
          style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.6)),
        )
      ];
    }
    return widgets;
  }

  Future<Widget> _buildDepartureBoardWidget(
      DepartureBoardQueryTimed boardInfo) async {
    // Fetch the departure board data
    LiveStationBoard stationBoard;
    try {
      stationBoard = await LiveStationBoard.fetchLiveDepartureBoard(
        boardInfo.stationBoardQuery.startStation.crs,
        boardInfo.stationBoardQuery.destinationStation?.crs,
      );
    } catch (e) {
      return HomeWidgetContainer(
          title:
              "${boardInfo.stationBoardQuery.startStation.name}${boardInfo.stationBoardQuery.destinationStation != null ? ' to ${boardInfo.stationBoardQuery.destinationStation!.name}' : ''}",
          subtitle: "Last updated at ${HHMMTime.getCurrentStringTime()}",
          containedWidget: const Column(
            children: [
              Text(
                "Failed to load details, check your connection",
                style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.6)),
              )
            ],
          ));
    }

    List<ServiceSummary> allServices =
        stationBoard.mergeServiceLists(stationBoard.trains, stationBoard.buses);
    allServices =
        stationBoard.mergeServiceLists(allServices, stationBoard.ferries);
    // boardInfo contains the relevant information required to query the departure board
    return HomeWidgetContainer(
        title:
            "${boardInfo.stationBoardQuery.startStation.name}${boardInfo.stationBoardQuery.destinationStation != null ? ' to ${boardInfo.stationBoardQuery.destinationStation!.name}' : ''}",
        subtitle: "Last updated at ${HHMMTime.getCurrentStringTime()}",
        containedWidget: Column(
          children: _buildServiceSummaryWidgets(boardInfo, allServices),
        ));
  }

  Future<void> _reloadSavedWidgets({bool refresh = true}) async {
    widgetsToDisplay = [];
    // Retrieve the widget data from local storage
    HomeScreenWidgetsListSerializable homeScreenWidgets =
        await HomeScreenWidgetsListSerializable.loadSaved();
    // Parse for each type
    for (HomeScreenWidgetDetails widgetDetails in homeScreenWidgets.widgets) {
      if (widgetDetails is DepartureBoardQueryTimed) {
        if (!widgetDetails.repeatingTimeSelection.isValidWhen(DateTime.now())) {
          // This skips adding the widget if it should not be displayed now
          continue;
        }

        // TODO: check timestamp here
        widgetsToDisplay.add(await _buildDepartureBoardWidget(widgetDetails));
        widgetsToDisplay.add(const SizedBox(height: 8));
      } else {
        print(
            "WARN: Object type could not be identified as particular type of home screen widget, so skipped");
      }
    }
    if (refresh) setState(() {});
  }

  Future<void> _loadSavedWidgets() async {
    if (alreadyLoaded) return;
    await _reloadSavedWidgets(refresh: false);
    alreadyLoaded = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("Loaded: $alreadyLoaded");
    return Stack(
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
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.black.withOpacity(0.05)),
        )),
        FutureBuilder(
            future: _loadSavedWidgets(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Column(
                  children: [LoadingBox()],
                );
              } else {
                return RefreshIndicator(
                  onRefresh: _reloadSavedWidgets,
                  child: ListView(
                    padding: const EdgeInsets.all(10),
                    children: widgetsToDisplay,
                  ),
                );
              }
            }),
      ],
    );
  }
}
