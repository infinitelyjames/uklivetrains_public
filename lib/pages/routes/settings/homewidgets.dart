import 'package:flutter/material.dart';
import 'package:uklivetrains/modules/persistentdata.dart';
import 'package:uklivetrains/structs/departureboardquerytimed.dart';
import 'package:uklivetrains/structs/homescreenwidgetdetails.dart';
import 'package:uklivetrains/widgets/settings/settingscategorycontainer.dart';
import 'package:uklivetrains/widgets/settings/settingslink.dart';

typedef Callback = void Function();

// Referenced from Settings
class HomeWidgetsRoute extends StatefulWidget {
  const HomeWidgetsRoute({super.key});

  @override
  State<HomeWidgetsRoute> createState() => _HomeWidgetsRouteState();
}

class _HomeWidgetsRouteState extends State<HomeWidgetsRoute> {
  List<Widget> _homePageWidgets = [];
  HomeScreenWidgetsListSerializable? widgetsData;

  @override
  void initState() {
    super.initState();
    _buildHomePageWidgets();
  }

  Widget _getWidgetDetailsContainer(
      {Icon? icon,
      required String title,
      required String subtitle,
      Widget? trailing,
      Callback? callback}) {
    return ListTile(
      leading: icon,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      isThreeLine: true,
      onTap: callback,
    );
  }

  Future<void> _buildHomePageWidgets() async {
    // Only bother loading on initial attempt (to prevent reloading from disk on setState({}))
    widgetsData ??= await HomeScreenWidgetsListSerializable.loadSaved();
    List<Widget> widgets = [];
    for (int i = 0; i < widgetsData!.widgets.length; i++) {
      HomeScreenWidgetDetails widgetDetails = widgetsData!.widgets[i];
      if (widgetDetails is DepartureBoardQueryTimed) {
        widgets.add(
          _getWidgetDetailsContainer(
            icon: const Icon(Icons.departure_board),
            title:
                "${widgetDetails.stationBoardQuery.startStation.name} ${widgetDetails.stationBoardQuery.destinationStation != null ? 'to ${widgetDetails.stationBoardQuery.destinationStation!.name} ' : ''}(Departure Board)",
            subtitle:
                "Shown ${widgetDetails.repeatingTimeSelection.toString()}",
            trailing: IconButton(
              onPressed: () {
                widgetsData!.widgets.removeAt(i);
                widgetsData!.savePersistent();
                _buildHomePageWidgets();
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        );
      } else {
        print(
            "WARNING: Unknown widget type: $widgetDetails, so not included on list");
      }
    }
    setState(() {
      _homePageWidgets = widgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage Customisation"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(padding: const EdgeInsets.all(10), children: [
        SettingsCategoryContainer(
            categoryName: "Add a widget",
            settingsActionWidgets: [
              SettingsLinkWidget(
                icon: const Icon(Icons.departure_board),
                title: "Departure Board",
              ),
              SettingsLinkWidget(
                icon: const Icon(Icons.train),
                title: "Train Service",
              ),
              SettingsLinkWidget(
                  icon: const Icon(Icons.directions_subway),
                  title: "London Underground Status"),
              SettingsLinkWidget(
                  icon: const Icon(Icons.warning_rounded),
                  title: "Service Disruptions"),
              SettingsLinkWidget(
                icon: const Icon(Icons.location_on),
                title: "Nearest Station",
              ),
            ]),
        const SizedBox(height: 5),
        SettingsCategoryContainer(
            categoryName: "Selected Widgets",
            settingsActionWidgets: _homePageWidgets)
      ]),
    );
  }
}
