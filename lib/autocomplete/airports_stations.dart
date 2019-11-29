import 'dart:convert';

import 'package:flutter/services.dart';

class AirportsStations {
  String name;
  int id;
  String alias;
  String country;
  String iata;
  String icao;
  String lat;
  String lon;
  String city;
  String timezoneName;
  String type;

  AirportsStations(
      {this.name,
      this.id,
      this.alias,
      this.lat,
      this.lon,
      this.country,
      this.iata,
      this.icao,
      this.city,
      this.type,
      this.timezoneName});

  factory AirportsStations.fromJson(Map<String, dynamic> parsedJson) {
    return AirportsStations(
        name: parsedJson['name'].toString(),
        id: parsedJson['id'],
        alias: parsedJson['alias'].toString(),
        lat: parsedJson['lat'].toString(),
        lon: parsedJson['long'].toString(),
        country: parsedJson['country'].toString(),
        iata: parsedJson['iata'].toString(),
        icao: parsedJson['icao'].toString(),
        city: parsedJson['city'].toString(),
        type: parsedJson['type'].toString(),
        timezoneName: parsedJson['timezone_name'].toString());
  }
}

class AirportsViewModel {
  static List<AirportsStations> airports;

  static Future loadAirports() async {
    if (airports == null) {
      try {
        airports = new List<AirportsStations>();
        String jsonString =
            await rootBundle.loadString('assets/airports_stations.json');
        Map parsedJson = json.decode(jsonString);
        var categoryJson = parsedJson['airports_stations'] as List;
        for (int i = 0; i < categoryJson.length; i++) {
          if (categoryJson[i]['type'] == 'airport')
            airports.add(new AirportsStations.fromJson(categoryJson[i]));
        }
      } catch (e) {
        print(e);
      }
    }
  }
}

class StationsViewModel {
  static List<AirportsStations> stations;

  static Future loadStations() async {
    try {
      stations = new List<AirportsStations>();
      String jsonString =
          await rootBundle.loadString('assets/airports_stations.json');
      Map parsedJson = json.decode(jsonString);
      var categoryJson = parsedJson['airports_stations'] as List;
      for (int i = 0; i < categoryJson.length; i++) {
        if (categoryJson[i]['type'] == 'station')
          stations.add(new AirportsStations.fromJson(categoryJson[i]));
      }
    } catch (e) {
      print(e);
    }
  }
}
