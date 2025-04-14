import 'package:flutter/material.dart';
import 'package:uklivetrains/data/station_codes.dart';
import 'package:uklivetrains/modules/persistentdata.dart';
import 'package:uklivetrains/modules/utils.dart' as utils;
import 'package:uklivetrains/modules/api.dart' as api;
import 'package:uklivetrains/pages/routes/settings/homewidgets/stationboard.dart';
import 'package:uklivetrains/pages/routes/train.dart';
import 'package:uklivetrains/pages/routes/trainlist.dart';
import 'package:uklivetrains/structs/place.dart';
import 'package:uklivetrains/structs/service.dart';
import 'package:uklivetrains/structs/stationboardquery.dart';
import 'package:uklivetrains/widgets/general/basicpopupmenu.dart';
import 'package:uklivetrains/widgets/textboxes/infobox.dart' as infobox;
import 'package:uklivetrains/widgets/textboxes/errorbox.dart' as errorbox;
import 'package:uklivetrains/widgets/textboxes/loadingbox.dart';
import 'package:uklivetrains/widgets/major-widgets/stationboardquerysummary.dart';
import 'package:uklivetrains/widgets/user-input/stationentrydropdown.dart';
import 'package:uklivetrains/widgets/textboxes/warningbox.dart';

String STATIONS_CSV = "data/station_codes.csv";

/* ToDo
-> Service disruption area
-> Dropdown list of stations, validating the name
-> All interactivity
-> Make the UI look better: 
  - Make Train widget more attractive - move text-based stuff into individual icons with a number next to them

*/

const textFieldStyle = TextStyle(fontFamily: 'Roboto', fontSize: 15);

@Deprecated("V1: too laggy")
class StationEntryDropdown extends StatelessWidget {
  StationEntryDropdown({
    Key? key,
    required this.hintText,
    required this.optional,
    this.controller,
  }) : super(key: key) {
    _dropdownMenuEntries = StationEntryDropdown.getDropdownEntries();
  }

  final String hintText;
  final TextEditingController? controller; // TODO - this needed?
  final bool optional;
  String? crsSelected;
  late List<DropdownMenuEntry> _dropdownMenuEntries;

  // ToDo- refactor usage for efficiency
  static List<DropdownMenuEntry> getDropdownEntries() {
    List<DropdownMenuEntry> items = [];
    for (var station in STATION_CODES.entries) {
      items.add(DropdownMenuEntry(value: station.value, label: station.key));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuEntry> entries = [];
    if (optional) entries.add(DropdownMenuEntry(value: "", label: "(any)"));
    entries.addAll(_dropdownMenuEntries);
    return DropdownMenu(
      dropdownMenuEntries: entries,
      onSelected: (value) {
        crsSelected = value;
      },
      enableSearch: true,
      enableFilter: true,
      label: Text(hintText),
      requestFocusOnTap: true,
    );
  }
}

// Todo - convert to stateful widget
class LiveTrainsSearchPage extends StatefulWidget {
  const LiveTrainsSearchPage({super.key});

  @override
  State<LiveTrainsSearchPage> createState() => _LiveTrainsSearchPageState();
}

class _LiveTrainsSearchPageState extends State<LiveTrainsSearchPage>
    with AutomaticKeepAliveClientMixin<LiveTrainsSearchPage> {
  // ToDo - work on keeping the page state when switching between tabs
  @override
  bool get wantKeepAlive => true;

  String? _startStationCRS;
  String? _destinationStationCRS;

  StationEntryDropDownV2? _startStationDropdown;
  final GlobalKey<StationEntryDropDownV2State> startStationGlobalKey =
      GlobalKey();
  StationEntryDropDownV2? _destinationStationDropDown;
  final GlobalKey<StationEntryDropDownV2State> destinationStationGlobalKey =
      GlobalKey();
  //StationEntryDropdown? _destinationStationDropdown;
  StarredStationBoardsListSerializable? starredStationBoardQueries;

  @override
  void initState() {
    super.initState();
    _loadStarredStationBoardQueries();
  }

  // Setup the dropdown lists for station entry on the main livetrains page
  void _setupStationDropdownLists() {
    _startStationDropdown = StationEntryDropDownV2(
      key: startStationGlobalKey,
      hintText: "Start",
    );
    _destinationStationDropDown = StationEntryDropDownV2(
      key: destinationStationGlobalKey,
      hintText: "Destination (optional)",
      optional: true,
    );
  }

  // Update start station crs code and destination crs code
  void _updateCRSCodeVariablesFromDropdown() {
    _startStationCRS = startStationGlobalKey.currentState != null
        ? startStationGlobalKey.currentState!.selectedCRS ?? ""
        : ""; // TODO - remove placeholder
    _destinationStationCRS = destinationStationGlobalKey.currentState != null
        ? destinationStationGlobalKey.currentState!.selectedCRS ?? ""
        : ""; // TODO - remove placeholder
  }

  void _loadTrainList({StationBoardQuery? stationBoardQuery}) {
    if (stationBoardQuery == null) {
      // No specific route button clicked, so check the contents of the dropdown menus
      // Setup the vars for the refresh button to later work
      _startStationCRS = startStationGlobalKey.currentState != null
          ? startStationGlobalKey.currentState!.selectedCRS ?? ""
          : ""; // TODO - remove placeholder
      // Set error text where applicable
      if (_startStationCRS == "" &&
          startStationGlobalKey.currentState != null) {
        startStationGlobalKey.currentState!.errorText =
            "You must select a station";
        //print('error');
        startStationGlobalKey.currentState!.refresh();
        return;
      } else if (startStationGlobalKey.currentState != null) {
        startStationGlobalKey.currentState!.errorText = null;
      }

      _destinationStationCRS = destinationStationGlobalKey.currentState != null
          ? destinationStationGlobalKey.currentState!.selectedCRS ?? ""
          : ""; // TODO - remove placeholder

      // _setAndBuildServicesContainer(
      //     _startStationCRS!, _destinationStationCRS, true);
    } else {
      // Specific route button clicked
      // Note, this block of code is not currently used as button callback uses a different function
      _startStationCRS = stationBoardQuery.startStation.crs;
      _destinationStationCRS = stationBoardQuery.destinationStation?.crs;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LiveTrainsRoutePage(
                  startStationCRS: _startStationCRS!,
                  destinationStationCRS: _destinationStationCRS,
                )));
  }

  Widget? _buildStarredStationBoardQueries() {
    if (starredStationBoardQueries == null) return null;
    List<Widget> widgets = [];
    for (int i = 0;
        i < starredStationBoardQueries!.boardQueryList.length;
        i++) {
      widgets.add(StationBoardQuerySummaryWidget(
        stationBoardQuery: starredStationBoardQueries!.boardQueryList[i],
        onDeleteCallback: () {
          starredStationBoardQueries!.boardQueryList.removeAt(i);
          starredStationBoardQueries!.savePersistent();
          setState(() {});
        },
      ));
      widgets.add(const Divider(height: 1));
    }
    if (widgets.isNotEmpty) widgets.removeLast();
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).primaryColor, width: 1),
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).brightness == Brightness.light ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [...widgets]),
          ),
        ],
      ),
    );
  }

  Future<void> _loadStarredStationBoardQueries(
      {bool refreshWidgets = true}) async {
    //print("Loading starredStationBoardQueries");
    starredStationBoardQueries =
        await StarredStationBoardsListSerializable.loadSaved();
    //print(
    //    "Loading starredStationBoardQueries finished: ${starredStationBoardQueries!.boardQueryList.length}");
    if (refreshWidgets) setState(() {});
  }

  // Returns true if operations can continue to do with the start and destination dropdowns
  // if not, returns false and displays relevant error messages
  bool _preventContinueUnlessFormFilled(BuildContext context) {
    _updateCRSCodeVariablesFromDropdown();
    if (_startStationCRS == null ||
        _startStationCRS == "" ||
        starredStationBoardQueries == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select a start to be able to star")));
      if (startStationGlobalKey.currentState != null) {
        startStationGlobalKey.currentState!.errorText =
            "You must select a station";
        startStationGlobalKey.currentState!.refresh();
      }
      return false;
    }
    return true;
  }

  void _addCurrentSelectionToHomescreen(BuildContext context) {
    if (!_preventContinueUnlessFormFilled(context)) return; // also updates vars
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                StationBoardHomeScreenWidgetsRoute.fromStartEnd(
                  Place.fromCRS(_startStationCRS!),
                  _destinationStationCRS == null || _destinationStationCRS == ""
                      ? null
                      : Place.fromCRS(_destinationStationCRS!),
                )));
  }

  Future<void> _starCurrentSelection(BuildContext context,
      {bool refreshWidgets = true}) async {
    if (!_preventContinueUnlessFormFilled(context)) return;
    // TODO: replace service types filter placeholders
    StationBoardQuery stationBoardQuery = StationBoardQuery(
        startStation: Place.fromCRS(_startStationCRS!),
        destinationStation:
            _destinationStationCRS == null || _destinationStationCRS == ""
                ? null
                : Place.fromCRS(_destinationStationCRS!),
        serviceTypesFiltered: [true, true]);
    starredStationBoardQueries!.boardQueryList.add(stationBoardQuery);
    if (refreshWidgets) setState(() {});
    // Now, update it in persistent storage
    await starredStationBoardQueries!.savePersistent();
  }

  // ToDo - make this cleaner
  @override
  Widget build(BuildContext context) {
    super.build(context);
    _setupStationDropdownLists();
    return Container(
      child: Stack(
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
          ListView(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 4),
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(15.0),
                  color: Theme.of(context).brightness == Brightness.light ?const Color.fromRGBO(226, 226, 226, 0.886) : const Color.fromRGBO(29, 29, 29, 0.886),
                ),
                child: Column(mainAxisSize: MainAxisSize.max, children: [
                  _startStationDropdown!,
                  const Text(
                    'to',
                    style: TextStyle(fontSize: 10),
                  ),
                  _destinationStationDropDown!,
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => {},
                        icon: BasicPopupMenuButton(entries: [
                          BasicPopupMenuEntry(
                            label: "Favourite",
                            callback: () => _starCurrentSelection(context),
                          ),
                          BasicPopupMenuEntry(
                            label: "Add to homepage",
                            callback: () =>
                                _addCurrentSelectionToHomescreen(context),
                          ),
                        ], child: const Icon(Icons.star_border)),
                      ),
                      // IconButton.filledTonal(
                      //   icon: Icon(Icons.star_border),
                      //   onPressed: () => _starCurrentSelection(context),
                      // ),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            setState(
                                () => _loadTrainList()); // _loadTrainList()
                          },
                          label: const Text('Search'),
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: Icon(Icons.tune),
                        onPressed: () => {},
                      ),
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              if (starredStationBoardQueries != null)
                _buildStarredStationBoardQueries()!,
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

/* Example usage

IndividualTrainSummary(
    destination: "London Victoria",
    platform: "3",
    scheduledDepartureTime: "14:01",
    startStation: "Dorking",
    destinationStation: "Clapham Junction",
    estDepartureTime: "14:20",
    estArrivalTime: "15:02",
    operator: "Southern",
    coaches: "12",
    callingPoints: [
      "Dorking",
      "Epsom",
      "Sutton",
      "Clapham Junction",
      "London Victoria"
    ])

*/
