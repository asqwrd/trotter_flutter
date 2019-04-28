import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../actions/trips/actions.dart';
import '../../actions/common-actions.dart';
import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/index.dart';

Future<TripsData> fetchTrips(Store<AppState> store) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.get('http://localhost:3002/api/trips/all?owner_id=${store.state.currentUser.uid}', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = TripsData.fromJson(json.decode(response.body));
      if(results.error == null){
        await prefs.setString('trips', response.body);
        store.dispatch(
          new GetTripsAction(
            results.trips,
          )
        );
         store.dispatch(
          new ErrorAction(
            null,
            'trips'
          )
        );
        store.dispatch(
          new OfflineAction(
            false,
          )
        );
      } else if(results.error != null){
         store.dispatch(
          new ErrorAction(
            results.error,
            null
          )
        );
      }
      store.dispatch(new SetTripsLoadingAction(false));
      return results;
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      return TripsData(error: "Response > $msg");
    }
  } catch(error){
    final String cacheData = prefs.getString('trips') ?? null;
    if(cacheData != null) {
       var tripsData = json.decode(cacheData);
       var results = TripsData.fromJson(tripsData);
       store.dispatch(
        new GetTripsAction(
          results.trips,
        )
      );
      store.dispatch(new SetTripsLoadingAction(false));
      store.dispatch(
        new OfflineAction(
          true,
        )
      );
      store.dispatch(
        new ErrorAction(
          null,
          'trips'
        )
      );
      return results;
    } else {
      store.dispatch(
        new ErrorAction(
          "Server is down",
          "trips"
        )
      );
      store.dispatch(new SetTripsLoadingAction(false));
      return TripsData(error: "Server is down");
    }
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
  try {
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
      store.dispatch(new ErrorAction(null,null));
      store.dispatch(new OfflineAction(
        false,
      ));
      return CreateTripData(trip: trip, success: true);
    } else {
      // If that response was not OK, throw an error.
      store.dispatch(new ErrorAction('Server is down', 'create_trip'));
      store.dispatch(new OfflineAction(
        true,
      ));
      return CreateTripData(success: false);
    }
  } catch(error){
    store.dispatch(new ErrorAction('Server is down', 'create_trip'));
    store.dispatch(new OfflineAction(
      true,
    ));
    return CreateTripData(success: false);
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
  final String error;

  TripsData({this.trips, this.error});

  factory TripsData.fromJson(Map<String, dynamic> json) {
    return TripsData(
      trips: json['trips'],
      error:null
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
  try {
    final response = await http.post('http://localhost:3002/api/trips/add/$tripId', body: json.encode(data), headers:{'Authorization':'security',"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return AddTripData.fromJson(json.decode(response.body));
    } else if(response.statusCode == 409){
      return AddTripErrorData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return AddTripData(success: false);
    }
  } catch(error){
    return AddTripData(success: false);
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
  final bool success;

  AddTripData({this.destination, this.exists, this.success});

  factory AddTripData.fromJson(Map<String, dynamic> json) {
    return AddTripData(
      destination: json['destination'],
      exists: false,
      success: true
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