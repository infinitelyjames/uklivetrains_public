import 'package:flutter/material.dart';
import 'package:uklivetrains/data/station_codes.dart';

const MAX_ITEMS_DISPLAYED = 10;

class Pair<K, V> {
  K key;
  V value;

  Pair({required this.key, required this.value});
}

class PairList<K, V> {
  List<Pair<K, V>> list;

  PairList({this.list = const []});
}

// V2 succeeds v1 which was the raw flutter version which suffered from major lag issues
class StationEntryDropDownV2 extends StatefulWidget {
  final Map<String, String> stationCodes;
  final String hintText;
  final bool optional;

  StationEntryDropDownV2(
      {Key? key,
      this.stationCodes = STATION_CODES,
      this.hintText = "Station",
      this.optional = false})
      : super(key: key);

  @override
  StationEntryDropDownV2State createState() => StationEntryDropDownV2State();
}

typedef Callback = void Function();

class StationEntryDropDownV2State extends State<StationEntryDropDownV2> {
  TextEditingController _controller = TextEditingController();
  PairList<String, String> _filteredStations = PairList();
  List<DropdownMenuEntry> _dropDownMenuStations = [
    const DropdownMenuEntry(value: "", label: "(all stations)", enabled: false)
  ];
  String? selectedCRS;
  String? errorText;
  late Callback _controllerCallback;
  bool _initialTextEditingControllerCallback =
      true; // See _onSearchChanged for explanation

  @override
  void initState() {
    super.initState();
    _filteredStations = PairList<String, String>();
    _setupTextEditingController();
    _initialTextEditingControllerCallback = true;
  }

  @override
  void dispose() {
    _disposeTextEditingController();
    super.dispose();
  }

  void _setupTextEditingController() {
    _controllerCallback = () => _onSearchChanged(_controller.text);
    _controller.addListener(_controllerCallback);
  }

  void _disposeTextEditingController() {
    // Dispose to prevent memory leaks
    _controller.removeListener(_controllerCallback);
    _controller.dispose();
  }

  void refresh() {
    setState(() {});
  }

  void _onSearchChanged(String newQuery) {
    // This function is called on build(). However, it cannot execute on build
    // as it calls setState(), which cannot be used on build.
    if (_initialTextEditingControllerCallback) {
      _initialTextEditingControllerCallback = false;
      return;
    }
    // Uncomment for debugging: print("Search changed to $newQuery");
    _filterStations(newQuery);
    _buildDropdownEntries();
    refresh();
  }

  void _filterStations(String query) {
    _filteredStations.list = [];
    query = query.toLowerCase();
    for (var entry in widget.stationCodes.entries) {
      if (entry.key.toLowerCase().contains(query)) {
        _filteredStations.list.add(Pair(key: entry.key, value: entry.value));
        if (_filteredStations.list.length >= MAX_ITEMS_DISPLAYED) break;
      }
    }
  }

  void _buildDropdownEntries() {
    /* Requires stations to be pre-filtered
    For optimal efficiency, do not call unless the list of stations has been changed */
    if (_filteredStations.list.length > MAX_ITEMS_DISPLAYED)
      throw Exception("List length of filtered stations exceeds allowed size");
    _dropDownMenuStations = widget.optional
        ? [const DropdownMenuEntry(value: "", label: "(all stations)")]
        : [];
    for (Pair station in _filteredStations.list) {
      _dropDownMenuStations
          .add(DropdownMenuEntry(label: station.key, value: station.value));
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return LayoutBuilder(
      builder: (context, constraints) => DropdownMenu(
        dropdownMenuEntries: _dropDownMenuStations,
        onSelected: (value) {
          selectedCRS = value;
          print(selectedCRS);
        },
        initialSelection: widget.optional ? "" : null,
        controller: _controller,
        enableSearch: true,
        enableFilter: true,
        label: Text(widget.hintText),
        requestFocusOnTap: true,
        width: constraints.maxWidth,
        errorText: errorText,
      ),
    );
  }
}
