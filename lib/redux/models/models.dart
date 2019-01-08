
import 'package:flutter/foundation.dart';


class AppState {
  final List<dynamic> trips;
  final bool tripLoading;
  AppState({
    @required this.trips,
    @required this.tripLoading
  });
  AppState.initialState()
    : trips = List.unmodifiable(<dynamic>[]),
    tripLoading = false;
}
