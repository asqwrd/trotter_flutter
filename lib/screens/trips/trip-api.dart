import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';

Future<dynamic> postAddToTrip(String tripId, dynamic data) async {
  final response = await http.post('http://localhost:3002/api/trips/add/$tripId', body: json.encode(data), headers:{'Authorization':'security',"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return AddTripData.fromJson(json.decode(response.body));
  } else if(response.statusCode == 409){
    return AddTripErrorData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;

    throw Exception('Response> $msg');
  }
  
}

Future<dynamic> putUpdateTrip(String tripId, String destinationId, dynamic data) async {
  final response = await http.put('http://localhost:3002/api/trips/update/$tripId/destination/$destinationId', body: json.encode(data), headers:{'Authorization':'security',"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return UpdateTripData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    return {
      "success": false
    };
  }
  
}

Future<dynamic> deleteDestination(String tripId, String destinationId) async {
  final response = await http.delete('http://localhost:3002/api/trips/delete/$tripId/destination/$destinationId', headers:{'Authorization':'security',"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return UpdateTripData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    return {
      "success": false
    };
  }
  
}

class AddTripData {
  final dynamic destination; 
  final bool exist;

  AddTripData({this.destination, this.exist});

  factory AddTripData.fromJson(Map<String, dynamic> json) {
    return AddTripData(
      destination: json['destination'],
      exist: false
    );
  }
}

class UpdateTripData {
  final bool success;

  UpdateTripData({this.success});

  factory UpdateTripData.fromJson(Map<String, dynamic> json) {
    return UpdateTripData(
      success: json['success'],
    );
  }
}

class AddTripErrorData {
  final bool exist; 
  final String message; 

  AddTripErrorData({this.exist, this.message});

  factory AddTripErrorData.fromJson(Map<String, dynamic> json) {
    return AddTripErrorData(
      exist: json['exist'],
      message: json['message'],
    );
  }
}

