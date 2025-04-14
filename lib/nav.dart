import 'package:flutter/material.dart';
import 'package:uklivetrains/pages/settings.dart' as settings;
import 'package:uklivetrains/pages/home.dart' as home;
import 'package:uklivetrains/pages/journeys.dart' as journeys;
import 'package:uklivetrains/pages/livetrains.dart' as livetrains;
import 'package:uklivetrains/structs/themenotifier.dart';

class NavPartialPage extends StatefulWidget {
  const NavPartialPage({super.key, required this.themeNotifier});
  final ThemePairNotifier themeNotifier;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<NavPartialPage> createState() => _NavPartialPageState();
}

class _NavPartialPageState extends State<NavPartialPage> {
  int _selectedPageIndex = 0;

  final homePage = home.HomePage(key: PageStorageKey('HomePage'));
  final liveTrainsPage = const livetrains.LiveTrainsSearchPage(
      key: PageStorageKey('LiveTrainsSearchPage'));
  final journeysPage = const Center(
      key: PageStorageKey('JourneysPage'),
      child: Text("Not implemented yet (2)."));
  late final settings.SettingsPage settingsPage;

  @override
  void initState() {
    super.initState();
    settingsPage = settings.SettingsPage(
        themeNotifier: widget.themeNotifier,
        key: PageStorageKey('SettingsPage'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text([
          "Home",
          "Live Trains",
          "Journeys",
          "Settings"
        ][_selectedPageIndex]),
      ),
      body: IndexedStack(
        index: _selectedPageIndex,
        children: [
          homePage,
          liveTrainsPage,
          journeysPage,
          settingsPage,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color.alphaBlend(
          Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(255, 255, 255, 0.8) : const Color.fromRGBO(0, 0, 0, 0.83),
          Theme.of(context).colorScheme.primary.withOpacity(1),
        ),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.train),
            label: 'Live Trains',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: 'Journeys',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedPageIndex,
        onTap: (int index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
      ),
    );
  }
}
