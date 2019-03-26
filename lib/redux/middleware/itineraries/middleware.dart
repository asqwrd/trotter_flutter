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
    store.dispatch(
      new GetItineraryAction(
        results.itinerary,
        results.destination,
        results.color,
      )
    );
    return results;
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

Future<ItineraryData> fetchSelectedItinerary(Store<AppState> store, String id) async {
  final response = await http.get('http://localhost:3002/api/itineraries/get/$id', headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    var results  = ItineraryData.fromJson(json.decode(response.body));
    store.dispatch(
      new SelectItineraryAction(results.itinerary['id'], false, results.destination['id'], results.itinerary)
    );
    return results;
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

Future<ItineraryData> fetchItineraryBuilder(Store<AppState> store, String id) async {
  final response = await http.get('http://localhost:3002/api/itineraries/get/$id', headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    var results  = ItineraryData.fromJson(json.decode(response.body));
    store.dispatch(
      new GetItineraryBuilderAction(
        results.itinerary,
        results.destination,
        results.color,
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


Future<DayData> addToDay(Store<AppState> store, String itineraryId, String dayId, String destinationId, dynamic data, [bool optimize]) async {

  final response = await http.post('http://localhost:3002/api/itineraries/add/$itineraryId/day/$dayId?optimize=$optimize', body: json.encode(data), headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    var res = DayData.fromJson(json.decode(response.body));
    var itineraryItems = res.day['itinerary_items'];
    if(optimize == false){
      itineraryItems = itineraryItems.sublist(1);
      res.day['itinerary_items'] = itineraryItems;
    }
    store.dispatch(
      new UpdateDayAfterAddAction(dayId, itineraryItems, res.justAdded, res.itinerary, destinationId)
    );
    return res;
  } else {
    // If that response was not OK, throw an error.
    return DayData(success: false);
  }
  
}

Future<DeleteItemData> deleteFromDay(String itineraryId, String dayId, String itineraryItemId) async {

  final response = await http.delete('http://localhost:3002/api/itineraries/delete/$itineraryId/day/$dayId/place/$itineraryItemId', headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON

    return DeleteItemData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

Future<ItinerariesData> fetchItineraries(String filter) async {
  final response =  await http.get('http://localhost:3002/api/itineraries/all?$filter', headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return ItinerariesData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
}

class ItinerariesData {

  final List<dynamic> itineraries;
 

  ItinerariesData({this.itineraries});

  factory ItinerariesData.fromJson(Map<String, dynamic> json) {
    return ItinerariesData(
      itineraries: json['itineraries'],
    );
  }
}

class SelectItineraryData {

  final String selectedItineraryId;
  final Map<String, dynamic> selectedItinerary;
  final String destinationId;
  final bool loading;
 

  SelectItineraryData({this.loading, this.selectedItineraryId, this.destinationId, this.selectedItinerary});
}


class DeleteItemData {
  final int destinationsDeleted; 
  final bool success;

  DeleteItemData({this.destinationsDeleted, this.success});

  factory DeleteItemData.fromJson(Map<String, dynamic> json) {
    return DeleteItemData(
      success: json['success']
    );
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
  final String justAdded;
  final bool success;

  DayData({this.day, this.itinerary, this.color, this.destination, this.justAdded, this.success});

  factory DayData.fromJson(Map<String, dynamic> json) {
    return DayData(
      day: json['day'],
      color: json['itinerary']['color'],
      justAdded: json['justAdded'],
      destination: json['itinerary']['destination'],
      itinerary: json['itinerary']['itinerary'],
      success: true
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