
import 'package:flutter/foundation.dart';
import '../middleware/itineraries/middleware.dart';


class AppState {
  final List<dynamic> trips;
  final ItineraryData itinerary;
  final SelectItineraryData selectedItinerary;
  final ItineraryData itineraryBuilder;
  final bool tripLoading;
  AppState({
    @required this.trips,
    @required this.tripLoading,
    this.itinerary,
    this.selectedItinerary,
    this.itineraryBuilder
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
    tripLoading = false;
}
