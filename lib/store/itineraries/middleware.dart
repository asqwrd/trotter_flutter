import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trotter_flutter/store/store.dart';

Future<CreateItineraryData> postCreateItinerary(
    TrotterStore store, dynamic data,
    [int index, bool undo = false]) async {
  try {
    final response = await http.post(
        'http://localhost:3002/api/itineraries/create',
        body: json.encode(data),
        headers: {
          'Authorization': 'security',
          "Content-Type": "application/json"
        });
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var itinerary =
          CreateItineraryResponseData.fromJson(json.decode(response.body));

      return CreateItineraryData(id: itinerary.id, success: true);
    } else {
      //store.dispatch(new ErrorAction(null, 'create_itinerary'));
      return CreateItineraryData(success: false);
    }
  } catch (error) {
    //store.dispatch(new CreateItineraryAction(null, false));
    //store.dispatch(new ErrorAction(null, 'create_itinerary'));
    store.setOffline(false);
    return CreateItineraryData(success: false);
  }
}

Future<ItineraryData> fetchItinerary(TrotterStore store, String id) async {
  try {
    final response = await http.get(
        'http://localhost:3002/api/itineraries/get/$id',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = ItineraryData.fromJson(json.decode(response.body));
      store.getItinerary(
        results.itinerary,
        results.destination,
        results.color,
      );
      store.setItineraryError(null);
      store.setOffline(false);
      store.setItineraryLoading(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      store.setItineraryError('Server is down');
      store.setOffline(true);
      return ItineraryData(error: 'Response> $msg');
    }
  } catch (error) {
    store.setItineraryError('Server is down');
    store.setOffline(true);
    return ItineraryData(error: 'Server is down');
  }
}

Future<ItineraryData> fetchSelectedItinerary(
    TrotterStore store, String id) async {
  try {
    final response = await http.get(
        'http://localhost:3002/api/itineraries/get/$id',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = ItineraryData.fromJson(json.decode(response.body));

      store.setSelectedItinerary(results.itinerary['id'], false,
          results.destination['id'], results.itinerary);

      store.setItineraryError(null);
      store.setOffline(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      store.setItineraryError('Server is down');
      store.setOffline(true);
      return ItineraryData(error: 'Response> $msg');
    }
  } catch (error) {
    store.setItineraryError('Server is down');
    store.setOffline(true);
    return ItineraryData(error: 'Server is down');
  }
}

Future<ItineraryData> fetchItineraryBuilder(
    TrotterStore store, String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.get(
        'http://localhost:3002/api/itineraries/get/$id',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = ItineraryData.fromJson(json.decode(response.body));
      await prefs.setString('itinerary_$id', response.body);
      store.getItineraryBuilder(
        results.itinerary,
        results.destination,
        results.color,
      );
      store.setItineraryError(null);
      store.setOffline(false);
      store.setItineraryBuilderLoading(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      //store.setItineraryError('Server is down');
      store.setOffline(true);
      return ItineraryData(error: 'Response> $msg');
    }
  } catch (error) {
    final String cacheData = prefs.getString('itinerary_$id') ?? null;
    if (cacheData != null) {
      var itineraryData = json.decode(cacheData);
      var results = ItineraryData.fromJson(itineraryData);
      store.getItineraryBuilder(
        results.itinerary,
        results.destination,
        results.color,
      );
      store.setItineraryBuilderLoading(false);
      store.setItineraryBuilderError('Server is down');
      store.setOffline(true);
      return results;
    }
    store.setItineraryError('Server is down');
    store.setItineraryBuilderLoading(false);
    return ItineraryData(error: 'Server is down');
  }
}

Future<DayData> fetchDay(String itineraryId, String dayId) async {
  try {
    final response = await http.get(
        'http://localhost:3002/api/itineraries/get/$itineraryId/day/$dayId',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return DayData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      return DayData(error: 'Response> $msg');
    }
  } catch (error) {
    return DayData(error: 'Server is down');
  }
}

//Stoping point

Future<DayData> addToDay(TrotterStore store, String itineraryId, String dayId,
    String destinationId, dynamic data,
    [bool optimize]) async {
  try {
    final response = await http.post(
        'http://localhost:3002/api/itineraries/add/$itineraryId/day/$dayId?optimize=$optimize',
        body: json.encode(data),
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var res = DayData.fromJson(json.decode(response.body));
      var itineraryItems = res.day['itinerary_items'];
      if (optimize == false) {
        itineraryItems = itineraryItems.sublist(1);
        res.day['itinerary_items'] = itineraryItems;
      }
      if (store.selectedItinerary.selectedItineraryId == itineraryId) {
        store.updateSelectedItinerary(
            dayId, itineraryItems, res.justAdded, res.itinerary, destinationId);
      }
      store.updateItineraryBuilder(
          dayId, itineraryItems, res.justAdded, res.itinerary, destinationId);
      store.setItineraryError(null);
      store.setOffline(false);
      return res;
    } else {
      // If that response was not OK, throw an error.
      store.setItineraryError('Server is down');
      store.setOffline(true);
      return DayData(success: false);
    }
  } catch (error) {
    store.setItineraryError('Server is down');
    store.setOffline(true);
    return DayData(success: false);
  }
}

Future<DeleteItemData> deleteFromDay(
    String itineraryId, String dayId, String itineraryItemId) async {
  try {
    final response = await http.delete(
        'http://localhost:3002/api/itineraries/delete/$itineraryId/day/$dayId/place/$itineraryItemId',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON

      return DeleteItemData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return DeleteItemData(success: false);
    }
  } catch (error) {
    return DeleteItemData(success: false);
  }
}

Future<ItinerariesData> fetchItineraries(String filter) async {
  final response = await http.get(
      'http://localhost:3002/api/itineraries/all?$filter',
      headers: {'Authorization': 'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return ItinerariesData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    return ItinerariesData(success: false);
  }
}

class ItinerariesData {
  final List<dynamic> itineraries;
  final bool success;

  ItinerariesData({this.itineraries, this.success});

  factory ItinerariesData.fromJson(Map<String, dynamic> json) {
    return ItinerariesData(itineraries: json['itineraries'], success: true);
  }
}

class SelectItineraryData {
  final String selectedItineraryId;
  final Map<String, dynamic> selectedItinerary;
  final String destinationId;
  final bool loading;

  SelectItineraryData(
      {this.loading,
      this.selectedItineraryId,
      this.destinationId,
      this.selectedItinerary});
}

class DeleteItemData {
  final int destinationsDeleted;
  final bool success;

  DeleteItemData({this.destinationsDeleted, this.success});

  factory DeleteItemData.fromJson(Map<String, dynamic> json) {
    return DeleteItemData(success: json['success']);
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
  final String error;

  DayData(
      {this.day,
      this.itinerary,
      this.color,
      this.destination,
      this.justAdded,
      this.success,
      this.error});

  factory DayData.fromJson(Map<String, dynamic> json) {
    return DayData(
        day: json['day'],
        color: json['itinerary']['color'],
        justAdded: json['justAdded'],
        destination: json['itinerary']['destination'],
        itinerary: json['itinerary']['itinerary'],
        success: true,
        error: null);
  }
}

class ItineraryData {
  final String color;
  final bool loading;
  final Map<String, dynamic> itinerary;
  final Map<String, dynamic> destination;
  final String error;

  ItineraryData(
      {this.color, this.loading, this.itinerary, this.destination, this.error});

  factory ItineraryData.fromJson(Map<String, dynamic> json) {
    return ItineraryData(
        loading: false,
        itinerary: json['itinerary'],
        destination: json['destination'],
        color: json['color'],
        error: null);
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
    return CreateItineraryData(id: json['id'], success: true);
  }
}
