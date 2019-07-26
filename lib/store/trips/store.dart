import 'package:flutter_store/flutter_store.dart';

class TripsStore extends Store {
  List<dynamic> _trips;
  get trips => _trips;
  String tripsError;
  bool tripLoading = false;

  getTrips(List<dynamic> trips) {
    setState(() {
      _trips = trips;
    });
  }

  deleteTrip(String tripId) {
    var trips = []..addAll(_trips);
    trips.removeWhere((trip) => trip['id'] == tripId);
    setState(() {
      _trips = trips;
    });
  }

  updateTrip(dynamic trip) {
    var trips = []..addAll(_trips);
    trips.removeWhere((item) => item['id'] == trip['id']);
    trips.add(trip);
    setState(() {
      _trips = trips;
    });
  }

  updateTripDestinations(String tripId, dynamic destination) {
    var tripIndex = _trips.indexWhere((trip) => trip['id'] == tripId);
    var trips = []..addAll(_trips);
    trips[tripIndex]['destinations'].add(destination);
    setState(() {
      _trips = trips;
    });
  }

  undoTripDelete(dynamic trip, int index) {
    var trips = []..addAll(_trips);
    trips.insert(index, trip);
    setState(() {
      _trips = trips;
    });
  }

  createTrip(dynamic trip) {
    var trips = []..addAll(_trips);
    trips.insert(0, trip);
    setState(() {
      _trips = trips;
    });
  }

  setTripsLoading(bool value) {
    setState(() {
      tripLoading = value;
    });
  }

  setTripsError(String value) {
    setState(() {
      tripsError = value;
    });
  }
}
