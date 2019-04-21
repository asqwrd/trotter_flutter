import 'package:redux/redux.dart';
import 'package:trotter_flutter/redux/actions/index.dart';
import '../../actions/itineraries/actions.dart';
import '../../middleware/itineraries/middleware.dart';

Map<String, dynamic> updateDayAfterAddReducer(dynamic state, dynamic action) {
  print(action.justAdded);
  var itinerary = state.itinerary;
  var index = itinerary["days"].indexWhere((day)=> day['id'] == action.dayId);
  var itineraryItems = action.itineraryItems;
  print(itineraryItems.length);
  var justAddedIndex = itineraryItems.indexWhere((itin)=> itin['id'] == action.justAdded);
  itineraryItems[justAddedIndex]['justAdded'] = true;
  itinerary["days"][index]["itinerary_items"] = itineraryItems;
  
  return itinerary;
}
Map<String, dynamic> updateSelectedDayAfterAddReducer(dynamic state, dynamic action) {
  var selectedItinerary = state.selectedItinerary;
  var index = selectedItinerary["days"].indexWhere((day)=> day['id'] == action.dayId);
  var itineraryItems = action.itineraryItems;
  selectedItinerary["days"][index]["itinerary_items"] = itineraryItems;
  
  return selectedItinerary;
}

Map<String, dynamic> updateDayAfterDeleteReducer(dynamic state, dynamic action) {
  var itinerary = state.itinerary;
  var index = itinerary["days"].indexWhere((day)=> day['id'] == action.dayId);
  var itineraryItems = itinerary["days"][index]["itinerary_items"];
  itineraryItems.removeWhere((item)=> item['id'] == action.id);
  itinerary["days"][index]["itinerary_items"] = itineraryItems;
  
  return itinerary;
}

ItineraryData getItineraryReducer(dynamic state, dynamic action) {
  if(action is GetItineraryAction){
    return ItineraryData(
      itinerary: action.itinerary,
      color: action.color,
      destination: action.destination,
      loading: true,
      error: state.error
    );
  }
  if(action is SetItineraryLoadingAction){
    return ItineraryData(
      itinerary: state.itinerary,
      color: state.color,
      destination: state.destination,
      loading: action.loading,
      error: state.error
    );
  }
  if(action is ErrorAction && action.page == "itinerary"){
    return ItineraryData(
      itinerary: state.itinerary,
      color: state.color,
      destination: state.destination,
      loading: state.loading,
      error: action.error
    );
  }

  return state;
}

SelectItineraryData getSelectItineraryReducer(dynamic state, dynamic action){
  if(action is SelectItineraryAction){
    return SelectItineraryData(
      loading: action.loading, 
      selectedItineraryId: action.selectedItineraryId,
      selectedItinerary: action.selectedItinerary,
      destinationId: action.destinationId
    );
  }

  if(action is UpdateDayAfterAddAction && (state.selectedItineraryId != null && action.itinerary['id'] == state.selectedItineraryId && action.destinationId == state.destinationId)){
    return SelectItineraryData(
      loading: state.loading,
      selectedItineraryId: action.itinerary['id'],
      selectedItinerary: updateSelectedDayAfterAddReducer(state, action),
      destinationId: action.destinationId
    );
  }

  if(action is SetSelectItineraryLoadingAction){
    return SelectItineraryData(
      loading: action.loading, 
      selectedItineraryId: state.selectedItineraryId,
      destinationId: state.destinationId,
      selectedItinerary: state.selectedItinerary,
    );
  }

  return state;
}

ItineraryData getItineraryBuilderReducer(dynamic state, dynamic action) {
  if(action is GetItineraryBuilderAction){
    return ItineraryData(
      itinerary: action.itinerary,
      color: action.color,
      destination: action.destination,
      loading: true,
      error: state.error
    );
  }
  if(action is UpdateDayAfterAddAction && (state.itinerary != null && state.itinerary['id'] == action.itinerary['id'])){
    return ItineraryData(
      itinerary: updateDayAfterAddReducer(state, action),
      color: state.color,
      destination: state.destination,
      loading: state.loading,
      error: state.error
    );
  }
  if(action is UpdateDayAfterDeleteAction){
    return ItineraryData(
      itinerary: updateDayAfterDeleteReducer(state, action),
      color: state.color,
      destination: state.destination,
      loading: state.loading,
      error: state.error
    );
  }
  if(action is SetItineraryBuilderLoadingAction){
    return ItineraryData(
      itinerary: state.itinerary,
      color: state.color,
      destination: state.destination,
      loading: action.loading,
      error: state.error
    );
  }
  if(action is ErrorAction && action.page == "itinerary_builder"){
    return ItineraryData(
      itinerary: state.itinerary,
      color: state.color,
      destination: state.destination,
      loading: state.loading,
      error: action.error
    );
  }
  return state;
}

bool itineraryLoadingReducer(dynamic state, action) {
  return action.loading;
}


final Reducer <List<dynamic>> itineraryReducer = combineReducers <List<dynamic>>([
  //new TypedReducer<dynamic, UpdateDayAfterAddAction>(updateDayAfterAddReducer),
]);