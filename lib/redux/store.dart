
import 'reducers/index.dart';
import 'models/index.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
    trips: tripsReducer(state.trips,action),
    itinerary: getItineraryReducer(state.itinerary, action),
    itineraryBuilder: getItineraryBuilderReducer(state.itineraryBuilder, action),
    tripLoading: tripLoadingReducer(state.tripLoading, action)
  );
}