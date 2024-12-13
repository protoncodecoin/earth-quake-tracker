import 'package:earth_quake_tracker/providers/app_data_provider.dart';
import 'package:earth_quake_tracker/settings.dart';
import 'package:earth_quake_tracker/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    Provider.of<AppDataProvider>(context, listen: false).init();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Green Earth"),
        actions: [
          IconButton(
            onPressed: _showSortingDialog,
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) => provider.hasDataLoaded
            ? provider.earthquakeModel!.features!.isEmpty
                ? const Center(
                    child: Text("No record found"),
                  )
                : ListView.builder(
                    itemCount: provider.earthquakeModel!.features!.length,
                    itemBuilder: (context, index) {
                      final data = provider
                          .earthquakeModel!.features![index].properties!;
                      return ListTile(
                        title: Text(data.place ?? data.title ?? "Unknown"),
                        subtitle: Text(
                          getFormattedDateTime(
                              data.time!, 'EEE MMM dd yyyy hh:mm a'),
                        ),
                        trailing: Chip(
                          label: Text('${data.mag}'),
                          avatar: data.alert == null
                              ? null
                              : CircleAvatar(
                                  backgroundColor:
                                      provider.getAlertColor(data.alert),
                                ),
                        ),
                      );
                      // return ListTile(title: ,);
                    },
                  )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showSortingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sort by"),
        content: Consumer<AppDataProvider>(
          builder: (context, provider, child) => Column(
            mainAxisSize: MainAxisSize.min,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              RadioGroup(
                groupValue: provider.orderBy,
                value: 'magnitude',
                label: "Magnitude",
                onChange: (value) {
                  // provider.setOrder(value!);

                  String result = provider.setOrderAndSnackBar(value!);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result),
                    ),
                  );
                },
              ),
              RadioGroup(
                groupValue: provider.orderBy,
                value: 'magnitude-asc',
                label: "Magnitude-ASC",
                onChange: (value) {
                  // provider.setOrder(value!);

                  String result = provider.setOrderAndSnackBar(value!);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result),
                    ),
                  );
                },
              ),
              RadioGroup(
                groupValue: provider.orderBy,
                value: 'time-asc',
                label: "Time-Asc",
                onChange: (value) {
                  // provider.setOrder(value!);

                  String result = provider.setOrderAndSnackBar(value!);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result),
                    ),
                  );
                },
              ),
              RadioGroup(
                groupValue: provider.orderBy,
                value: 'time',
                label: "Time",
                onChange: (value) {
                  // provider.setOrder(value!);

                  String result = provider.setOrderAndSnackBar(value!);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

class RadioGroup extends StatelessWidget {
  final String groupValue;
  final String value;
  final String label;
  final Function(String?) onChange;

  const RadioGroup({
    super.key,
    required this.groupValue,
    required this.value,
    required this.label,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<String>(
          groupValue: groupValue,
          value: value,
          onChanged: onChange,
        ),
        Text(label)
      ],
    );
  }
}
