
import 'package:flutter/material.dart';
import 'package:uklivetrains/modules/persistentdata.dart';
import 'package:uklivetrains/widgets/settings/settingscategorycontainer.dart';
import 'package:uklivetrains/widgets/settings/settingslink.dart';

enum ThemePreference {
  light,
  dark,
  system,
}

class LightModeDarkModeSettingsPage extends StatefulWidget {
  const LightModeDarkModeSettingsPage({super.key});

  @override
  State<LightModeDarkModeSettingsPage> createState() => _LightModeDarkModeSettingsPageState();
}

class _LightModeDarkModeSettingsPageState extends State<LightModeDarkModeSettingsPage> {
  ThemePreference? _selectedThemePreference;

  Future<void> _updateSavedThemePreference(ThemePreference newThemePreference) async {
    print("Debug: updating saved theme preference to $newThemePreference");
    LightDarkThemeDataSerializable lightDarkThemeDataSerializable = LightDarkThemeDataSerializable(themePreference: newThemePreference);
    await lightDarkThemeDataSerializable.savePersistent();
    setState(() {
      _selectedThemePreference = newThemePreference;
    });
    // TODO: trigger rebuild of app upon selection change
  }

  void _onSelectionChanged(ThemePreference? newSelection) {
    if (newSelection == null) return;
    _updateSavedThemePreference(newSelection);
  }

  Future<void> _loadSavedThemePreference() async {
    final LightDarkThemeDataSerializable serializableThemeData = await LightDarkThemeDataSerializable.loadSaved();
    // TODO: setState allowed in initState() ??? -- same methodology used in livetrains.dart to load starred station board queries
    setState(() {
      _selectedThemePreference = serializableThemeData.themePreference;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedThemePreference();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Light & Dark Themes"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(padding: const EdgeInsets.all(10), children:  [
        //Text("Light and dark themes share the same base colour and background image."),
        if (_selectedThemePreference != null)
        SettingsCategoryContainer(
            categoryName: "Select theme",
            settingsActionWidgets: [
              RadioListTile(
                title: const Text("Light"),
                value: ThemePreference.light, 
                groupValue: _selectedThemePreference, 
                onChanged: (ThemePreference? newThemePreference) => _onSelectionChanged(newThemePreference),
              ),
              RadioListTile(
                title: const Text("Dark"),
                value: ThemePreference.dark, 
                groupValue: _selectedThemePreference, 
                onChanged: (ThemePreference? newThemePreference) => _onSelectionChanged(newThemePreference),
              ),
              RadioListTile(
                title: const Text("System"),
                value: ThemePreference.system, 
                groupValue: _selectedThemePreference, 
                onChanged: (ThemePreference? newThemePreference) => _onSelectionChanged(newThemePreference),
              ),
            ])
        else const Text("Loading, please wait..."),
        Text(
          "Changes made will take place on next app restart", 
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ]),
    );
  }
}