import 'dart:convert';

import 'package:earth_quake_tracker/models/earthquake_model.dart';
import 'package:earth_quake_tracker/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as gc;

var data =
    "?format=geojson&starttime=2024-01-01&endtime=2024-01-02&minmagnitude=5";

class AppDataProvider with ChangeNotifier {
  final baseUrl = Uri.parse("https://earthquake.usgs.gov/fdsnws/event/1/query");
  //"https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2014-01-01&endtime=2014-01-02"
  Map<String, dynamic> queryParams = {};
  double _maxRadiusKm = 500;
  double _latitude = 0.0, _longitude = 0.0;
  String _startTime = '', _endTime = '';
  String _orderBy = 'time';
  String? _currentCity;
  final double _maxRadiusKmThreshold = 20001.6;
  bool _shouldUseLocation = false;
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

  bool get hasDataLoaded => earthquakeModel != null;

// My code
  bool hasSubsequentDataLoaded = false;
  bool fetchStatus = false;

  void setOrder(String value) {
    _orderBy = value;
    notifyListeners();

    _setQueryParams();
    getEarthquakeData();
  }

  String setOrderAndSnackBar(String value) {
    _orderBy = value;
    notifyListeners();

    _setQueryParams();
    getEarthquakeData();

    if (earthquakeModel!.features!.isEmpty) {
      return "Data empty or couldn't update data";
    }
    return "Data Updated";
  }

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
    // _startTime = '2014-01-01';
    _endTime = getFormattedDateTime(DateTime.now().microsecondsSinceEpoch);
    // _endTime = '2014-01-02';
    _maxRadiusKm = _maxRadiusKmThreshold;

    _setQueryParams();

    getEarthquakeData();
  }

  Color getAlertColor(String color) {
    return switch (color) {
      'green' => Colors.green,
      'yellow' => Colors.yellow,
      'orange' => Colors.orange,
      _ => Colors.red,
    };
  }

  Future<void> getEarthquakeData() async {
    final uri = Uri.https(baseUrl.authority, baseUrl.path, queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        earthquakeModel = EarthquakeModel.fromJson(json);
        notifyListeners();
      }
    } catch (error) {
      print(error.toString());
    }
  }

  void setStartTime(String date) {
    _startTime = date;
    _setQueryParams();
    notifyListeners();
  }

  void setEndTime(String date) {
    _endTime = date;
    _setQueryParams();
    notifyListeners();
  }

  Future<void> setUserLocation(bool value) async {
    _shouldUseLocation = value;
    notifyListeners();

    if (value == true) {
      final position = await _determinePosition();
      _latitude = position.latitude;
      _longitude = position.longitude;
      await _getCurrentCity();
      _maxRadiusKm = 500;
      _setQueryParams();
      getEarthquakeData();
    } else {
      _latitude = 0;
      _longitude = 0;
      _maxRadiusKm = _maxRadiusKmThreshold;
      _setQueryParams();
      getEarthquakeData();
    }
  }

  Future<void> _getCurrentCity() async {
    try {
      final placemarkList =
          await gc.placemarkFromCoordinates(_latitude, _longitude);

      if (placemarkList.isNotEmpty) {
        final placemark = placemarkList[0];
        _currentCity = placemark.locality;
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
