import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trotter_flutter/globals.dart';
import 'package:trotter_flutter/store/store.dart';

Future<TripsData> fetchTrips([TrotterStore store]) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.get(
        '$ApiDomain/api/trips/all?user_id=${store.currentUser.uid}',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = TripsData.fromJson(json.decode(response.body));
      if (results.error == null) {
        await prefs.setString('trips', response.body);
        store?.tripStore?.setTripsError(null);
        store?.setOffline(false);
        store?.tripStore?.setTrips(results.trips, results.pastTrips);
      } else if (results.error != null) {
        store.tripStore.setTripsError(results.error);
      }
      store?.setTripsLoading(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      return TripsData(error: "Response > $msg");
    }
  } catch (error) {
    final String cacheData = prefs.getString('trips') ?? null;
    if (cacheData != null) {
      var tripsData = json.decode(cacheData);
      var results = TripsData.fromJson(tripsData);
      store?.tripStore?.setTrips(results.trips, results.pastTrips);
      store?.tripStore?.setTripsError(null);
      store?.setOffline(true);
      store?.tripStore?.setTripsError(null);
      return results;
    } else {
      store?.tripStore?.setTripsError('Server is down');
      store?.setTripsLoading(false);
      return TripsData(error: "Server is down");
    }
  }
}

Future<FlightsAndAccomodationsData> fetchFlightsAccomodations(
    String tripId, String userId) async {
  try {
    final response = await http.get(
        '$ApiDomain/api/trips/$tripId/flights_accomodations?user_id=$userId',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return FlightsAndAccomodationsData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      print(msg);
      return FlightsAndAccomodationsData(error: 'Response> $msg');
    }
  } catch (error) {
    return FlightsAndAccomodationsData(error: 'Server is down');
  }
}

Future<DeleteTripData> deleteTrip(TrotterStore store, String tripId) async {
  try {
    final response = await http.delete(
        '$ApiDomain/api/trips/delete/trip/$tripId',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = DeleteTripData.fromJson(json.decode(response.body));
      store.tripStore.deleteTrip(tripId);
      return results;
    } else {
      // If that response was not OK, throw an error.
      store.setTripsLoading(false);
      return DeleteTripData(success: false);
    }
  } catch (error) {
    // If that response was not OK, throw an error.
    store.setTripsLoading(false);
    return DeleteTripData(success: false);
  }
}

Future<AddTravelerData> addTraveler(
    TrotterStore store, String tripId, dynamic data) async {
  try {
    final response = await http.post(
        '$ApiDomain/api/trips/$tripId/travelers/add',
        body: json.encode(data),
        headers: {
          'Authorization': 'security',
          "Content-Type": "application/json"
        });
    print(response.statusCode);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results =
          AddTravelerResponseData.fromJson(json.decode(response.body));
      var success = results.success;
      var exists = results.exists;
      return AddTravelerData(success: success, exists: exists);
    } else {
      // If that response was not OK, throw an error.
      store.tripStore.setTripsError('Server is down');
      store.setOffline(true);
      return AddTravelerData(success: false, exists: false);
    }
  } catch (error) {
    print(error);
    store.tripStore.setTripsError('Server is down');
    store.setOffline(true);
    return AddTravelerData(success: false, exists: false);
  }
}

Future<CreateTripData> postCreateTrip(TrotterStore store, dynamic data,
    [int index, bool undo = false]) async {
  try {
    var owner = store.currentUser.uid;
    data['trip']['owner_id'] = owner;
    data['trip']['group'] = [owner];
    final response = await http.post('$ApiDomain/api/trips/create/',
        body: json.encode(data),
        headers: {
          'Authorization': 'security',
          "Content-Type": "application/json"
        });
    print(response.statusCode);
    print(index);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = CreateTripResponseData.fromJson(json.decode(response.body));
      var trip = results.trip;
      trip['destinations'] = results.destinations;
      if (index != null && undo == true) {
        store.tripStore.undoTripDelete(trip, index);
      } else {
        store.tripStore.createTrip(trip);
      }
      store.tripStore.setTripsError(null);
      store.setTripsLoading(false);
      return CreateTripData(trip: trip, success: true);
    } else {
      // If that response was not OK, throw an error.
      store.tripStore.setTripsError('Server is down');
      store.setOffline(true);
      return CreateTripData(success: false);
    }
  } catch (error) {
    print(error);
    store.tripStore.setTripsError('Server is down');
    store.setOffline(true);
    return CreateTripData(success: false);
  }
}

Future<CreateTripData> undoDeleteTrip(
    TrotterStore store, dynamic data, int index) async {
  var results = await postCreateTrip(store, data, index, true);
  return results;
}

class CreateTripResponseData {
  final Map<String, dynamic> trip;
  final List<dynamic> destinations;

  CreateTripResponseData({this.trip, this.destinations});

  factory CreateTripResponseData.fromJson(Map<String, dynamic> json) {
    return CreateTripResponseData(
        trip: json['trip'], destinations: json['destinations']);
  }
}

class CreateTripData {
  final Map<String, dynamic> trip;
  final List<dynamic> destinations;
  final bool success;

  CreateTripData({this.trip, this.destinations, this.success});

  factory CreateTripData.fromJson(Map<String, dynamic> json) {
    return CreateTripData(
        trip: json['trip'], destinations: json['destinations'], success: true);
  }
}

class AddTravelerResponseData {
  final bool success;
  final bool exists;

  AddTravelerResponseData({this.success, this.exists});

  factory AddTravelerResponseData.fromJson(Map<String, dynamic> json) {
    return AddTravelerResponseData(
        success: json['success'], exists: json['exists']);
  }
}

class AddTravelerData {
  final bool exists;
  final bool success;

  AddTravelerData({this.success, this.exists});

  factory AddTravelerData.fromJson(Map<String, dynamic> json) {
    return AddTravelerData(success: json['success'], exists: json['exists']);
  }
}

class TripsData {
  final List<dynamic> trips;
  final List<dynamic> pastTrips;
  final String error;

  TripsData({this.trips, this.pastTrips, this.error});

  factory TripsData.fromJson(Map<String, dynamic> json) {
    return TripsData(
        trips: json['upcomingTrips'],
        pastTrips: json['pastTrips'],
        error: null);
  }
}

class TripsInviteData {
  final List<dynamic> success;
  final String error;

  TripsInviteData({this.success, this.error});

  factory TripsInviteData.fromJson(Map<String, dynamic> json) {
    return TripsInviteData(success: json['success'], error: null);
  }
}

class DeleteTripData {
  final int destinationsDeleted;
  final bool success;

  DeleteTripData({this.destinationsDeleted, this.success});

  factory DeleteTripData.fromJson(Map<String, dynamic> json) {
    return DeleteTripData(
        destinationsDeleted: json['destinations_deleted'],
        success: json['success']);
  }
}

class DeleteTripError {
  final bool success;

  DeleteTripError({this.success});

  factory DeleteTripError.fromJson(Map<String, dynamic> json) {
    return DeleteTripError(success: false);
  }
}

Future<dynamic> postAddToTrip(String tripId, dynamic data,
    [String currentUserId]) async {
  try {
    final response = await http.post(
        '$ApiDomain/api/trips/add/$tripId?updatedBy=$currentUserId',
        body: json.encode(data),
        headers: {
          'Authorization': 'security',
          "Content-Type": "application/json"
        });
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return AddTripData.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      return AddTripErrorData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return AddTripData(success: false);
    }
  } catch (error) {
    return AddTripData(success: false);
  }
}

Future<AddFlightsAndAccomodationsData> postAddFlightsAndAccomodations(
    String tripId, String destinationId, dynamic data) async {
  try {
    final response = await http.post(
        '$ApiDomain/api/trips/add/flights_accomodations/$tripId/destination/$destinationId',
        body: json.encode(data),
        headers: {
          'Authorization': 'security',
          "Content-Type": "application/json"
        });
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return AddFlightsAndAccomodationsData.fromJson(
          json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return AddFlightsAndAccomodationsData(success: false);
    }
  } catch (error) {
    print(error);
    return AddFlightsAndAccomodationsData(success: false);
  }
}

Future<AddFlightsAndAccomodationsData> deleteFlightsAndAccomodations(
    String tripId,
    String destinationId,
    String detailId,
    String currentUserId) async {
  try {
    final response = await http.delete(
        '$ApiDomain/api/trips/delete/flights_accomodations/$tripId/destination/$destinationId/detail/$detailId?deletedBy=$currentUserId',
        headers: {
          'Authorization': 'security',
          "Content-Type": "application/json"
        });
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return AddFlightsAndAccomodationsData.fromJson(
          json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return AddFlightsAndAccomodationsData(success: false);
    }
  } catch (error) {
    return AddFlightsAndAccomodationsData(success: false);
  }
}

Future<FlightsAndAccomodationsTravelersData>
    putUpdateFlightsAccommodationTravelers(String tripId, String destinationId,
        String detailId, dynamic data, String currentUserId) async {
  final response = await http.put(
      '$ApiDomain/api/trips/update/$tripId/destination/$destinationId/details/$detailId?updatedBy=$currentUserId',
      body: json.encode(data),
      headers: {
        'Authorization': 'security',
        "Content-Type": "application/json"
      });
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return FlightsAndAccomodationsTravelersData.fromJson(
        json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    print(response.statusCode);
    return FlightsAndAccomodationsTravelersData(error: 'Server is down');
  }
}

Future<dynamic> putUpdateTripDestination(
    String tripId, String destinationId, dynamic data) async {
  final response = await http.put(
      '$ApiDomain/api/trips/update/$tripId/destination/$destinationId',
      body: json.encode(data),
      headers: {
        'Authorization': 'security',
        "Content-Type": "application/json"
      });
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return UpdateTripData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    return {"success": false};
  }
}

Future<UpdateTripData> putUpdateTrip(
    String tripId, dynamic data, String currentUserId) async {
  final response = await http.put(
      '$ApiDomain/api/trips/update/trip/$tripId?updatedBy=$currentUserId',
      body: json.encode(data),
      headers: {
        'Authorization': 'security',
        "Content-Type": "application/json"
      });
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return UpdateTripData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    return UpdateTripData(success: false);
  }
}

Future<UpdateTripData> deleteDestination(String tripId, String destinationId,
    [String currentUserId]) async {
  try {
    final response = await http.delete(
        '$ApiDomain/api/trips/delete/$tripId/destination/$destinationId?updatedBy=$currentUserId',
        headers: {
          'Authorization': 'security',
          "Content-Type": "application/json"
        });
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return UpdateTripData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return UpdateTripData(success: false);
    }
  } catch (error) {
    return UpdateTripData(success: false);
  }
}

class AddTripData {
  final dynamic destination;
  final bool exists;
  final bool success;

  AddTripData({this.destination, this.exists, this.success});

  factory AddTripData.fromJson(Map<String, dynamic> json) {
    return AddTripData(
        destination: json['destination'], exists: false, success: true);
  }
}

class AddFlightsAndAccomodationsData {
  final dynamic result;
  final bool success;

  AddFlightsAndAccomodationsData({this.result, this.success});

  factory AddFlightsAndAccomodationsData.fromJson(Map<String, dynamic> json) {
    return AddFlightsAndAccomodationsData(
        result: json['result'], success: true);
  }
}

class FlightsAndAccomodationsData {
  final List<dynamic> flightsAccomodations;
  final String error;

  FlightsAndAccomodationsData({this.flightsAccomodations, this.error});

  factory FlightsAndAccomodationsData.fromJson(Map<String, dynamic> json) {
    return FlightsAndAccomodationsData(
        flightsAccomodations: json['flightsAccomodations'], error: null);
  }
}

class FlightsAndAccomodationsTravelersData {
  final dynamic travelers;
  final String error;

  FlightsAndAccomodationsTravelersData({this.travelers, this.error});

  factory FlightsAndAccomodationsTravelersData.fromJson(
      Map<String, dynamic> json) {
    return FlightsAndAccomodationsTravelersData(
        travelers: json['travelers'], error: null);
  }
}

class UpdateTripData {
  final bool success;
  final List<dynamic> travelers;

  UpdateTripData({this.success, this.travelers});

  factory UpdateTripData.fromJson(Map<String, dynamic> json) {
    return UpdateTripData(
        success: json['success'], travelers: json['travelers']);
  }
}

class AddTripErrorData {
  final bool exists;
  final String message;
  final dynamic destination;

  AddTripErrorData({this.exists, this.message, this.destination});

  factory AddTripErrorData.fromJson(Map<String, dynamic> json) {
    return AddTripErrorData(
      exists: json['exists'],
      destination: null,
      message: json['message'],
    );
  }
}
