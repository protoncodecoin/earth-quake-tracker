import 'package:earth_quake_tracker/providers/app_data_provider.dart';
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
                          return ListTile(title: ,);
                        },
                      )
                : const Text("data")));
  }
}
