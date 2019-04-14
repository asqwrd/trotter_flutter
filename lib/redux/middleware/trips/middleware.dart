import 'dart:async';

import '../../actions/trips/actions.dart';
import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/index.dart';

Future<TripsData> fetchTrips(Store<AppState> store) async {
  try {
    final response = await http.get('http://localhost:3002/api/trips/all?owner_id=${store.state.currentUser.uid}', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = TripsData.fromJson(json.decode(response.body));
      store.dispatch(
        new GetTripsAction(
          results.trips, 
        )
      );
      store.dispatch(new SetTripsLoadingAction(false));
      return results;
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      return throw Exception('Response> $msg');
    }
  } catch(error){
    //return error;
  }
}

Future<DeleteTripData> deleteTrip(Store<AppState> store, String tripId) async {
  final response = await http.delete('http://localhost:3002/api/trips/delete/trip/$tripId', headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    var results = DeleteTripData.fromJson(json.decode(response.body));
    store.dispatch(
      new DeleteTripAction(
        tripId,
        results.success 
      )
    );
    return results;
  } else {
    // If that response was not OK, throw an error.
    store.dispatch(
      new DeleteTripAction(
        tripId,
        false 
      )
    );
    return DeleteTripData(success: false);
  }
  
}

Future<CreateTripData> postCreateTrip(Store<AppState> store, dynamic data, [int index, bool undo = false]) async {
  var owner = store.state.currentUser.uid;
  data['trip']['owner_id'] = owner;
  final response = await http.post('http://localhost:3002/api/trips/create/', body: json.encode(data), headers:{'Authorization':'security',"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    var results = CreateTripResponseData.fromJson(json.decode(response.body));
    var trip = results.trip;
    trip['destinations'] = results.destinations;
    if(index != null && undo == true){
      store.dispatch(
        new UndoTripDeleteAction(
          trip,
          index,
          true 
        )
      );
    } else {
      store.dispatch(
        new CreateTripAction(
          trip,
          true
        )
      );
    }
    return CreateTripData(trip: trip, success: true);
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
    //return CreateTripData(success: false);
  }
  
}

class CreateTripResponseData {
  final Map<String, dynamic> trip; 
  final List<dynamic> destinations; 

  CreateTripResponseData({this.trip, this.destinations});

  factory CreateTripResponseData.fromJson(Map<String, dynamic> json) {
    return CreateTripResponseData(
      trip: json['trip'],
      destinations: json['destinations']
    );
  }
}

class CreateTripData {
  final Map<String, dynamic> trip; 
  final bool success;

  CreateTripData({this.trip, this.success});

  factory CreateTripData.fromJson(Map<String, dynamic> json) {
    return CreateTripData(
      trip: json['trip'],
      success: true
    );
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

class DeleteTripData {
  final int destinationsDeleted; 
  final bool success;

  DeleteTripData({this.destinationsDeleted, this.success});

  factory DeleteTripData.fromJson(Map<String, dynamic> json) {
    return DeleteTripData(
      destinationsDeleted: json['destinations_deleted'],
      success: json['success']
    );
  }
}
class DeleteTripError {
  final bool success;

  DeleteTripError({this.success});

  factory DeleteTripError.fromJson(Map<String, dynamic> json) {
    return DeleteTripError(
      success: false
    );
  }
}

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

Future<dynamic> putUpdateTripDestination(String tripId, String destinationId, dynamic data) async {
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

Future<dynamic> putUpdateTrip(String tripId, dynamic data) async {
  final response = await http.put('http://localhost:3002/api/trips/update/trip/$tripId', body: json.encode(data), headers:{'Authorization':'security',"Content-Type": "application/json"});
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
  final bool exists;

  AddTripData({this.destination, this.exists});

  factory AddTripData.fromJson(Map<String, dynamic> json) {
    return AddTripData(
      destination: json['destination'],
      exists: false
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