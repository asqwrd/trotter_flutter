import 'package:redux/redux.dart';
import 'package:flutter/foundation.dart';
import '../../middleware/index.dart';
import '../models.dart';

class TripViewModel {
  final Function() onGetTrips;
  final Future<DeleteTripData> Function(String) onDeleteTrip;
  final Function(dynamic) onUpdateTripsFromTrip;
  final Future<CreateTripData> Function(dynamic) onCreateTrip;
  final Future<CreateTripData> Function(dynamic, int) undoDeleteTrip;

  TripViewModel(
      {this.onGetTrips,
      this.onDeleteTrip,
      this.onUpdateTripsFromTrip,
      this.onCreateTrip,
      this.undoDeleteTrip});

  factory TripViewModel.create(Store<AppState> store) {
    _onGetTrips() async {
      await fetchTrips(store);
    }

    _onDeleteTrip(String tripId) async {
      var data = await deleteTrip(store, tripId);
      return data;
    }

    _onCreateTrip(dynamic data) async {
      var trip = new Map<String, dynamic>.from(data)
        ..addAll({
          "user": {
            "displayName": store.state.currentUser.displayName,
            "photoUrl": store.state.currentUser.photoUrl,
            "email": store.state.currentUser.email,
            "phoneNumber": store.state.currentUser.phoneNumber,
            "uid": store.state.currentUser.uid,
          }
        });
      var results = await postCreateTrip(store, trip);
      return results;
    }

    _undoDeleteTrip(dynamic trip, int index) async {
      var data = new Map<String, dynamic>.from(trip)
        ..addAll({
          "user": {
            "displayName": store.state.currentUser.displayName,
            "photoUrl": store.state.currentUser.photoUrl,
            "email": store.state.currentUser.email,
            "phoneNumber": store.state.currentUser.phoneNumber,
            "uid": store.state.currentUser.uid,
          }
        });
      var results = await postCreateTrip(store, data, index, true);
      return results;
    }

    return TripViewModel(
      onGetTrips: _onGetTrips,
      onDeleteTrip: _onDeleteTrip,
      onCreateTrip: _onCreateTrip,
      undoDeleteTrip: _undoDeleteTrip,
    );
  }
}
