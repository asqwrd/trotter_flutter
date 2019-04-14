
import 'package:flutter/foundation.dart';
import '../middleware/itineraries/middleware.dart';
import 'package:firebase_auth/firebase_auth.dart';



class AppState {
  final List<dynamic> trips;
  final ItineraryData itinerary;
  final SelectItineraryData selectedItinerary;
  final ItineraryData itineraryBuilder;
  final bool tripLoading;
  final bool offline;
  final String tripsError;
  final FirebaseUser currentUser;
  
  AppState({
    @required this.trips,
    @required this.tripLoading,
    this.itinerary,
    this.selectedItinerary,
    this.itineraryBuilder,
    this.currentUser,
    this.tripsError,
    this.offline
  });
  AppState.initialState()
    : trips = List.unmodifiable(<dynamic>[]),
    itinerary = ItineraryData(
      itinerary: null,
      loading: true,
      color: null,
      destination: null
    ),
    itineraryBuilder = ItineraryData(
      itinerary: null,
      loading: true,
      color: null,
      destination: null
    ),
    selectedItinerary = SelectItineraryData(
      loading: false, 
      selectedItineraryId: null,
      selectedItinerary: null,
      destinationId: null,
    ),
    tripLoading = false,
    tripsError = null,
    offline = false,
    currentUser = null;
}
