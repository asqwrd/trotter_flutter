import 'package:redux/redux.dart';
import '../../actions/trips/actions.dart';

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

List<dynamic> updateTripsAfterCreateReducer(dynamic state, dynamic action) {
  var trips = []..addAll(state);
  trips.insert(0, action.trip);
  return trips;
}

List<dynamic> updateTripsDestinationReducer(dynamic state, dynamic action) {
  var tripIndex = state.indexWhere((trip)=> trip['id'] == action.tripId);
  var trips = []..addAll(state);
  trips[tripIndex]['destinations'].add(action.destination);

  return trips;
}

bool tripLoadingReducer(dynamic state, action) {
  if(action is SetTripsLoadingAction)
    return action.loading;
  return state;
}

List<dynamic> deleteTripReducer(dynamic state, action) {
  if(action is DeleteTripAction){
    var trips = []..addAll(state);
    trips.removeWhere((trip)=> trip['id'] == action.tripId);
    return trips;
  }
  return state;
}

List<dynamic> undoDeleteTripReducer(dynamic state, action) {
  if(action is UndoTripDeleteAction){
    var trips = []..addAll(state);
    trips.insert(action.index, action.trip);
    return trips;
  }
  return state;
}

final Reducer <List<dynamic>> tripsReducer = combineReducers <List<dynamic>>([
  new TypedReducer<List<dynamic>, GetTripsAction>(getTripsReducer),
  new TypedReducer<List<dynamic>, UpdateTripsFromTripAction>(updateTripsFromTripReducer),
  new TypedReducer<List<dynamic>, UpdateTripsAfterCreateAction>(updateTripsAfterCreateReducer),
  new TypedReducer<List<dynamic>, UpdateTripsDestinationAction>(updateTripsDestinationReducer),
  new TypedReducer<List<dynamic>, DeleteTripAction>(deleteTripReducer),
  new TypedReducer<List<dynamic>, UndoTripDeleteAction>(undoDeleteTripReducer),
]);

