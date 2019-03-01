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

Future<ItineraryData> fetchItinerary(Store<AppState> store, String id) async {
  final response = await http.get('http://localhost:3002/api/itineraries/get/$id', headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    var results  = ItineraryData.fromJson(json.decode(response.body));
    print("hi fetch");
    store.dispatch(
      new GetItineraryAction(
        results.itinerary,
        results.destination,
        results.color 
      )
    );
    return results;
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

Future<DayData> fetchDay(String itineraryId, String dayId) async {

  final response = await http.get('http://localhost:3002/api/itineraries/get/$itineraryId/day/$dayId', headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return DayData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}


Future<AddItemData> addToDay(String itineraryId, String dayId, dynamic data) async {

  final response = await http.post('http://localhost:3002/api/itineraries/add/$itineraryId/day/$dayId', body: json.encode(data), headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON

    return AddItemData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    print(response);
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

class AddItemData {
  final Map<String, dynamic> itineraryItem; 

  AddItemData({this.itineraryItem});

  factory AddItemData.fromJson(Map<String, dynamic> json) {
    return AddItemData(
      itineraryItem: json['itinerary_item'],
    );
  }
}

class DayData {
  final Map<String, dynamic> day; 
  final Map<String, dynamic> itinerary; 
  final Map<String, dynamic> destination; 
  final String color;

  DayData({this.day, this.itinerary, this.color, this.destination});

  factory DayData.fromJson(Map<String, dynamic> json) {
    return DayData(
      day: json['day'],
      color: json['itinerary']['color'],
      destination: json['itinerary']['destination'],
      itinerary: json['itinerary']['itinerary']
    );
  }
}

class ItineraryData {
  final String color;
  final bool loading;
  final Map<String, dynamic> itinerary; 
  final Map<String, dynamic> destination; 

  ItineraryData({this.color, this.loading, this.itinerary, this.destination});

  factory ItineraryData.fromJson(Map<String, dynamic> json) {
    return ItineraryData(
      loading: false,
      itinerary: json['itinerary'],
      destination: json['destination'],
      color: json['color']
    );
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