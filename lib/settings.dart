import 'package:earth_quake_tracker/providers/app_data_provider.dart';
import 'package:earth_quake_tracker/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) => ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            Text(
              "Time Settings",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Start Time"),
                    subtitle: Text(provider.startTime),
                    trailing: IconButton(
                      onPressed: () async {
                        final date = await selectDate();

                        if (date != null) {
                          provider.setStartTime(date);
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                  ListTile(
                    title: const Text("End Time"),
                    subtitle: Text(provider.endTime),
                    trailing: IconButton(
                      onPressed: () async {
                        final date = await selectDate();

                        if (date != null) {
                          provider.setEndTime(date);
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provider.getEarthquakeData();
                      showMessage(context, 'Changes Updated');
                    },
                    child: const Text("Update changes"),
                  ),
                  Text(
                    "Time Settings",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Card(
                    child: SwitchListTile(
                      title: Text(provider.currentCity ?? "Not set"),
                      subtitle: provider.currentCity == null
                          ? null
                          : Text(
                              "Earthquake data will be shown within ${provider.maxRadiusKm} km radius from ${provider.currentCity}"),
                      value: provider.shouldUseLocation,
                      onChanged: (value) async {
                        EasyLoading.show(status: "Getting location...");
                        provider.setUserLocation(value);
                        EasyLoading.dismiss();
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String?> selectDate() async {
    final dt = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (dt != null) {
      return getFormattedDateTime(dt.microsecondsSinceEpoch);
    }
    return null;
  }
}
