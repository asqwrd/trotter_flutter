import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/globals.dart';

Future<CreateItineraryData> postCreateItinerary(
    TrotterStore store, dynamic data,
    [int index, bool undo = false]) async {
  try {
    final response = await http.post('$ApiDomain/api/itineraries/create',
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

Future<ItineraryData> fetchItinerary(String id, [TrotterStore store]) async {
  try {
    final response = await http.get('$ApiDomain/api/itineraries/get/$id',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = ItineraryData.fromJson(json.decode(response.body));
      store?.itineraryStore?.setItinerary(
        results.itinerary,
        results.destination,
        results.color,
      );
      store?.itineraryStore?.setItineraryError(null);
      store?.setOffline(false);
      store?.itineraryStore?.setItineraryLoading(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      store?.itineraryStore?.setItineraryError('Server is down');
      store?.setOffline(true);
      return ItineraryData(error: 'Response> $msg');
    }
  } catch (error) {
    store?.itineraryStore?.setItineraryError('Server is down');
    store?.setOffline(true);
    return ItineraryData(error: 'Server is down');
  }
}

Future<StartLocationData> updateStartLocation(String id, dynamic data,
    [TrotterStore store]) async {
  try {
    final response = await http.put(
        '$ApiDomain/api/itineraries/update/$id/startLocation',
        body: json.encode(data),
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = StartLocationData.fromJson(json.decode(response.body));
      store?.itineraryStore?.updateStartLocation(results.startLocation);

      return results;
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      print(msg);
      return StartLocationData(success: false);
    }
  } catch (error) {
    return StartLocationData(success: false);
  }
}

Future<ItineraryData> fetchSelectedItinerary(
    TrotterStore store, String id) async {
  try {
    final response = await http.get('$ApiDomain/api/itineraries/get/$id',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = ItineraryData.fromJson(json.decode(response.body));

      store.itineraryStore.setSelectedItinerary(results.itinerary['id'],
          results.destination['id'], results.itinerary, false);

      store.itineraryStore.setItineraryError(null);
      store.setOffline(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      store.itineraryStore.setItineraryError('Server is down');
      store.setOffline(true);
      return ItineraryData(error: 'Response> $msg');
    }
  } catch (error) {
    store.itineraryStore.setItineraryError('Server is down');
    store.setOffline(true);
    return ItineraryData(error: 'Server is down');
  }
}

Future<ItineraryData> fetchItineraryBuilder(String id,
    [TrotterStore store]) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.get('$ApiDomain/api/itineraries/get/$id',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = ItineraryData.fromJson(json.decode(response.body));
      await prefs.setString('itinerary_$id', response.body);
      store?.itineraryStore?.setItineraryBuilder(
        results.itinerary,
        results.destination,
        results.color,
      );
      store?.itineraryStore?.setItineraryBuilderError(null);
      store?.setOffline(false);
      store?.itineraryStore?.setItineraryBuilderLoading(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      //store.setItineraryError('Server is down');
      store?.setOffline(true);
      return ItineraryData(error: 'Response> $msg');
    }
  } catch (error) {
    final String cacheData = prefs.getString('itinerary_$id') ?? null;
    if (cacheData != null) {
      var itineraryData = json.decode(cacheData);
      var results = ItineraryData.fromJson(itineraryData);
      store?.itineraryStore?.setItineraryBuilder(
        results.itinerary,
        results.destination,
        results.color,
      );
      store?.itineraryStore?.setItineraryBuilderLoading(false);
      store?.itineraryStore?.setItineraryBuilderError('Server is down');
      store?.setOffline(true);
      return results;
    }
    store?.itineraryStore?.setItineraryError('Server is down');
    store?.itineraryStore?.setItineraryBuilderLoading(false);
    return ItineraryData(error: 'Server is down');
  }
}

Future<DayData> fetchDay(String itineraryId, String dayId,
    [dynamic startLocation, String filter = '']) async {
  var location = '';
  double distanceInMeters = -1;
  Position position;
  final PermissionStatus isLocationEnabled =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.location);

  if (startLocation != null && isLocationEnabled == PermissionStatus.granted) {
    location = '${startLocation['lat']},${startLocation['lng']}';
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    distanceInMeters = await Geolocator().distanceBetween(position.latitude,
        position.longitude, startLocation['lat'], startLocation['lng']);

    if (distanceInMeters < 50000) {
      location = '${position.latitude},${position.longitude}';
    }
  }

  try {
    final response = await http.get(
        '$ApiDomain/api/itineraries/get/$itineraryId/day/$dayId?latlng=$location&filter=$filter',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = DayData.fromJson(json.decode(response.body));
      results.usedCurrentPoistion =
          distanceInMeters >= 0 && distanceInMeters <= 50000;
      results.currentPosition = results.usedCurrentPoistion == true
          ? {
              "location": {'lat': position.latitude, 'lng': position.longitude},
              "name": "you"
            }
          : null;
      print(results.usedCurrentPoistion);
      return results;
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
    [bool optimize, userId = '', copied = '']) async {
  try {
    final response = await http.post(
        '$ApiDomain/api/itineraries/add/$itineraryId/day/$dayId?optimize=$optimize&userId=$userId&copied=$copied',
        body: json.encode(data),
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var res = DayData.fromJson(json.decode(response.body));
      var itineraryItems = res.day['itinerary_items'];
      var allItineraryItems = [...itineraryItems, ...res.visited];
      if (optimize == false) {
        itineraryItems = itineraryItems.sublist(1);
        allItineraryItems = [...itineraryItems, ...res.visited];
        res.day['itinerary_items'] = itineraryItems;
      }
      if (store.itineraryStore.selectedItinerary != null &&
          store.itineraryStore.selectedItinerary.selectedItineraryId ==
              itineraryId) {
        store.itineraryStore.updateSelectedItinerary(dayId, allItineraryItems,
            res.justAdded, res.itinerary, destinationId);
      }
      if (store.itineraryStore.itineraryBuilder.itinerary != null &&
          store.itineraryStore.itineraryBuilder.itinerary['id'] ==
              itineraryId) {
        store.itineraryStore.updateItineraryBuilder(dayId, allItineraryItems,
            res.justAdded, res.itinerary, destinationId);
      }
      store.itineraryStore.setItineraryError(null);
      store.setOffline(false);

      return res;
    } else {
      // If that response was not OK, throw an error.
      store.itineraryStore.setItineraryError('Server is down');
      store.setOffline(true);
      return DayData(success: false);
    }
  } catch (error) {
    print(error);
    store.itineraryStore.setItineraryError('Server is down');
    store.setOffline(true);
    return DayData(success: false);
  }
}

Future<DayData> toggleVisited(
  TrotterStore store,
  String tripId,
  String itineraryId,
  String dayId,
  String itineraryItemId,
  dynamic data,
) async {
  try {
    final response = await http.put(
        '$ApiDomain/api/itineraries/$itineraryId/day/$dayId/itinerary_items/$itineraryItemId/toggle?tripId=$tripId&userId=${store.currentUser.uid}',
        body: json.encode(data),
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var res = DayData.fromJson(json.decode(response.body));

      var itineraryItems = res.day['itinerary_items'];
      itineraryItems = itineraryItems.sublist(1);
      var allItineraryItems = [...itineraryItems, ...res.visited];
      res.day['itinerary_items'] = itineraryItems;
      if (store.itineraryStore.itineraryBuilder.itinerary != null &&
          store.itineraryStore.itineraryBuilder.itinerary['id'] ==
              itineraryId) {
        store.itineraryStore.updateItineraryBuilder(
            dayId, allItineraryItems, res.justAdded, res.itinerary);
      }

      store.itineraryStore.setItineraryError(null);
      store.setOffline(false);

      return res;
    } else {
      // If that response was not OK, throw an error.
      store.itineraryStore.setItineraryError('Server is down');
      store.setOffline(true);
      return DayData(success: false);
    }
  } catch (error) {
    print(error);
    store.itineraryStore.setItineraryError('Server is down');
    store.setOffline(true);
    return DayData(success: false);
  }
}

Future<DescriptionData> addDescription(
  TrotterStore store,
  String tripId,
  String itineraryId,
  String dayId,
  String itineraryItemId,
  dynamic data,
) async {
  try {
    final response = await http.post(
        '$ApiDomain/api/itineraries/$itineraryId/day/$dayId/itinerary_items/$itineraryItemId/description?tripId=$tripId',
        body: json.encode(data),
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var res = DescriptionData.fromJson(json.decode(response.body));

      store.itineraryStore.setItineraryError(null);
      store.setOffline(false);

      return res;
    } else {
      // If that response was not OK, throw an error.
      store.itineraryStore.setItineraryError('Server is down');
      store.setOffline(true);
      return DescriptionData(success: false);
    }
  } catch (error) {
    print(error);
    store.itineraryStore.setItineraryError('Server is down');
    store.setOffline(true);
    return DescriptionData(success: false);
  }
}

Future<DeleteItemData> deleteFromDay(String itineraryId, String dayId,
    String itineraryItemId, String currentUserId,
    {sendNotification: true, movedPlaceId: '', movedDayId: ''}) async {
  try {
    final response = await http.delete(
        '$ApiDomain/api/itineraries/delete/$itineraryId/day/$dayId/place/$itineraryItemId?deletedBy=$currentUserId&sendNotification=$sendNotification&movedPlaceId=$movedPlaceId&movedDayId=$movedDayId',
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
  final response = await http.get('$ApiDomain/api/itineraries/all?$filter',
      headers: {'Authorization': 'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return ItinerariesData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    print(msg);
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
  final bool updating;

  SelectItineraryData(
      {this.loading,
      this.updating,
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
  final List<dynamic> visited;
  final bool success;
  bool usedCurrentPoistion;
  dynamic currentPosition;
  final String error;

  DayData(
      {this.day,
      this.itinerary,
      this.color,
      this.destination,
      this.justAdded,
      this.success,
      this.usedCurrentPoistion,
      this.currentPosition,
      this.visited,
      this.error});

  factory DayData.fromJson(Map<String, dynamic> json) {
    return DayData(
        day: json['day'],
        color: json['itinerary']['color'],
        justAdded: json['justAdded'],
        visited: json['visited'],
        destination: json['itinerary']['destination'],
        itinerary: json['itinerary']['itinerary'],
        success: true,
        usedCurrentPoistion: false,
        currentPosition: null,
        error: null);
  }
}

class ItineraryData {
  final String color;
  final bool loading;
  final Map<String, dynamic> itinerary;
  final Map<String, dynamic> destination;
  final List<dynamic> hotels;
  final String error;

  ItineraryData(
      {this.color,
      this.loading,
      this.itinerary,
      this.destination,
      this.error,
      this.hotels});

  factory ItineraryData.fromJson(Map<String, dynamic> json) {
    return ItineraryData(
        loading: false,
        itinerary: json['itinerary'],
        destination: json['destination'],
        color: json['color'],
        hotels: json['hotels'],
        error: null);
  }
}

class StartLocationData {
  final Map<String, dynamic> startLocation;
  final bool success;

  StartLocationData({
    this.startLocation,
    this.success,
  });

  factory StartLocationData.fromJson(Map<String, dynamic> json) {
    return StartLocationData(
        success: json['success'], startLocation: json['start_location']);
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

class DescriptionData {
  final List<dynamic> descriptions;
  final bool success;

  DescriptionData({this.descriptions, this.success});

  factory DescriptionData.fromJson(Map<String, dynamic> json) {
    return DescriptionData(descriptions: json['descriptions'], success: true);
  }
}
