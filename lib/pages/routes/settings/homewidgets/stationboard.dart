import 'package:flutter/material.dart';
import 'package:uklivetrains/modules/persistentdata.dart';
import 'package:uklivetrains/structs/departureboardquerytimed.dart';
import 'package:uklivetrains/structs/place.dart';
import 'package:uklivetrains/structs/repeatingtimeselection.dart';
import 'package:uklivetrains/structs/stationboardquery.dart';
import 'package:uklivetrains/structs/timeformats.dart';
import 'package:uklivetrains/widgets/user-input/daysselector.dart';
import 'package:uklivetrains/widgets/settings/settingscategorycontainer.dart';

enum BoardContains {
  disruption, // only disruption
  trains, // trains and disruption if present
}

enum TimeSelection {
  allday,
  custom,
}

// Referenced from live trains search page, dropdown list from star button
class StationBoardHomeScreenWidgetsRoute extends StatefulWidget {
  // final Place startStation;
  // final Place? destinationStation;
  final StationBoardQuery stationBoardQuery;

  const StationBoardHomeScreenWidgetsRoute(
      {super.key, required this.stationBoardQuery});

  @Deprecated(
      "Using above method is preferable and does not rely on placeholders which may become outdated")
  factory StationBoardHomeScreenWidgetsRoute.fromStartEnd(
      Place startStation, Place? destinationStation) {
    return StationBoardHomeScreenWidgetsRoute(
      stationBoardQuery: StationBoardQuery(
          startStation: startStation,
          destinationStation: destinationStation,
          serviceTypesFiltered: [true, true]),
    ); // TODO: fix placeholder
  }

  @override
  State<StationBoardHomeScreenWidgetsRoute> createState() =>
      _StationBoardHomeScreenWidgetsRouteState();
}

class _StationBoardHomeScreenWidgetsRouteState
    extends State<StationBoardHomeScreenWidgetsRoute> {
  BoardContains _widgetTypeSelected = BoardContains.trains;
  TimeSelection _timeRangeTypeSelected = TimeSelection.allday;
  TimeOfDay? _customStartTime;
  TimeOfDay? _customEndTime;
  List<bool> _daysSelected = [true, true, true, true, true, false, false];

  Future<void> _onCustomTimeSelection(
      BuildContext context, TimeSelection? value) async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: _customStartTime ?? TimeOfDay.now(),
      helpText: "Select a Start Time",
      confirmText: "Next",
    );
    if (startTime == null || !mounted) return;
    // TODO: clarify async gap
    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: _customEndTime ?? TimeOfDay.now(),
      helpText: "Select an End Time",
      confirmText: "Finish",
    );
    if (endTime == null) return;
    // TODO: add check for end time being later
    setState(() {
      if (value != null) _timeRangeTypeSelected = value;
      _customStartTime = startTime;
      _customEndTime = endTime;
    });
  }

  Future<void> _onSubmit(BuildContext context) async {
    // TODO: support service disruption only option
    // Setup the time window
    TimeWindow timeWindow;
    if (_customStartTime != null && _customEndTime != null) {
      timeWindow = TimeWindow(
          startTime: HHMMTime(_customStartTime!.format(context)),
          endTime: HHMMTime(_customEndTime!.format(context)));
    } else {
      timeWindow = TimeWindow.allDay();
    }
    // Setup the repeating time selection
    RepeatingTimeSelection repeatingTimeSelection = RepeatingTimeSelection(
        onDaysOfWeek: _daysSelected, timeWindows: [timeWindow]);
    // Setup the conditional departure board
    DepartureBoardQueryTimed departureBoardQueryTimed =
        DepartureBoardQueryTimed(
      repeatingTimeSelection: repeatingTimeSelection,
      stationBoardQuery: widget.stationBoardQuery,
    );
    // Fetch the current list of widgets
    HomeScreenWidgetsListSerializable homeScreenWidgets =
        await HomeScreenWidgetsListSerializable.loadSaved();
    // Add the departure board widget
    homeScreenWidgets.widgets.add(departureBoardQueryTimed);
    // Save the resulting object
    await homeScreenWidgets.savePersistent();
    // Success, and exit:
    // TODO: fix async gap
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Widget"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(padding: EdgeInsets.all(10), children: [
        SettingsCategoryContainer(
            categoryName: "Query Details",
            settingsActionWidgets: [
              ListTile(
                title: Text(
                  "Start",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Text(
                  "${widget.stationBoardQuery.startStation.name} (${widget.stationBoardQuery.startStation.crs})",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ListTile(
                title: Text(
                  "Destination",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Text(
                  widget.stationBoardQuery.destinationStation != null
                      ? "${widget.stationBoardQuery.destinationStation!.name} (${widget.stationBoardQuery.destinationStation!.crs})"
                      : "*",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ]),
        const SizedBox(height: 10),
        SettingsCategoryContainer(
            categoryName: "Select details to display",
            settingsActionWidgets: [
              RadioListTile(
                title: const Text("Live trains and service disruption"),
                value: BoardContains.trains,
                groupValue: _widgetTypeSelected,
                onChanged: (BoardContains? value) => setState(() {
                  if (value != null) _widgetTypeSelected = value;
                }),
              ),
              RadioListTile(
                title: const Text("Service disruption only"),
                value: BoardContains.disruption,
                groupValue: _widgetTypeSelected,
                onChanged: (BoardContains? value) => setState(() {
                  if (value != null) _widgetTypeSelected = value;
                }),
              ),
            ]),
        const SizedBox(height: 10),
        SettingsCategoryContainer(
            categoryName: "Show on days",
            settingsActionWidgets: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DaysOfWeekSelector(
                    initialSelection: _daysSelected,
                    onChangedCallback: (newDaysSelected) =>
                        {_daysSelected = newDaysSelected},
                  ),
                ],
              )
            ]),
        const SizedBox(height: 10),
        SettingsCategoryContainer(
            categoryName: "Show at times",
            settingsActionWidgets: [
              RadioListTile(
                title: const Text("All Day"),
                value: TimeSelection.allday,
                groupValue: _timeRangeTypeSelected,
                onChanged: (TimeSelection? value) => setState(() {
                  if (value != null) _timeRangeTypeSelected = value;
                }),
              ),
              RadioListTile(
                title: _customStartTime != null && _customEndTime != null
                    ? Text(
                        "${_customStartTime!.format(context)} to ${_customEndTime!.format(context)}")
                    : const Text("Custom start and end time"),
                value: TimeSelection.custom,
                secondary: _customStartTime != null && _customEndTime != null
                    ? IconButton.filledTonal(
                        onPressed: () async {
                          await _onCustomTimeSelection(
                              context, TimeSelection.custom);
                        },
                        icon: const Icon(Icons.edit_rounded),
                      )
                    : null,
                groupValue: _timeRangeTypeSelected,
                onChanged: (TimeSelection? value) async {
                  // If selected initially, then user clicks back to all day, and then back again, they won't be forced to enter the details again
                  if (_customStartTime == null || _customStartTime == null) {
                    await _onCustomTimeSelection(context, value);
                  } else {
                    // We still need to set the state though
                    setState(() {
                      if (value != null) _timeRangeTypeSelected = value;
                    });
                  }
                },
              ),
            ]),
        const SizedBox(height: 30),
        FilledButton.icon(
            onPressed: () => _onSubmit(context),
            label: const Text("Add Widget")),
        Text(
          "Tip: You can re-arrange the order of the widgets in Settings",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ]),
    );
  }
}
