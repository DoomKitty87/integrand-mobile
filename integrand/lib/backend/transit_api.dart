import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class StopLive {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String direction;
  final List<int> routes;

  List<dynamic> arrivals = [];

  Future<void> update() async {
    http.Response response = await http.get(Uri.parse(
        "${TransitAPI.arrivalsUrl}?locIDs=$id&showPosition=true&appID=${TransitAPI.appId}"));
    arrivals = jsonDecode(response.body)["resultSet"]["arrival"];
  }

  StopLive(this.id, this.name, this.latitude, this.longitude, this.direction,
      this.routes);
}

class Stop {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String direction;
  final List<int> routes;

  Stop(this.id, this.name, this.latitude, this.longitude, this.direction,
      this.routes);
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/stops.json').path;
}

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

class TransitAPI with ChangeNotifier {
  List<Stop> staticStopData = [];

  List<StopLive> savedStops = [];
  List<StopLive> nearbyStops = [];

  static const int updateInterval = 60;
  static const int nearbyRadius = 1600;
  static const String stopsUrl =
      "https://developer.trimet.org/ws/V1/routeConfig/stops/true/json/true/dir/true/appid/E3CD8568B5DDD3C637CB78337";
  static const String arrivalsUrl =
      "https://developer.trimet.org/ws/v2/arrivals/";
  static const String appId = "E3CD8568B5DDD3C637CB78337";

  void addSavedStop(StopLive stop) {
    if (savedStops.contains(stop)) {
      return;
    }
    savedStops.add(stop);
    notifyListeners();
  }

  void removeSavedStop(StopLive stop) {
    savedStops.remove(stop);
    notifyListeners();
  }

  void initialize() async {
    // print("Initializing TransitAPI");
    // Check if data for local transit provider is downloaded
    if (File(await _localPath).existsSync()) {
      // Load data from storage
      // print("Loading stops from storage");

      File file = File(await _localPath);
      String data = await file.readAsString();
      // Parse data
      List<dynamic> stops = jsonDecode(data);
      for (var stop in stops) {
        staticStopData.add(Stop(stop["locid"], stop["desc"], stop["lat"],
            stop["lng"], stop["dir"], stop["routes"].cast<int>()));
      }
      //print("Loaded ${staticStopData.length} stops from storage");
    } else {
      // Download data from api
      http.Response response = await http.get(Uri.parse(stopsUrl));
      // print(response.body);
      List<dynamic> routes = jsonDecode(response.body)["resultSet"]["route"];
      List<dynamic> stops = [];
      Map<int, List<int>> stopRoutes = {};
      for (var route in routes) {
        // if (route["type"] != "B") {
        //   continue;
        // }
        for (var dir in route["dir"]) {
          if (dir["stop"] == null) {
            continue;
          }
          for (var stop in dir["stop"]) {
            stops.add(stop);
            if (!stopRoutes.containsKey(stop["locid"])) {
              stopRoutes[stop["locid"]] = [];
            }
            if (!(stopRoutes[stop["locid"]]!.contains(route["route"]))) {
              stopRoutes[stop["locid"]]?.add(route["route"]);
            }
          }
        }
      }

      Set<int> ids = {};
      stops.retainWhere((stop) => ids.add(stop["locid"]));

      for (var stop in stops) {
        staticStopData.add(Stop(stop["locid"], stop["desc"], stop["lat"],
            stop["lng"], stop["dir"], stopRoutes[stop["locid"]]!));
      }

      // Reorganize stops data for storage
      stops = [];
      for (var stop in staticStopData) {
        stops.add({
          "locid": stop.id,
          "desc": stop.name,
          "lat": stop.latitude,
          "lng": stop.longitude,
          "dir": stop.direction,
          "routes": stop.routes
        });
      }

      // Save data to storage
      File file = File(await _localPath);
      //print("Saving ${staticStopData.length} stops to storage");
      // print(await _localPath);
      await file.writeAsString(jsonEncode(stops));
    }

    // Load saved stops from storage

    // Load nearby stops from location
    Position position = await _determinePosition();

    for (var stop in staticStopData) {
      double distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, stop.latitude, stop.longitude);
      if (distance < nearbyRadius) {
        // print("Adding nearby stop ${stop.name}");
        nearbyStops.add(StopLive(stop.id, stop.name, stop.latitude,
            stop.longitude, stop.direction, stop.routes));
      }
    }

    // Sort nearby stops by distance
    nearbyStops.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(
          position.latitude, position.longitude, a.latitude, a.longitude);
      double distanceB = Geolocator.distanceBetween(
          position.latitude, position.longitude, b.latitude, b.longitude);
      return distanceA.compareTo(distanceB);
    });

    // Limit to 5 nearby stops
    nearbyStops = nearbyStops.sublist(0, 5);

    for (var stop in nearbyStops) {
      await stop.update();
    }

    notifyListeners();

    // Start timer to update stops
    Timer.periodic(const Duration(seconds: updateInterval), (timer) async {
      // Update stop data with live bus locations
      for (var liveStop in savedStops) {
        await liveStop.update();
      }

      for (var liveStop in nearbyStops) {
        await liveStop.update();
      }

      notifyListeners();
    });
  }

  TransitAPI() {
    // print("TransitAPI constructor");
    initialize();
  }
}
