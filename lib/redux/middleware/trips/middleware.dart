import '../../actions/trips/actions.dart';
import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/index.dart';

Future<TripsData> fetchTrips(Store<AppState> store) async {
  final response = await http.get('http://localhost:3002/api/trips/all/', headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    var results = TripsData.fromJson(json.decode(response.body));
    store.dispatch(
      new GetTripsAction(
        results.trips, 
      )
    );
    return results;
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

class TripsData {
  final List<dynamic> trips; 

  TripsData({this.trips});

  factory TripsData.fromJson(Map<String, dynamic> json) {
    return TripsData(
      trips: json['trips'],
    );
  }
}