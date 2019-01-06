import 'package:redux/redux.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';


enum Actions { UpdateTrip, Loading }

class AppState {
  final List<dynamic> trips;
  final bool loading;
  AppState({
    @required this.trips,
    @required this.loading
  });
  AppState.initialState()
    : trips = List.unmodifiable(<dynamic>[]),
    loading = false;
}

//Actions
class GetTripsAction {
  final List<dynamic> trips;
  GetTripsAction(this.trips);
}

class UpdateTripsFromTripAction {
  final Map<String,dynamic> trip;
  UpdateTripsFromTripAction(this.trip);
}

class UpdateTripsDestinationAction {
  final String tripId;
  final dynamic destination;
  
  UpdateTripsDestinationAction(this.tripId, this.destination);
}

class SetLoadingAction {
  final bool loading;
  SetLoadingAction(this.loading);
}

//Reeducers
List<dynamic> getTripsReducer(dynamic state, dynamic action) {
  return []
  ..addAll(action.trips);
}

List<dynamic> updateTripsFromTripReducer(dynamic state, dynamic action) {
  var tripIndex = state.indexWhere((trip)=> trip['id'] == action.trip['id']);
  var trips = []..addAll(state);
  trips.replaceRange(tripIndex, tripIndex + 1, [action.trip]);

  return trips;
}

List<dynamic> updateTripsDestinationReducer(dynamic state, dynamic action) {
  var tripIndex = state.indexWhere((trip)=> trip['id'] == action.tripId);
  var trips = []..addAll(state);
  trips[tripIndex]['destinations'].add(action.destination);

  return trips;
}

AppState appStateReducer(AppState state, action) {
  return AppState(
    trips: tripsReducer(state.trips,action),
    loading: loadingReducer(state.loading, action)
  );
}

final Reducer <List<dynamic>> tripsReducer = combineReducers <List<dynamic>>([
  new TypedReducer<List<dynamic>, GetTripsAction>(getTripsReducer),
  new TypedReducer<List<dynamic>, UpdateTripsFromTripAction>(updateTripsFromTripReducer),
  new TypedReducer<List<dynamic>, UpdateTripsDestinationAction>(updateTripsDestinationReducer),
]);

bool loadingReducer(dynamic state, action) {
  if(action is SetLoadingAction)
    return action.loading;
  return state;
}


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