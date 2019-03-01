
import 'package:flutter/foundation.dart';
import '../middleware/itineraries/middleware.dart';


class AppState {
  final List<dynamic> trips;
  final ItineraryData itinerary;
  final bool tripLoading;
  AppState({
    @required this.trips,
    @required this.tripLoading,
    this.itinerary
  });
  AppState.initialState()
    : trips = List.unmodifiable(<dynamic>[]),
    itinerary = null,
    tripLoading = false;
}
