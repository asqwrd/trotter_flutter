import 'package:flutter_store/flutter_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trotter_flutter/redux/middleware/itineraries/middleware.dart';
import 'package:trotter_flutter/store/auth.dart';

class TrotterStore extends Store {
  FirebaseUser _currentUser;
  get currentUser => _currentUser;
  List<dynamic> _trips;
  get trips => _trips;
  ItineraryData _itinerary = ItineraryData(
      itinerary: null,
      loading: true,
      color: null,
      destination: null,
      error: null);
  get itinerary => _itinerary;
  SelectItineraryData _selectedItinerary = SelectItineraryData(
    loading: false,
    selectedItineraryId: null,
    selectedItinerary: null,
    destinationId: null,
  );
  get selectedItinerary => _selectedItinerary;
  ItineraryData _itineraryBuilder = ItineraryData(
      itinerary: null,
      loading: true,
      color: null,
      destination: null,
      error: null);
  get itineraryBuilder => _itineraryBuilder;
  bool tripLoading = false;
  bool offline = false;
  String tripsError;

  setTripsLoading(bool value) {
    setState(() {
      tripLoading = value;
    });
  }

  setOffline(bool value) {
    setState(() {
      offline = value;
    });
  }

  setTripsError(String value) {
    setState(() {
      tripsError = value;
    });
  }

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
    var tripIndex = _trips.indexWhere((trip) => trip['id'] == trip['id']);
    var trips = []..addAll(_trips);
    trips.replaceRange(tripIndex, tripIndex + 1, [trip]);
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

  getItinerary(dynamic itinerary, dynamic destination, String color) {
    setState(() {
      _itinerary = ItineraryData(
          itinerary: itinerary,
          color: color,
          destination: destination,
          loading: true,
          error: _itinerary.error);
    });
  }

  getItineraryBuilder(dynamic itinerary, dynamic destination, String color) {
    setState(() {
      _itineraryBuilder = ItineraryData(
          itinerary: itinerary,
          color: color,
          destination: destination,
          loading: true,
          error: _itinerary.error);
    });
  }

  setSelectedItinerary(String selectedItineraryId, bool loading,
      String destinationId, dynamic selectedItinerary) {
    setState(() {
      _selectedItinerary = SelectItineraryData(
          loading: loading,
          selectedItineraryId: selectedItineraryId,
          selectedItinerary: selectedItinerary,
          destinationId: destinationId);
    });
  }

  updateSelectedItinerary(String dayId, List<dynamic> itineraryItems,
      String justAdded, Map<String, dynamic> itinerary, String destinationId) {
    var selectedItinerary = _selectedItinerary.selectedItinerary;
    var index =
        selectedItinerary["days"].indexWhere((day) => day['id'] == dayId);
    selectedItinerary["days"][index]["itinerary_items"] = itineraryItems;

    setState(() {
      _selectedItinerary = SelectItineraryData(
          loading: _selectedItinerary.loading,
          selectedItineraryId: itinerary['id'],
          selectedItinerary: selectedItinerary,
          destinationId: destinationId);
    });
  }

  updateItineraryBuilder(String dayId, List<dynamic> itineraryItems,
      String justAdded, Map<String, dynamic> itinerary, String destinationId) {
    var itinerary = _itineraryBuilder.itinerary;
    var index = itinerary["days"].indexWhere((day) => day['id'] == dayId);
    var justAddedIndex =
        itineraryItems.indexWhere((itin) => itin['id'] == justAdded);
    itineraryItems[justAddedIndex]['justAdded'] = true;
    itinerary["days"][index]["itinerary_items"] = itineraryItems;
    setState(() {
      _itineraryBuilder = ItineraryData(
          color: _itineraryBuilder.color,
          destination: _itineraryBuilder.destination,
          loading: _itineraryBuilder.loading,
          error: _itineraryBuilder.error);
    });
  }

  updateItineraryBuilderDelete(String dayId, String id) {
    var itinerary = _itineraryBuilder.itinerary;
    var index = itinerary["days"].indexWhere((day) => day['id'] == dayId);
    var itineraryItems = itinerary["days"][index]["itinerary_items"];
    itineraryItems.removeWhere((item) => item['id'] == id);
    itinerary["days"][index]["itinerary_items"] = itineraryItems;
    setState(() {
      _itineraryBuilder = ItineraryData(
          itinerary: itinerary,
          color: _itineraryBuilder.color,
          destination: _itineraryBuilder.destination,
          loading: _itineraryBuilder.loading,
          error: _itineraryBuilder.error);
    });
  }

  setItineraryError(String error) {
    setState(() {
      _itinerary = ItineraryData(
          itinerary: _itinerary.itinerary,
          color: _itinerary.color,
          destination: _itinerary.destination,
          loading: _itinerary.loading,
          error: error);
    });
  }

  setItineraryBuilderError(String error) {
    setState(() {
      _itineraryBuilder = ItineraryData(
          itinerary: _itineraryBuilder.itinerary,
          color: _itineraryBuilder.color,
          destination: _itineraryBuilder.destination,
          loading: _itineraryBuilder.loading,
          error: error);
    });
  }

  setItineraryBuilderLoading(bool loading) {
    setState(() {
      _itineraryBuilder = ItineraryData(
          itinerary: _itineraryBuilder.itinerary,
          color: _itineraryBuilder.color,
          destination: _itineraryBuilder.destination,
          loading: loading,
          error: _itineraryBuilder.error);
    });
  }

  setSelectItineraryLoading(bool loading) {
    setState(() {
      _selectedItinerary = SelectItineraryData(
          loading: loading,
          selectedItineraryId: _selectedItinerary.selectedItineraryId,
          selectedItinerary: _selectedItinerary.selectedItinerary,
          destinationId: _selectedItinerary.destinationId);
    });
  }

  setItineraryLoading(bool loading) {
    setState(() {
      _itinerary = ItineraryData(
          itinerary: _itinerary.itinerary,
          color: _itinerary.color,
          destination: _itinerary.destination,
          loading: loading,
          error: _itinerary.error);
    });
  }

  login() async {
    var user = await googleLogin();
    setState(() {
      _currentUser = user;
    });
  }

  logout() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.signOut();
      print('logged out!');
      setState(() {
        _currentUser = null;
      });
    } catch (error) {
      print('store.dart error');
      print(error);
    }
  }

  checkLoginStatus() async {
    FirebaseUser user;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Actions are classes, so you can Typecheck them
    try {
      user = await _auth.currentUser();

      print('Logged in ' + user.displayName);

      setState(() {
        _currentUser = user;
      });
    } catch (error) {
      print('checkstatus error');
      print(error);
    }
  }
}
