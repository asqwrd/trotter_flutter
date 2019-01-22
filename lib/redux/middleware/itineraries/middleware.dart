import '../../actions/itineraries/actions.dart';
import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/index.dart';

Future<CreateItineraryData> postCreateItinerary(Store<AppState> store, dynamic data, [int index, bool undo = false]) async {
  final response = await http.post('http://localhost:3002/api/itineraries/create', body: json.encode(data), headers:{'Authorization':'security',"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    var itinerary = CreateItineraryResponseData.fromJson(json.decode(response.body));
    
    store.dispatch(
      new CreateItineraryAction(
        itinerary,
        true
      )
    );
    return CreateItineraryData(id: itinerary.id, success: true);
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
    //return CreateTripData(success: false);
  }
  
}

class CreateItineraryResponseData {
  final String id; 
  final List<dynamic> destinations; 

  CreateItineraryResponseData({this.id, this.destinations});

  factory CreateItineraryResponseData.fromJson(Map<String, dynamic> json) {
    return CreateItineraryResponseData(
      id: json['id'],
    );
  }
}

class CreateItineraryData {
  final String id; 
  final bool success;

  CreateItineraryData({this.id, this.success});

  factory CreateItineraryData.fromJson(Map<String, dynamic> json) {
    return CreateItineraryData(
      id: json['id'],
      success: true
    );
  }
}