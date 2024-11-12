import 'dart:convert';

import 'package:earth_quake_tracker/models/earthquake_model.dart';
import 'package:earth_quake_tracker/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

var data =
    "?format=geojson&starttime=2024-01-01&endtime=2024-01-02&minmagnitude=5";

class AppDataProvider with ChangeNotifier {
  final baseUrl = Uri.parse("https://earthquake.usgs.gov/fdsnws/event/1/query");
  Map<String, dynamic> queryParams = {};
  double _maxRadiusKm = 500;
  final double _latitude = 0.0, _longitude = 0.0;
  String _startTime = '', _endTime = '';
  final String _orderBy = 'time';
  String? _currentCity;
  final double _maxRadiusKmThreshold = 20001.6;
  final bool _shouldUseLocation = false;
  EarthquakeModel? earthquakeModel;

  double get maxRadiusKm => _maxRadiusKm;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get startTime => _startTime;
  String get endTime => _endTime;
  String get orderBy => _orderBy;
  String? get currentCity => _currentCity;
  double get maxRadiusKmThreshold => _maxRadiusKmThreshold;
  bool get shouldUseLocation => _shouldUseLocation;

  _setQueryParams() {
    queryParams['format'] = 'geojson';
    queryParams['starttime'] = _startTime;
    queryParams['endtime'] = _endTime;
    queryParams['minmagnitude'] = '4';
    queryParams['orderby'] = _orderBy;
    queryParams['limit'] = '500';
    queryParams['latitude'] = '$_latitude';
    queryParams['longitude'] = '$_longitude';
    queryParams['maxradiuskm'] = '$_maxRadiusKm';
  }

  init() {
    _startTime = getFormattedDateTime(DateTime.now()
        .subtract(const Duration(days: 1))
        .millisecondsSinceEpoch);
    _endTime = getFormattedDateTime(DateTime.now().microsecondsSinceEpoch);
    _maxRadiusKm = _maxRadiusKmThreshold;

    _setQueryParams();

    getEarthquakeData();
  }

  Future<void> getEarthquakeData() async {
    final uri = Uri.https(baseUrl.authority, baseUrl.path, queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        earthquakeModel = EarthquakeModel.fromJson(json);
        print(earthquakeModel?.features?.length);
        notifyListeners();
      }
    } catch (error) {
      print(error.toString());
    }
  }
}
