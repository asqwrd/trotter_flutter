import 'dart:convert';

import 'package:flutter/services.dart';

class Airlines {
  String name;
  int id;
  String alias;
  String country;
  String iata;
  String icao;
  String callsign;
  String active;

  Airlines(
      {this.name,
      this.id,
      this.alias,
      this.country,
      this.iata,
      this.icao,
      this.callsign,
      this.active});

  factory Airlines.fromJson(Map<String, dynamic> parsedJson) {
    return Airlines(
        name: parsedJson['name'].toString(),
        id: parsedJson['id'],
        alias: parsedJson['alias'].toString(),
        country: parsedJson['country'].toString(),
        iata: parsedJson['iata'].toString(),
        icao: parsedJson['icao'].toString(),
        callsign: parsedJson['callsign'].toString(),
        active: parsedJson['active'].toString());
  }
}

class AirlinesViewModel {
  static List<Airlines> airlines;

  static Future loadAirlines() async {
    try {
      airlines = new List<Airlines>();
      String jsonString = await rootBundle.loadString('assets/airlines.json');
      Map parsedJson = json.decode(jsonString);
      var categoryJson = parsedJson['airlines'] as List;
      for (int i = 0; i < categoryJson.length; i++) {
        //print(categoryJson[i]);
        airlines.add(new Airlines.fromJson(categoryJson[i]));
      }
    } catch (e) {
      print(e);
    }
  }
}
